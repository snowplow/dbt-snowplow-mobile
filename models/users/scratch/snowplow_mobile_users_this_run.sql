{{ 
  config(
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
    {{ dbt_utils.current_timestamp() }} AS model_tstamp,

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

from {{ ref('snowplow_mobile_users_aggs') }} as b

inner join {{ ref('snowplow_mobile_users_sessions_this_run') }} as a
on a.session_id = b.first_session_id

inner join {{ ref('snowplow_mobile_users_lasts') }} c
on b.device_user_id = c.device_user_id
