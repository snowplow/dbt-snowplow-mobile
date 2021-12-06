{{ 
  config(
    materialized='table',
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["user_id"]),
    sort='start_tstamp',
    dist='device_user_id',
    tags=["this_run"]
  ) 
}}

select

    -- user fields
    a.user_id,
    a.device_user_id,
    a.network_userid,

    b.start_tstamp,
    b.end_tstamp,
    CURRENT_TIMESTAMP() AS model_tstamp,

    -- engagement fields
    b.screen_views,
    b.screen_names_viewed,
    b.sessions,
    b.sessions_duration_s,
    b.active_days,
    --errors
    b.app_errors,
    b.fatal_app_errors,

    -- screen fields
    a.first_screen_view_name,
    a.first_screen_view_transition_type,
    a.first_screen_view_type,

    c.last_screen_view_name,
    c.last_screen_view_transition_type,
    c.last_screen_view_type,

    -- device fields
    a.platform,
    a.dvce_screenwidth,
    a.dvce_screenheight,
    a.device_manufacturer,
    a.device_model,
    a.os_type,
    a.os_version first_os_version,
    c.last_os_version,
    a.android_idfa,
    a.apple_idfa,
    a.apple_idfv,
    a.open_idfa,

    -- geo fields
    a.geo_country,
    a.geo_region,
    a.geo_city,
    a.geo_zipcode,
    a.geo_latitude,
    a.geo_longitude,
    a.geo_region_name,
    a.geo_timezone,

    a.carrier first_carrier,
    c.last_carrier

from {{ ref('snowplow_mob_users_aggs') }} as b

inner join {{ ref('snowplow_mob_users_sessions_this_run') }} as a
on a.device_user_id = b.device_user_id

inner join {{ ref('snowplow_mob_users_lasts') }} c
on b.device_user_id = c.device_user_id