{{ 
  config(
    materialized='table',
    sort='derived_tstamp',
    dist='screen_view_id',
    tags=["this_run"]
  ) 
}}
{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mob_base_events_this_run'),
                                      'collector_tstamp',
                                      'collector_tstamp') %}

with app_errors_events as (
  select
      ae.message,
      ae.programming_language,
      ae.class_name,
      ae.exception_name,
      ae.is_fatal,
      ae.line_number,
      ae.stack_trace,
      ae.thread_id,
      ae.thread_name

  from {{ var('snowplow__app_error_context') }} ae

  where ae.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
)

, app_error_context as (
  select *

  from {{ ref('snowplow_mob_base_events_this_run') }} as ac

  where ev.event_name = 'application_error'
)

, select 

      ac.event_id,

      ac.app_id,

      ac.user_id,
      ac.device_user_id,
      ac.network_userid,

      ac.session_id,
      ac.session_index,
      ac.previous_session_id,
      ac.session_first_event_id,

      ac.dvce_created_tstamp,
      ac.collector_tstamp,
      ac.derived_tstamp,
      CURRENT_TIMESTAMP AS model_tstamp,

      ac.platform,
      ac.dvce_screenwidth,
      ac.dvce_screenheight,
      ac.device_manufacturer,
      ac.device_model,
      ac.os_type,
      ac.os_version,
      ac.android_idfa,
      ac.apple_idfa,
      ac.apple_idfv,
      ac.open_idfa,

      ac.screen_id,
      ac.screen_name,
      ac.screen_activity,
      ac.screen_fragment,
      ac.screen_top_view_controller,
      ac.screen_type,
      ac.screen_view_controller,

      ac.device_latitude,
      ac.device_longitude,
      ac.device_latitude_longitude_accuracy,
      ac.device_altitude,
      ac.device_altitude_accuracy,
      ac.device_bearing,
      ac.device_speed,
      ac.geo_country,
      ac.geo_region,
      ac.geo_city,
      ac.geo_zipcode,
      ac.geo_latitude,
      ac.geo_longitude,
      ac.geo_region_name,
      ac.geo_timezone,

      ac.user_ipaddress,
      ac.useragent,

      ac.carrier,
      ac.network_technology,
      ac.network_type,

      ac.build,
      ac.version,
      ac.event_index_in_session,

      ae.message,
      ae.programming_language,
      ae.class_name,
      ae.exception_name,
      ae.is_fatal,
      ae.line_number,
      ae.stack_trace,
      ae.thread_id,
      ae.thread_name    

    from app_error_context as ac
    inner join app_errors_events ae
    on ac.event_id = ae.root_id
    and ac.collector_tstamp = ae.root_tstamp