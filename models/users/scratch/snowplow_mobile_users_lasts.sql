{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    sort='device_user_id',
    dist='device_user_id',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  a.device_user_id,
  a.last_screen_view_name,
  a.last_screen_view_transition_type,
  a.last_screen_view_type,
  a.carrier AS last_carrier,
  a.os_version AS last_os_version

  {%- if var('snowplow__user_last_passthroughs', []) -%}
    {%- for identifier in var('snowplow__user_last_passthroughs', []) %}
    {# Check if it's a simple column or a sql+alias #}
    {%- if identifier is mapping -%}
        ,{{identifier['sql']}} as {{identifier['alias']}}
    {%- else -%}
        ,a.{{identifier}} as last_{{identifier}}
    {%- endif -%}
    {% endfor -%}
  {%- endif %}

from {{ ref('snowplow_mobile_users_sessions_this_run') }} a

inner join {{ ref('snowplow_mobile_users_aggs') }} b
on a.session_id = b.last_session_id
