{{ 
  config(
    partition_by = {
      "field": "derived_tstamp",
      "data_type": "timestamp" 
    },
    sort='derived_tstamp',
    dist='event_id',
    tags=["this_run"],
    enabled=var("snowplow__enable_app_errors_module", false)
  ) 
}}
{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mobile_base_events_this_run'),
                                      'collector_tstamp',
                                      'collector_tstamp') %}

with app_errors_events as (
  select
      ae.root_id,
      ae.root_tstamp,
      ae.message,
      ae.programming_language,
      ae.class_name,
      ae.exception_name,
      ae.is_fatal,
      ae.line_number,
      ae.stack_trace,
      ae.thread_id,
      ae.thread_name

  from {{ var('snowplow__app_errors_table') }} ae

  where ae.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
)

, app_error_base_events as (
  select *

  from {{ ref('snowplow_mobile_base_events_this_run') }} as ac

  where ac.event_name = 'application_error'
)
select 

  abe.event_id,

  abe.app_id,

  abe.user_id,
  abe.device_user_id,
  abe.network_userid,

  abe.session_id,
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

  ae.message,
  ae.programming_language,
  ae.class_name,
  ae.exception_name,
  ae.is_fatal,
  ae.line_number,
  ae.stack_trace,
  ae.thread_id,
  ae.thread_name    

from app_error_base_events as abe
inner join app_errors_events ae
on abe.event_id = ae.root_id
and abe.collector_tstamp = ae.root_tstamp
