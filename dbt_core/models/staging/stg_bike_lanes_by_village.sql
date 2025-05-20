{{ config(materialized='view') }}

select
  village,
  sum(lane_length_km) as total_bike_lane_km
from {{ ref('stg_bike_lanes') }}
group by village
