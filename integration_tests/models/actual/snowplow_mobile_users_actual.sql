--Removing model_tstamp

select
  user_id,
  device_user_id,
  network_userid,
  start_tstamp,
  end_tstamp,
  model_tstamp,
  screen_views,
  screen_names_viewed,
  sessions,
  sessions_duration_s,
  active_days,
  app_errors,
  fatal_app_errors,
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
  first_os_version,
  last_os_version,
  android_idfa,
  apple_idfa,
  apple_idfv,
  open_idfa,
  geo_country,
  geo_region,
  geo_city,
  geo_zipcode,
  geo_latitude,
  geo_longitude,
  geo_region_name,
  geo_timezone,
  first_carrier,
  last_carrier

from {{ ref('snowplow_mobile_users') }}
