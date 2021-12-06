{% macro atomic_schema_by_target() %}

  {{ return(adapter.dispatch('atomic_schema_by_target', ['snowplow_mob'])()) }}

{% endmacro %}

{% macro default__atomic_schema_by_target() %}

  {{ return('atomic') }}

{% endmacro %}

{% macro bigquery__atomic_schema_by_target() %}

  {{ return('rt_pipeline_dev1') }}

{% endmacro %}
