{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

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
