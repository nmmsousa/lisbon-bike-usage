{{ config(
    materialized = 'incremental',
    unique_key = ['station_name', 'interval_start']
) }}

with base as (
    select
        name as station_name,
        bs.village,
        -- Truncate the timestamp to a 4-hour interval
        TIMESTAMP_TRUNC(timestamp, HOUR) - INTERVAL MOD(EXTRACT(HOUR FROM timestamp), 4) HOUR as interval_start,
        -- Calculate the interval_end by adding 4 hours to interval_start
        TIMESTAMP_ADD(
            TIMESTAMP_TRUNC(timestamp, HOUR) - INTERVAL MOD(EXTRACT(HOUR FROM timestamp), 4) HOUR, 
            INTERVAL 4 HOUR
        ) as interval_end,     
        -- Aggregations
        avg(free_bikes) as avg_free_bikes,
        max(free_bikes) as max_free_bikes,
        min(free_bikes) as min_free_bikes,
        avg(empty_slots) as avg_empty_slots,
        max(empty_slots) as max_empty_slots,
        min(empty_slots) as min_empty_slots
    from {{ source('bike', 'bike_data_row') }} as bdr
    inner join {{ ref ('stg_bike_stations') }} as bs on bs.longitude = bdr.longitude and bs.latitude = bdr.latitude
    
    {% if is_incremental() %}
        -- Only select new records after the last processed interval
        where timestamp > (select max(interval_start) from {{ this }})
    {% endif %}

    group by station_name, bs.village, interval_start, interval_end
)

select * from base
