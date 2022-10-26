{{
  config(
    sort='derived_tstamp',
    dist='screen_view_id',
    tags=["this_run"]
  )
}}

with screen_view_ids as (
  select
    sv.root_id,
    sv.root_tstamp,
    sv.id as screen_view_id,
    sv.name as screen_view_name,
    sv.previous_id as screen_view_previous_id,
    sv.previous_name as screen_view_previous_name,
    sv.previous_type as screen_view_previous_type,
    sv.transition_type as screen_view_transition_type,
    sv.type as screen_view_type

  from {{ var('snowplow__screen_view_events') }} sv
)

, screen_view_events as (
  select *

  from {{ ref('snowplow_mobile_base_events_this_run') }} as ev

  where ev.event_name = 'screen_view'
)

, screen_views_dedupe as (
  select
    sv.screen_view_id,
    ev.event_id,

    ev.app_id,

    ev.user_id,
    ev.device_user_id,
    ev.network_userid,

    ev.session_id,
    ev.session_index,
    ev.previous_session_id,
    ev.session_first_event_id,

    ev.dvce_created_tstamp,
    ev.collector_tstamp,
    ev.derived_tstamp,

    sv.screen_view_name,
    sv.screen_view_transition_type,
    sv.screen_view_type,
    ev.screen_fragment,
    ev.screen_top_view_controller,
    ev.screen_view_controller,
    sv.screen_view_previous_id,
    sv.screen_view_previous_name,
    sv.screen_view_previous_type,

    ev.platform,
    ev.dvce_screenwidth,
    ev.dvce_screenheight,
    ev.device_manufacturer,
    ev.device_model,
    ev.os_type,
    ev.os_version,
    ev.android_idfa,
    ev.apple_idfa,
    ev.apple_idfv,

    ev.device_latitude,
    ev.device_longitude,
    ev.device_latitude_longitude_accuracy,
    ev.device_altitude,
    ev.device_altitude_accuracy,
    ev.device_bearing,
    ev.device_speed,
    ev.geo_country,
    ev.geo_region,
    ev.geo_city,
    ev.geo_zipcode,
    ev.geo_latitude,
    ev.geo_longitude,
    ev.geo_region_name,
    ev.geo_timezone,

    ev.user_ipaddress,

    ev.useragent,

    ev.carrier,
    ev.open_idfa,
    ev.network_technology,
    ev.network_type,

    ev.build,
    ev.version,

    row_number() over (partition by sv.screen_view_id order by ev.derived_tstamp) as screen_view_id_index

  from screen_view_events as ev

  inner join screen_view_ids sv
  on ev.event_id = sv.root_id
  and ev.collector_tstamp = sv.root_tstamp

  where sv.screen_view_id is not null
)

, cleaned_screen_view_events AS (
  select
    *,
    row_number() over (partition by sv.session_id order by sv.derived_tstamp) as screen_view_in_session_index

  from screen_views_dedupe sv

  where sv.screen_view_id_index = 1 --take first row of duplicates
)

select
  ev.screen_view_id,
  ev.event_id,

  ev.app_id,

  ev.user_id,
  ev.device_user_id,
  ev.network_userid,

  ev.session_id,
  ev.session_index,
  ev.previous_session_id,
  ev.session_first_event_id,

  ev.screen_view_in_session_index,
  max(ev.screen_view_in_session_index) over (partition by ev.session_id) as screen_views_in_session,

  ev.dvce_created_tstamp,
  ev.collector_tstamp,
  ev.derived_tstamp,
  {{ snowplow_utils.current_timestamp_in_utc() }} AS model_tstamp,

  ev.screen_view_name,
  ev.screen_view_transition_type,
  ev.screen_view_type,
  ev.screen_fragment,
  ev.screen_top_view_controller,
  ev.screen_view_controller,
  ev.screen_view_previous_id,
  ev.screen_view_previous_name,
  ev.screen_view_previous_type,

  ev.platform,
  ev.dvce_screenwidth,
  ev.dvce_screenheight,
  ev.device_manufacturer,
  ev.device_model,
  ev.os_type,
  ev.os_version,
  ev.android_idfa,
  ev.apple_idfa,
  ev.apple_idfv,
  ev.open_idfa,

  ev.device_latitude,
  ev.device_longitude,
  ev.device_latitude_longitude_accuracy,
  ev.device_altitude,
  ev.device_altitude_accuracy,
  ev.device_bearing,
  ev.device_speed,
  ev.geo_country,
  ev.geo_region,
  ev.geo_city,
  ev.geo_zipcode,
  ev.geo_latitude,
  ev.geo_longitude,
  ev.geo_region_name,
  ev.geo_timezone,

  ev.user_ipaddress,

  ev.useragent,

  ev.carrier,
  ev.network_technology,
  ev.network_type,

  ev.build,
  ev.version

from cleaned_screen_view_events ev
