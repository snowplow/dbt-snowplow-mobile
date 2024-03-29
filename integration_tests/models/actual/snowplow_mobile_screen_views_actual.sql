{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

-- Removing model_tstamp

select
  screen_view_id,
  event_id,
  app_id,
  user_id,
  device_user_id,
  network_userid,
  session_id,
  session_index,
  previous_session_id,
  session_first_event_id,
  screen_view_in_session_index,
  screen_views_in_session,
  dvce_created_tstamp,
  collector_tstamp,
  derived_tstamp,
  model_tstamp,
  screen_view_name,
  screen_view_transition_type,
  screen_view_type,
  screen_fragment,
  screen_top_view_controller,
  screen_view_controller,
  screen_view_previous_id,
  screen_view_previous_name,
  screen_view_previous_type,
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
  carrier,
  network_technology,
  network_type,
  build,
  version

  , event_id2
  , v_collector

from {{ ref('snowplow_mobile_screen_views') }}
