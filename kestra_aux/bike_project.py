#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import requests
import time
import pandas as pd
from google.cloud import storage
import os

# Function to get 'freguesia' from coordinates using Nominatim
def get_freguesia(lat, lon):
    url = "https://nominatim.openstreetmap.org/reverse"
    params = {
        'lat': lat,
        'lon': lon,
        'format': 'json',
        'zoom': 14,
        'addressdetails': 1
    }
    headers = {'User-Agent': 'CityBikes-ETL-Script'}
    try:
        response = requests.get(url, params=params, headers=headers)
        if response.status_code == 200:
            data = response.json()
            address = data.get('address', {})
            return {
                'suburb': address.get('suburb', None),
                'neighbourhood': address.get('neighbourhood', None),
                'city_district': address.get('city_district', None),
                'village': address.get('village', None)
            }
        else:
            print(f"Geocode error {response.status_code}: {response.text}")
            return None
    except Exception as e:
        print(f"Geocode request failed: {e}")
        return None

# Step 1: Access Gira network info from CityBikes API
citybikes_url = "https://api.citybik.es/v2/networks/gira"
response = requests.get(citybikes_url)

if response.status_code == 200:
    stations = response.json()['network']['stations']
    station_data = []

    for i, station in enumerate(stations):
        lat = station['latitude']
        lon = station['longitude']
        name = station['name']
        #free_bikes = station['free_bikes']
        #empty_slots = station['empty_slots']
        slots = station['extra']['slots']

        # Step 2: Get freguesia (respect Nominatim rate limits)
        freguesia = get_freguesia(lat, lon)
        #time.sleep(1)

        station_data.append({
            'name': name,
            'latitude': lat,
            'longitude': lon,
            #'free_bikes': free_bikes,
            #'empty_slots': empty_slots,
            #'freguesia': freguesia,
            'slots': slots,
            'suburb': freguesia.get('suburb'),
            'neighbourhood': freguesia.get('neighbourhood'),
            'city_district': freguesia.get('city_district'),
            'village': freguesia.get('village')
        })

    # Step 3: Convert to DataFrame and export to CSV
    df = pd.DataFrame(station_data)
    #print(df)
    df.to_csv("gira_station_status.csv", index=False)
    print("✅ Data saved to 'gira_station_status.csv'.")

else:
    print(f"Failed to fetch data from CityBikes API. Status code: {response.status_code}")


def upload_to_gcs(bucket_name, source_file_name, destination_blob_name):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_filename(source_file_name)

bucket_name = 'data_lake_locations'
source_file_name = "gira_station_status.csv"
destination_blob_name = "gira_station_locations.csv"

upload_to_gcs(bucket_name, source_file_name, destination_blob_name)
print(f"✅ File uploaded to gs://{bucket_name}/{destination_blob_name}")
os.remove(source_file_name)
print(f"🗑️ Local file '{source_file_name}' deleted from VM.")