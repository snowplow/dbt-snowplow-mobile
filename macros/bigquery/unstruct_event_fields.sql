{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro screen_view_event_fields() %}
  
  {% set screen_view_event_fields = [
    {'field':('id', 'screen_view_id'), 'dtype':'string'},
    {'field':('name', 'screen_view_name'), 'dtype':'string'},
    {'field':('previous_id', 'screen_view_previous_id'), 'dtype':'string'},
    {'field':('previous_name', 'screen_view_previous_name'), 'dtype':'string'},
    {'field':('previous_type', 'screen_view_previous_type'), 'dtype':'string'},
    {'field':('transition_type', 'screen_view_transition_type'), 'dtype':'string'},
    {'field':('type', 'screen_view_type'), 'dtype':'string'}
    ] %}

  {{ return(screen_view_event_fields) }}

{% endmacro %}
