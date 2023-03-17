{{
  config(
    enabled=(var("snowplow__enable_geolocation_context", false)
      and target.type in ['redshift','postgres'] | as_bool()),
    dist='root_id',
    sort='root_tstamp'
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mobile_base_events_this_run_limits'),
                                      'lower_limit',
                                      'upper_limit') %}
with base as (

  select
    gc.root_id,
    gc.root_tstamp,
    gc.latitude AS device_latitude,
    gc.longitude AS device_longitude,
    gc.latitude_longitude_accuracy AS device_latitude_longitude_accuracy,
    gc.altitude AS device_altitude,
    gc.altitude_accuracy AS device_altitude_accuracy,
    gc.bearing AS device_bearing,
    gc.speed AS device_speed,
    row_number() over (partition by root_id order by root_tstamp) dedupe_index

  from {{ var("snowplow__geolocation_context") }} gc

  where gc.root_tstamp between {{ lower_limit }} and {{ upper_limit }}

)

select *

from base

where dedupe_index = 1
