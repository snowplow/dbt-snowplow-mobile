{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    sort='collector_tstamp',
    dist='event_id',
    tags=["this_run"]
  )
}}

{# dbt passed variables by reference so need to use copy to avoid altering the list multiple times #}
{% set contexts = var('snowplow__entities_or_sdes', []).copy() %}

{% do contexts.append({'schema': var('snowplow__session_context'), 'prefix': 'session_con', 'single_entity': True}) %}

{% do contexts.append({'schema': var('snowplow__screen_view_context'), 'prefix': 'screen_view', 'single_entity': True}) %}

{% if var('snowplow__enable_mobile_context', false) -%}
  {% do contexts.append({'schema': var('snowplow__mobile_context'), 'prefix': 'mobile_con', 'single_entity': True}) %}
{% endif -%}

{% if var('snowplow__enable_geolocation_context', false) -%}
  {% do contexts.append({'schema': var('snowplow__geolocation_context'), 'prefix': 'geo_con', 'single_entity': True}) %}
{% endif -%}

{% if var('snowplow__enable_application_context', false) -%}
  {% do contexts.append({'schema': var('snowplow__application_context'), 'prefix': 'app_con', 'single_entity': True}) %}
{% endif -%}

{% if var('snowplow__enable_screen_context', false) -%}
  {% do contexts.append({'schema': var('snowplow__screen_context'), 'prefix': 'screen_con', 'single_entity': True}) %}
{% endif -%}

{% if var('snowplow__enable_app_errors_module', false) -%}
  {% do contexts.append({'schema': var('snowplow__application_error_events'), 'prefix': 'app_err_con', 'single_entity': True}) %}
{% endif -%}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
    sessions_this_run_table='snowplow_mobile_base_sessions_this_run',
    session_identifiers=session_identifiers(),
    session_sql=var('snowplow__session_sql', none),
    session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
    derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
    days_late_allowed=var('snowplow__days_late_allowed', 3),
    max_session_days=var('snowplow__max_session_days', 3),
    app_ids=var('snowplow__app_id', []),
    snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
    snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
    snowplow_events_table=var('snowplow__events_table', 'events'),
    entities_or_sdes=contexts,
    custom_sql=var('snowplow__custom_sql', '')) %}

{% set final_query %}
with base_query as (
  {{ base_events_query }}
), final as (
  select
  -- session context
  e.sc_session_id as session_id,
  e.sc_session_index as session_index,
  e.sc_previous_session_id as previous_session_id,
  e.sc_user_id as device_user_id,
  e.sc_first_event_id as session_first_event_id,
  e.sc_event_index as session_event_index,
  e.sc_storage_mechanism as session_storage_mechanism,
  e.sc_first_event_timestamp as session_first_event_timestamp,
  -- screen context
  {% if var("snowplow__enable_screen_context", false) %}
    e.screen_con_screen_id as screen_id, --could rename to screen_view_id and coalesce with screen view events,
    e.screen_con_screen_name as screen_name,
    e.screen_con_screen_activity as screen_activity,
    e.screen_con_screen_fragment as screen_fragment,
    e.screen_con_screen_top_view_controller as screen_top_view_controller,
    e.screen_con_screen_type as screen_type,
    e.screen_con_screen_view_controller as screen_view_controller,
  {% else %}
    cast(null as {{ type_string() }}) as screen_id, --could rename to screen_view_id and coalesce with screen view events.
    cast(null as {{ type_string() }}) as screen_name,
    cast(null as {{ type_string() }}) as screen_activity,
    cast(null as {{ type_string() }}) as screen_fragment,
    cast(null as {{ type_string() }}) as screen_top_view_controller,
    cast(null as {{ type_string() }}) as screen_type,
    cast(null as {{ type_string() }}) as screen_view_controller,
  {% endif %}
  -- mobile context
  {% if var("snowplow__enable_mobile_context", false) %}
    e.mobile_con_device_manufacturer as device_manufacturer,
    e.mobile_con_device_model as device_model,
    e.mobile_con_os_type as os_type,
    e.mobile_con_os_version as os_version,
    e.mobile_con_android_idfa as android_idfa,
    e.mobile_con_apple_idfa as apple_idfa,
    e.mobile_con_apple_idfv as apple_idfv,
    e.mobile_con_carrier as carrier,
    e.mobile_con_open_idfa as open_idfa,
    e.mobile_con_network_technology as network_technology,
    e.mobile_con_network_type as network_type,
  {% else %}
    cast(null as {{ type_string() }}) as device_manufacturer,
    cast(null as {{ type_string() }}) as device_model,
    cast(null as {{ type_string() }}) as os_type,
    cast(null as {{ type_string() }}) as os_version,
    cast(null as {{ type_string() }}) as android_idfa,
    cast(null as {{ type_string() }}) as apple_idfa,
    cast(null as {{ type_string() }}) as apple_idfv,
    cast(null as {{ type_string() }}) as carrier,
    cast(null as {{ type_string() }}) as open_idfa,
    cast(null as {{ type_string() }}) as network_technology,
    cast(null as {{ type_string() }}) as network_type,
  {% endif %}
  -- geo context
  {% if var("snowplow__enable_geolocation_context", false) %}
    e.geo_con_latitude as device_latitude,
    e.geo_con_longitude as device_longitude,
    e.geo_con_latitude_longitude_accuracy as device_latitude_longitude_accuracy,
    e.geo_con_altitude as device_altitude,
    e.geo_con_altitude_accuracy as device_altitude_accuracy,
    e.geo_con_bearing as device_bearing,
    e.geo_con_speed as device_speed,
  {% else %}
    cast(null as {{ type_float() }}) as device_latitude,
    cast(null as {{ type_float() }}) as device_longitude,
    cast(null as {{ type_float() }}) as device_latitude_longitude_accuracy,
    cast(null as {{ type_float() }}) as device_altitude,
    cast(null as {{ type_float() }}) as device_altitude_accuracy,
    cast(null as {{ type_float() }}) as device_bearing,
    cast(null as {{ type_float() }}) as device_speed,
  {% endif %}
  -- app context
  {% if var("snowplow__enable_application_context", false) %}
    e.app_con_build as build,
    e.app_con_version as version,
  {% else %}
    cast(null as {{ type_string() }}) as build,
    cast(null as {{ type_string() }}) as version,
  {% endif %}

  e.*

  from base_query e
)
select * from final
{% endset %}
{% set query_cols = get_column_schema_from_query(final_query) %}

with final as (
  {{ final_query }}
)
select
  {% for col in query_cols | map(attribute='name') | list -%}
    {% if col == 'session_identifier' -%}
      f.session_identifier as session_id,
      f.session_identifier as session_identifier
    {%- elif col == 'session_id' -%}
      f.session_id as original_session_id
    {%- elif col == 'user_identifier' -%}
      f.user_identifier as device_user_id,
      f.user_identifier as user_identifier
    {%- elif col == 'device_user_id' -%}
      f.device_user_id as original_device_user_id
    {%- else -%}
      f.{{col}}
    {%- endif -%}
    {%- if not loop.last -%},{%- endif %}
  {% endfor %}

  , row_number() over(partition by f.session_identifier order by derived_tstamp) as event_index_in_session


from final f
