{% macro mobile_cluster_by_fields_sessions_lifecycle() %}

  {{ return(adapter.dispatch('mobile_cluster_by_fields_sessions_lifecycle', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__mobile_cluster_by_fields_sessions_lifecycle() %}

  {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["session_identifier"], snowflake_val=["to_date(start_tstamp)"])) }}

{% endmacro %}


{% macro cluster_by_fields_app_errors() %}

  {{ return(adapter.dispatch('cluster_by_fields_app_errors', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__cluster_by_fields_app_errors() %}

  {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["session_id"], snowflake_val=["to_date(derived_tstamp)"])) }}

{% endmacro %}

{% macro mobile_cluster_by_fields_screen_views() %}

  {{ return(adapter.dispatch('mobile_cluster_by_fields_screen_views', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__mobile_cluster_by_fields_screen_views() %}

  {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["device_user_id", "session_id"], snowflake_val=["to_date(derived_tstamp)"])) }}

{% endmacro %}


{% macro mobile_cluster_by_fields_sessions() %}

  {{ return(adapter.dispatch('mobile_cluster_by_fields_sessions', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__mobile_cluster_by_fields_sessions() %}

  {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["device_user_id"], snowflake_val=["to_date(start_tstamp)"])) }}

{% endmacro %}


{% macro mobile_cluster_by_fields_users() %}

  {{ return(adapter.dispatch('mobile_cluster_by_fields_users', 'snowplow_mobile')()) }}

{% endmacro %}

{% macro default__mobile_cluster_by_fields_users() %}

  {{ return(snowplow_utils.get_value_by_target_type(bigquery_val=["device_user_id"], snowflake_val=["to_date(start_tstamp)"])) }}

{% endmacro %}
