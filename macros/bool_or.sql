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
