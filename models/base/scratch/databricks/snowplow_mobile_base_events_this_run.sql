{{
  config(
    tags=["this_run"]
  )
}}

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
    snowplow_events_table=var('snowplow__events_table', 'events')
)%}

with base_query as (
  {{ base_events_query }}
), final as (
  select
    -- screen view events
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.id::STRING AS screen_view_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.name::STRING AS screen_view_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_id::STRING AS screen_view_previous_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_name::STRING AS screen_view_previous_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.previous_type::STRING AS screen_view_previous_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.transition_type::STRING AS screen_view_transition_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1.type::STRING AS screen_view_type,
    -- screen context
    {% if var('snowplow__enable_screen_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].id::STRING AS screen_id,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].name::STRING AS screen_name,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].activity::STRING AS screen_activity,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].fragment::STRING AS screen_fragment,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].top_view_controller::STRING AS screen_top_view_controller,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].type::STRING AS screen_type,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0].view_controller::STRING AS screen_view_controller,
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
    {% if var('snowplow__enable_mobile_context', false) %}
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_manufacturer::STRING AS device_manufacturer,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].device_model::STRING AS device_model,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_type::STRING AS os_type,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].os_version::STRING AS os_version,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].android_idfa::STRING AS android_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfa::STRING AS apple_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].apple_idfv::STRING AS apple_idfv,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].carrier::STRING AS carrier,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].open_idfa::STRING AS open_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_technology::STRING AS network_technology,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0].network_type::STRING AS network_type,
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
    {% if var('snowplow__enable_geolocation_context', false) %}
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude::FLOAT AS device_latitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].longitude::FLOAT AS device_longitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].latitude_longitude_accuracy::FLOAT AS device_latitude_longitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude::FLOAT AS device_altitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].altitude_accuracy::FLOAT AS device_altitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].bearing::FLOAT AS device_bearing,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0].speed::FLOAT AS device_speed,
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
    {% if var('snowplow__enable_application_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_application_1[0].build::STRING AS build,
      a.contexts_com_snowplowanalytics_mobile_application_1[0].version::STRING AS version,
    {% else %}
      cast(null as {{ type_string() }}) as build,
      cast(null as {{ type_string() }}) as version,
    {% endif %}
    -- session context
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_id::STRING AS session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].session_index::INT AS session_index,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].previous_session_id::STRING AS previous_session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].user_id::STRING AS device_user_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0].first_event_id::STRING AS session_first_event_id,
    -- select all fields in case of future additions to context schemas
    a.*

    from base_query a
)

select
  session_identifier as session_id,
  session_id as original_session_id,
  user_identifier as device_user_id,
  device_user_id as original_device_user_id,
  f.* except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1, session_id, device_user_id),

  row_number() over(partition by session_id order by derived_tstamp) as event_index_in_session

from final f
