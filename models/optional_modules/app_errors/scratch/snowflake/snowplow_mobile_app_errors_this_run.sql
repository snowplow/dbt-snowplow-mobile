{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    tags=["this_run"],
    enabled=(var("snowplow__enable_app_errors_module", false) and target.type == 'snowflake' | as_bool()),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
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

      --Error details
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:message::VARCHAR() AS message,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:programmingLanguage::VARCHAR() AS programming_language,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:className::VARCHAR() AS class_name,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:exceptionName::VARCHAR() AS exception_name,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:isFatal::BOOLEAN AS is_fatal,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:lineNumber::INT AS line_number,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:stackTrace::VARCHAR() AS stack_trace,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:threadId::INT AS thread_id,
  e.unstruct_event_com_snowplowanalytics_snowplow_application_error_1:threadName::VARCHAR() AS thread_name

from {{ ref('snowplow_mobile_base_events_this_run') }} as e
where e.event_name = 'application_error'
