{{ config(materialized='view') }}

select
  name as station_name,
  latitude,
  longitude,
  slots,
  coalesce(village, city_district, neighbourhood, suburb) as village
from {{ source('bike', 'gira_station_locations') }}
where coalesce(village, suburb, neighbourhood, city_district) is not null