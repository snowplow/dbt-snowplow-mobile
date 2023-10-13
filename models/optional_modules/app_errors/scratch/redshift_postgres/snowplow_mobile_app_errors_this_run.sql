{{
  config(
    sort='derived_tstamp',
    dist='event_id',
    tags=["this_run"],
    enabled=(var("snowplow__enable_app_errors_module", false) and target.type in ['redshift', 'postgres'] | as_bool())
  )
}}
{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mobile_base_events_this_run'),
                                      'collector_tstamp',
                                      'collector_tstamp') %}

with app_error_base_events as (
  select *

  from {{ ref('snowplow_mobile_base_events_this_run') }} as ac

  where ac.event_name = 'application_error'
)
select

  abe.event_id,

  abe.app_id,

  abe.user_id,
  abe.device_user_id,
  abe.user_identifier,
  abe.network_userid,

  abe.session_id,
  abe.session_identifier,
  abe.session_index,
  abe.previous_session_id,
  abe.session_first_event_id,

  abe.dvce_created_tstamp,
  abe.collector_tstamp,
  abe.derived_tstamp,
  CURRENT_TIMESTAMP AS model_tstamp,

  abe.platform,
  abe.dvce_screenwidth,
  abe.dvce_screenheight,
  abe.device_manufacturer,
  abe.device_model,
  abe.os_type,
  abe.os_version,
  abe.android_idfa,
  abe.apple_idfa,
  abe.apple_idfv,
  abe.open_idfa,

  abe.screen_id,
  abe.screen_name,
  abe.screen_activity,
  abe.screen_fragment,
  abe.screen_top_view_controller,
  abe.screen_type,
  abe.screen_view_controller,

  abe.device_latitude,
  abe.device_longitude,
  abe.device_latitude_longitude_accuracy,
  abe.device_altitude,
  abe.device_altitude_accuracy,
  abe.device_bearing,
  abe.device_speed,
  abe.geo_country,
  abe.geo_region,
  abe.geo_city,
  abe.geo_zipcode,
  abe.geo_latitude,
  abe.geo_longitude,
  abe.geo_region_name,
  abe.geo_timezone,

  abe.user_ipaddress,
  abe.useragent,

  abe.carrier,
  abe.network_technology,
  abe.network_type,

  abe.build,
  abe.version,
  abe.event_index_in_session,

  abe.app_err_con_message,
  abe.app_err_con_programming_language,
  abe.app_err_con_class_name,
  abe.app_err_con_exception_name,
  abe.app_err_con_is_fatal,
  abe.app_err_con_line_number,
  abe.app_err_con_stack_trace,
  abe.app_err_con_thread_id,
  abe.app_err_con_thread_name

from app_error_base_events as abe
