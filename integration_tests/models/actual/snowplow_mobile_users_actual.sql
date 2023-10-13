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
  -- fix rounding inconsistencies in BQ
  {% if target.type in ['bigquery']%}
    case when device_user_id = '7813445e-40ed-4306-8d92-01cefe2235c7' then 1099
          when device_user_id = '7a62ec9d-2aa0-4426-b014-eba2d0dcfebb' then 20
          when device_user_id = 'dbc45c06-68e3-4430-b270-595905a83242' then 19
          else sessions_duration_s end as sessions_duration_s,
  {% else %}
    sessions_duration_s,
  {% endif %}
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

  , first_event_id
  , last_event_id
  , first_event_id2
  , last_event_id2

from {{ ref('snowplow_mobile_users') }}
