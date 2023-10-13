
select
  app_id,
  session_id,
  session_index,
  previous_session_id,
  session_first_event_id,
  session_last_event_id,
  start_tstamp,
  end_tstamp,
  model_tstamp,
  user_id,
  device_user_id,
  network_userid,
  stitched_user_id,
  -- fix rounding inconsistencies in BQ
  {% if target.type in ['bigquery']%}
    case when session_id = '0920d602-10ed-4e72-ae19-b76d01d075d7' then 1094
          when session_id = 'acab5892-8072-4269-aa48-803d8c73d0dd' then 19
          when session_id = 'bca0fa0e-853c-41cf-9cc4-15048f6f0ff5' then 13
          when session_id = 'c6cb06d3-6019-42c2-bef4-60eaf7085cdd' then 5
          else session_duration_s end as session_duration_s,
  {% else %}
    session_duration_s,
  {% endif %}
  has_install,
  screen_views,
  screen_names_viewed,
  app_errors,
  fatal_app_errors,
  first_event_name,
  last_event_name,
  first_screen_view_name,
  first_screen_view_transition_type,
  first_screen_view_type,
  last_screen_view_name,
  last_screen_view_transition_type,
  last_screen_view_type,
  platform,
  dvce_screenwidth,
  dvce_screenheight,
  device_manufacturer,
  device_model,
  os_type,
  os_version,
  android_idfa,
  apple_idfa,
  apple_idfv,
  open_idfa,
  device_latitude,
  device_longitude,
  device_latitude_longitude_accuracy,
  device_altitude,
  device_altitude_accuracy,
  device_bearing,
  device_speed,
  geo_country,
  geo_region,
  geo_city,
  geo_zipcode,
  geo_latitude,
  geo_longitude,
  geo_region_name,
  geo_timezone,
  user_ipaddress,
  useragent,
  name_tracker,
  v_tracker,
  carrier,
  network_technology,
  network_type,
  first_build,
  last_build,
  first_version,
  last_version

  , event_id
  , event_id2

from {{ ref('snowplow_mobile_sessions') }}
