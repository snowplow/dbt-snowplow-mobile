{% macro cluster_by_fields_sessions_lifecycle() %}

  {{ return(adapter.dispatch('cluster_by_fields_sessions_lifecycle', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_sessions_lifecycle() %}

  {{ return(snowplow_utils.get_cluster_by(bigquery_cols=["session_id"], snowflake_cols=["to_date(derived_tstamp)"])) }}

{% endmacro %}


{% macro cluster_by_fields_app_errors() %}

  {{ return(adapter.dispatch('cluster_by_fields_app_errors', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_app_errors() %}

  {{ return(snowplow_utils.get_cluster_by(bigquery_cols=["event_id"], snowflake_cols=["to_date(derived_tstamp)"])) }}

{% endmacro %}

{% macro cluster_by_fields_screen_views() %}

  {{ return(adapter.dispatch('cluster_by_fields_screen_views', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_screen_views() %}

  {{ return(snowplow_utils.get_cluster_by(bigquery_cols=["device_user_id", "session_id"], snowflake_cols=["to_date(derived_tstamp)"])) }}

{% endmacro %}


{% macro cluster_by_fields_sessions() %}

  {{ return(adapter.dispatch('cluster_by_fields_sessions', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_sessions() %}

  {{ return(snowplow_utils.get_cluster_by(bigquery_cols=["session_id"], snowflake_cols=["to_date(derived_tstamp)"])) }}

{% endmacro %}


{% macro cluster_by_fields_users() %}

  {{ return(adapter.dispatch('cluster_by_fields_users', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_users() %}

  {{ return(snowplow_utils.get_cluster_by(bigquery_cols=["device_user_id"], snowflake_cols=["to_date(derived_tstamp)"])) }}

{% endmacro %}
