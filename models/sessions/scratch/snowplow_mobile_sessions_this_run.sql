{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    sort='start_tstamp',
    dist='session_id',
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  -- app id
  es.app_id,

  -- session fields
  es.session_identifier,
  es.original_session_id,
  es.session_id,
  es.session_index,
  es.previous_session_id,
  es.session_first_event_id,
  sa.session_last_event_id,

  sa.start_tstamp,
  sa.end_tstamp,
  {{ snowplow_utils.current_timestamp_in_utc() }} as model_tstamp,

  -- user fields
  es.user_id,
  es.original_device_user_id,
  es.device_user_id,
  es.user_identifier,
  es.network_userid,

  {% if var('snowplow__session_stitching') %}
    -- updated with mapping as part of post hook on derived sessions table
    cast(es.device_user_id as {{snowplow_utils.type_max_string() }}) as stitched_user_id,
  {% else %}
    cast(null as {{ snowplow_utils.type_max_string() }}) as stitched_user_id,
  {% endif %}

  sa.session_duration_s,
  sa.has_install,
  sv.screen_views,
  sv.screen_names_viewed,
  cast(sa.app_errors as {{ type_int() }}) as app_errors,
  cast(sa.fatal_app_errors as {{ type_int() }}) as fatal_app_errors,

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
  es.carrier,
  es.network_technology,
  es.network_type,
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

  --first/last build/version to measure app updates.
  es.build as first_build,
  sa.last_build,
  es.version as first_version,
  sa.last_version

  {%- if var('snowplow__session_passthroughs', []) -%}
    {%- set passthrough_names = [] -%}
    {%- for identifier in var('snowplow__session_passthroughs', []) %}
      {# Check if it's a simple column or a sql+alias #}
      {%- if identifier is mapping -%}
          ,{{identifier['sql']}} as {{identifier['alias']}}
          {%- do passthrough_names.append(identifier['alias']) -%}
      {%- else -%}
          ,es.{{identifier}}
          {%- do passthrough_names.append(identifier) -%}
      {%- endif -%}
    {% endfor -%}
  {%- endif %}

from {{ ref('snowplow_mobile_base_events_this_run') }} as es

inner join {{ ref('snowplow_mobile_sessions_aggs') }} as sa
on es.session_id = sa.session_id
and es.event_index_in_session = 1

left join {{ ref('snowplow_mobile_sessions_sv_details') }} sv
on es.session_id = sv.session_id
