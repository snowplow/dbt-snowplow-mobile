{{ 
  config(
    materialized='table',
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["domain_userid"]),
    sort='start_tstamp',
    dist='session_id',
    tags=["this_run"]
  ) 
}}

  select
    es.app_id,

    es.session_id,
    es.session_index,
    es.previous_session_id,
    es.session_first_event_id,
    sa.session_last_event_id,

    sa.start_tstamp,
    sa.end_tstamp,
    CURRENT_TIMESTAMP() as model_tstamp,

    es.user_id,
    es.device_user_id,
    es.network_userid,

    sa.session_duration_s,
    sa.has_install,
    sv.screen_views,
    sv.screen_names_viewed,
    sa.app_errors,
    sa.fatal_app_errors,

    es.event_name as first_event_name,
    sa.last_event_name,

    sv.first_screen_view_name,
    sv.first_screen_view_transition_type,
    sv.first_screen_view_type,

    sv.last_screen_view_name,
    sv.last_screen_view_transition_type,
    sv.last_screen_view_type,

    es.platform,
    es.dvce_screenwidth,
    es.dvce_screenheight,
    es.device_manufacturer,
    es.device_model,
    es.os_type,
    es.os_version,
    es.android_idfa,
    es.apple_idfa,
    es.apple_idfv,
    es.open_idfa,

    es.device_latitude,
    es.device_longitude,
    es.device_latitude_longitude_accuracy,
    es.device_altitude,
    es.device_altitude_accuracy,
    es.device_bearing,
    es.device_speed,
    es.geo_country,
    es.geo_region,
    es.geo_city,
    es.geo_zipcode,
    es.geo_latitude,
    es.geo_longitude,
    es.geo_region_name,
    es.geo_timezone,

    es.user_ipaddress,

    es.useragent,
    es.name_tracker,
    es.v_tracker,

    es.carrier,
    es.network_technology,
    es.network_type,
    --first/last build/version to measure app updates.
    es.build as first_build,
    sa.last_build,
    es.version as first_version,
    sa.last_version

from {{ ref('snowplow_mob_base_events_this_run') }} as es

inner join {{ ref('snowplow_mob_sessions_aggs') }} as sa
on es.session_id = sa.session_id

left join {{ ref('snowplow_mob_sessions_sv_details') }} sv
on es.session_id = sv.session_id

where
es.event_index_in_session = 1