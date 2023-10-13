{{
  config(
    tags=["this_run"]
  )
}}

{% set base_events_query = snowplow_utils.base_create_snowplow_events_this_run(
    sessions_this_run_table='snowplow_mobile_base_sessions_this_run',
    session_identifiers=var('snowplow__session_identifiers', [{"schema" : var('snowplow__session_context'), "field" : "session_id"}]),
    session_sql=var('snowplow__session_sql', none),
    session_timestamp=var('snowplow__session_timestamp', 'collector_tstamp'),
    derived_tstamp_partitioned=var('snowplow__derived_tstamp_partitioned', true),
    days_late_allowed=var('snowplow__days_late_allowed', 3),
    max_session_days=var('snowplow__max_session_days', 3),
    app_ids=var('snowplow__app_id', []),
    snowplow_events_database=var('snowplow__database', target.database) if target.type not in ['databricks', 'spark'] else var('snowplow__databricks_catalog', 'hive_metastore') if target.type in ['databricks'] else var('snowplow__atomic_schema', 'atomic'),
    snowplow_events_schema=var('snowplow__atomic_schema', 'atomic'),
    snowplow_events_table=var('snowplow__events_table', 'events'),
    custom_sql=var('snowplow__custom_sql', '')
)%}

with base_query as (
  {{ base_events_query }}
), final as (
  select
    -- screen view events
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:id::varchar(36) AS screen_view_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:name::varchar AS screen_view_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousId::varchar(36) AS screen_view_previous_id,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousName::varchar AS screen_view_previous_name,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:previousType::varchar AS screen_view_previous_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:transitionType::varchar AS screen_view_transition_type,
    a.unstruct_event_com_snowplowanalytics_mobile_screen_view_1:type::varchar AS screen_view_type,
    -- screen context
    {% if var('snowplow__enable_screen_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:id::varchar(36) AS screen_id,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:name::varchar AS screen_name,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:activity::varchar AS screen_activity,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:fragment::varchar AS screen_fragment,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:topViewController::varchar AS screen_top_view_controller,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:type::varchar AS screen_type,
      a.contexts_com_snowplowanalytics_mobile_screen_1[0]:viewController::varchar AS screen_view_controller,
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
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceManufacturer::varchar AS device_manufacturer,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:deviceModel::varchar AS device_model,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osType::varchar AS os_type,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:osVersion::varchar AS os_version,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:androidIdfa::varchar AS android_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfa::varchar AS apple_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:appleIdfv::varchar AS apple_idfv,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:carrier::varchar AS carrier,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:openIdfa::varchar AS open_idfa,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkTechnology::varchar AS network_technology,
      a.contexts_com_snowplowanalytics_snowplow_mobile_context_1[0]:networkType::varchar(255) AS network_type,
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
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitude::float AS device_latitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:longitude::float AS device_longitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:latitudeLongitudeAccuracy::float AS device_latitude_longitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitude::float AS device_altitude,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:altitudeAccuracy::float AS device_altitude_accuracy,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:bearing::float AS device_bearing,
      a.contexts_com_snowplowanalytics_snowplow_geolocation_context_1[0]:speed::float AS device_speed,
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
      a.contexts_com_snowplowanalytics_mobile_application_1[0]:build::varchar(255) AS build,
      a.contexts_com_snowplowanalytics_mobile_application_1[0]:version::varchar(255) AS version,
    {% else %}
      cast(null as {{ type_string() }}) as build,
      cast(null as {{ type_string() }}) as version,
    {% endif %}
    -- session context
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionId::varchar(36) AS session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionIndex::int AS session_index,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previousSessionId::varchar(36) AS previous_session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:userId::varchar(36) AS device_user_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventId::varchar(36) AS session_first_event_id,
    a.*

  from base_query a
)

select
  a.session_identifier as session_id,
  a.session_id as original_session_id,
  a.user_identifier as device_user_id,
  a.device_user_id as original_device_user_id,
  a.* exclude(unstruct_event_com_snowplowanalytics_mobile_screen_view_1, session_id, device_user_id),

  row_number() over(partition by session_identifier order by derived_tstamp) as event_index_in_session

from final a
