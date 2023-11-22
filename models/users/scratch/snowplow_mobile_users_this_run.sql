{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    sort='start_tstamp',
    dist='device_user_id',
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select

    -- user fields
    a.user_identifier,
    a.original_device_user_id,
    a.user_id,
    a.device_user_id,
    a.network_userid,

    b.start_tstamp,
    b.end_tstamp,
    {{ current_timestamp() }} AS model_tstamp,

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
    a.carrier first_carrier,
    c.last_carrier,

    -- geo fields
    a.geo_country,
    a.geo_region,
    a.geo_city,
    a.geo_zipcode,
    a.geo_latitude,
    a.geo_longitude,
    a.geo_region_name,
    a.geo_timezone

  {%- if var('snowplow__user_first_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_first_passthroughs', []) %}
      {# Check if it's a simple column or a sql+alias #}
      {%- if identifier is mapping -%}
          ,{{identifier['sql']}} as {{identifier['alias']}}
      {%- else -%}
          ,a.{{identifier}} as first_{{identifier}}
      {%- endif -%}
    {% endfor -%}
  {%- endif %}
  {%- if var('snowplow__user_last_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_last_passthroughs', []) %}
      {# Check if it's a simple column or a sql+alias #}
      {%- if identifier is mapping -%}
          ,c.{{identifier['alias']}}
      {%- else -%}
          ,c.last_{{identifier}}
      {%- endif -%}
    {% endfor -%}
  {%- endif %}

from {{ ref('snowplow_mobile_users_aggs') }} as b

inner join {{ ref('snowplow_mobile_users_sessions_this_run') }} as a
on a.session_id = b.first_session_id

inner join {{ ref('snowplow_mobile_users_lasts') }} c
on b.device_user_id = c.device_user_id
