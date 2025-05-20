{{ config(
    materialized = 'table'
) }}

with changes as (
    select
        station_name,
        village,
        interval_start,
        avg_free_bikes,
        lag(avg_free_bikes) over (
            partition by station_name
            order by interval_start
        ) as prev_avg_free_bikes
    from {{ ref('inc_bike_station_utilization_incremental') }}
),

diffs as (
    select
        station_name,
        village,
        interval_start,
        (avg_free_bikes - prev_avg_free_bikes) as bike_change,
        extract(hour from interval_start) as hour_start,
        extract(hour from interval_start)+4 as hour_end,
        -- Get weekday name
        format_date('%A', date(interval_start)) as weekday,
        -- Map weekday number (1 = Monday, ..., 7 = Sunday)
        case extract(dayofweek from date(interval_start))
            when 1 then 7
            when 2 then 1
            when 3 then 2
            when 4 then 3
            when 5 then 4
            when 6 then 5
            when 7 then 6
        end as weekday_num,
        case
            when extract(hour from interval_start) between 7 and 20 then 'working_hours'
            else 'off_hours'
        end as working_hours_flag
    from changes
    where prev_avg_free_bikes is not null
),

aggregated as (
    select
        station_name,
        village,
        hour_start,
        hour_end,
        weekday,
        weekday_num,
        concat(weekday_num, ' - ', weekday) as weekday_,
        working_hours_flag,
        avg(bike_change) as avg_change,
        avg(abs(bike_change)) as avg_activity,
        sum(abs(bike_change)) as sum_activity
    from diffs
    group by station_name, village, hour_start,hour_end, weekday, weekday_num, working_hours_flag
)

select *
from aggregated
order by village, hour_start, hour_end, weekday_num