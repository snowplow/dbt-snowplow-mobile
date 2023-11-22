{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    enabled=(var("snowplow__enable_app_errors_module", false) and target.type == 'bigquery' | as_bool())
  )
}}

select
  e.event_id,

  e.app_id,

  e.user_id,
  e.device_user_id,
  e.network_userid,

  e.session_id,
  e.session_index,
  e.previous_session_id,
  e.session_first_event_id,

  e.dvce_created_tstamp,
  e.collector_tstamp,
  e.derived_tstamp,
  {{ snowplow_utils.current_timestamp_in_utc() }} AS model_tstamp,

  e.platform,
  e.dvce_screenwidth,
  e.dvce_screenheight,
  e.device_manufacturer,
  e.device_model,
  e.os_type,
  e.os_version,
  e.android_idfa,
  e.apple_idfa,
  e.apple_idfv,
  e.open_idfa,

  e.screen_id,
  e.screen_name,
  e.screen_activity,
  e.screen_fragment,
  e.screen_top_view_controller,
  e.screen_type,
  e.screen_view_controller,

  e.device_latitude,
  e.device_longitude,
  e.device_latitude_longitude_accuracy,
  e.device_altitude,
  e.device_altitude_accuracy,
  e.device_bearing,
  e.device_speed,
  e.geo_country,
  e.geo_region,
  e.geo_city,
  e.geo_zipcode,
  e.geo_latitude,
  e.geo_longitude,
  e.geo_region_name,
  e.geo_timezone,

  e.user_ipaddress,
  e.useragent,

  e.carrier,
  e.network_technology,
  e.network_type,

  e.build,
  e.version,
  e.event_index_in_session,

  -- app error events
  {{ snowplow_utils.get_optional_fields(
      enabled=true,
      fields=app_error_context_fields(),
      col_prefix='unstruct_event_com_snowplowanalytics_snowplow_application_error_1_',
      relation=ref('snowplow_mobile_base_events_this_run'),
      relation_alias='e') }}

from {{ ref('snowplow_mobile_base_events_this_run') }} as e

where e.event_name = 'application_error'
