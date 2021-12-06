{% macro get_session_id_path_sql(relation_alias) %}

  {{ return(adapter.dispatch('get_session_id_path_sql', ['snowplow_mob'])(relation_alias)) }}

{% endmacro %}

{% macro default__get_session_id_path_sql(relation_alias) %}

  {% set session_id_path_sql %}
    {{ relation_alias }}.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:id::VARCHAR(36)
  {% endset %}

  {{ return(session_id_path_sql) }}

{% endmacro %}

{% macro bigquery__get_session_id_path_sql(relation_alias) %}

  {%- set session_id = snowplow_utils.combine_column_versions(
                                  relation=source('atomic','events'),
                                  column_prefix='contexts_com_snowplowanalytics_snowplow_client_session_1_',
                                  source_fields=['session_id'],
                                  relation_alias=relation_alias
                                  )|join('') -%}

  {# TODO: Improve API of combine_column_versions so we dont need split #}
  {% set session_id_path_sql %}
    {{ session_id.split(' as session_id')[0] }}
  {% endset %}

  {{ return(session_id_path_sql) }}

{% endmacro %}
