{{ config(materialized='view') }}

select
  OBJECTID as id,
  DESIGNACAO as name,
  HIERARQUIA as hierarquia,
  TIPOLOGIA as type,
  NIVEL_SEGREGACAO as segregation,
  FREGUESIA as village,
  COMP_M as lane_length_m,
  COMP_KM as lane_length_km
from {{ source('bike', 'bike_lanes_data') }}
where COMP_KM is not null