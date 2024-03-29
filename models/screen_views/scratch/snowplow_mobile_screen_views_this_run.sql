{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    sort='derived_tstamp',
    dist='screen_view_id',
    cluster_by=snowplow_utils.get_value_by_target_type(bigquery_val=["session_id"]),
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

with screen_views_dedupe as (
  select
    ev.screen_view_id,
    ev.event_id,

    ev.app_id,

    ev.user_id,
    ev.original_device_user_id,
    ev.user_identifier,
    ev.device_user_id,
    ev.network_userid,

    ev.session_id,
    ev.session_identifier,
    ev.original_session_id,
    ev.session_index,
    ev.previous_session_id,
    ev.session_first_event_id,

    ev.dvce_created_tstamp,
    ev.collector_tstamp,
    ev.derived_tstamp,

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
    ev.carrier,
    ev.open_idfa,
    ev.network_technology,
    ev.network_type,

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

    ev.build,
    ev.version,

    row_number() over (partition by ev.screen_view_id order by ev.derived_tstamp) as screen_view_id_index

    {%- if var('snowplow__screen_view_passthroughs', []) -%}
      {%- set passthrough_names = [] -%}
      {%- for identifier in var('snowplow__screen_view_passthroughs', []) %}
      {# Check if it's a simple column or a sql+alias #}
        {%- if identifier is mapping -%}
          ,{{identifier['sql']}} as {{identifier['alias']}}
          {%- do passthrough_names.append(identifier['alias']) -%}
        {%- else -%}
          ,ev.{{identifier}}
          {%- do passthrough_names.append(identifier) -%}
        {%- endif -%}
      {% endfor -%}
  {%- endif %}

  from {{ ref('snowplow_mobile_base_events_this_run') }} as ev

  where ev.event_name = 'screen_view'
  and ev.screen_view_id is not null
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
  ev.user_identifier,
  ev.device_user_id,
  ev.network_userid,

  ev.session_id,
  ev.original_session_id,
  ev.session_identifier,
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
  ev.carrier,
  ev.network_technology,
  ev.network_type,

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
  ev.build,
  ev.version

  {%- if var('snowplow__screen_view_passthroughs', []) -%}
    {%- for col in passthrough_names %}
      , ev.{{col}}
    {%- endfor -%}
  {%- endif %}

from cleaned_screen_view_events ev
