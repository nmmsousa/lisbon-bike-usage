{{ config(materialized='table') }}

with stations as (
  select village, count(*) as num_stations, sum(slots) as total_slots
  from {{ ref('stg_bike_stations') }}
  group by village
),

lanes as (
  select * from {{ ref('stg_bike_lanes_by_village') }}
)

select
  s.village,
  coalesce(s.num_stations,0) as num_stations,
  coalesce(round(l.total_bike_lane_km, 2),0) as total_bike_lane_km,
  coalesce(round(s.num_stations / nullif(l.total_bike_lane_km, 0), 2),0) as statins_per_km,
  s.total_slots,
  coalesce(round(s.total_slots / nullif(l.total_bike_lane_km, 0), 2),0) as slots_per_km
from stations s
left join lanes l on s.village = l.village
order by s.num_stations desc
