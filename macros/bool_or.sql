{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro bool_or(field) %}

  {{ return(adapter.dispatch('bool_or', 'snowplow_mobile')(field)) }}

{% endmacro %}

{% macro default__bool_or(field) %}

  BOOL_OR(
    {{ field }}
  )

{% endmacro %}

{% macro snowflake__bool_or(field) %}

  BOOLOR_AGG(
    {{ field }}
  )

{% endmacro %}

{% macro bigquery__bool_or(field) %}

  LOGICAL_OR(
    {{ field }}
  )

{% endmacro %}
