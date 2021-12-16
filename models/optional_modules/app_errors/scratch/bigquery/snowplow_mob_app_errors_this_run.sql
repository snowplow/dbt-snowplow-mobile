{{ 
  config(
    materialized='table',
    sort='derived_tstamp',
    dist='screen_view_id',
    tags=["this_run"]
  ) 
}}
{% set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mob_base_events_this_run'),
                                      'collector_tstamp',
                                      'collector_tstamp') %}


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
        CURRENT_TIMESTAMP() AS model_tstamp,

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
        {{ get_fields_from_col(
           col_prefix='unstruct_event_com_snowplowanalytics_snowplow_application_error_1_',
           fields=app_error_context_fields(),
           relation=ref('snowplow_mob_base_events_this_run'),
           relation_alias='e') }}
    --from {{ var('snowplow__app_error_context') }} as a

from {{ ref('snowplow_mob_base_events_this_run') }} as e
    
where e.event_name = 'application_error'