{% macro start_date_by_target() %}

  {{ return(adapter.dispatch('start_date_by_target', ['snowplow_mob'])()) }}

{% endmacro %}

{% macro default__start_date_by_target() %}

  {{ return('2020-01-01') }}

{% endmacro %}

{% macro bigquery__start_date_by_target() %}

  {{ return('2021-03-01') }}

{% endmacro %}

{% macro redshift__start_date_by_target() %}

  {{ return('2020-10-01') }}

{% endmacro %}

{% macro snowflake__start_date_by_target() %}

  {{ return('2020-10-01') }}

{% endmacro %}
