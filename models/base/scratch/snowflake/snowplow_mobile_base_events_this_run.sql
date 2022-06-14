{{
  config(
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_mobile_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}

{% set session_id = snowplow_mobile.get_session_id_path_sql(relation_alias='a') %}

with events as (
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
      cast(null as {{ dbt_utils.type_string() }}) as screen_id, --could rename to screen_view_id and coalesce with screen view events.
      cast(null as {{ dbt_utils.type_string() }}) as screen_name,
      cast(null as {{ dbt_utils.type_string() }}) as screen_activity,
      cast(null as {{ dbt_utils.type_string() }}) as screen_fragment,
      cast(null as {{ dbt_utils.type_string() }}) as screen_top_view_controller,
      cast(null as {{ dbt_utils.type_string() }}) as screen_type,
      cast(null as {{ dbt_utils.type_string() }}) as screen_view_controller,
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
      cast(null as {{ dbt_utils.type_string() }}) as device_manufacturer,
      cast(null as {{ dbt_utils.type_string() }}) as device_model,
      cast(null as {{ dbt_utils.type_string() }}) as os_type,
      cast(null as {{ dbt_utils.type_string() }}) as os_version,
      cast(null as {{ dbt_utils.type_string() }}) as android_idfa,
      cast(null as {{ dbt_utils.type_string() }}) as apple_idfa,
      cast(null as {{ dbt_utils.type_string() }}) as apple_idfv,
      cast(null as {{ dbt_utils.type_string() }}) as carrier,
      cast(null as {{ dbt_utils.type_string() }}) as open_idfa,
      cast(null as {{ dbt_utils.type_string() }}) as network_technology,
      cast(null as {{ dbt_utils.type_string() }}) as network_type,
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
      cast(null as {{ dbt_utils.type_float() }}) as device_latitude,
      cast(null as {{ dbt_utils.type_float() }}) as device_longitude,
      cast(null as {{ dbt_utils.type_float() }}) as device_latitude_longitude_accuracy,
      cast(null as {{ dbt_utils.type_float() }}) as device_altitude,
      cast(null as {{ dbt_utils.type_float() }}) as device_altitude_accuracy,
      cast(null as {{ dbt_utils.type_float() }}) as device_bearing,
      cast(null as {{ dbt_utils.type_float() }}) as device_speed,
    {% endif %}
    -- app context
    {% if var('snowplow__enable_application_context', false) %}
      a.contexts_com_snowplowanalytics_mobile_application_1[0]:build::varchar(255) AS build,
      a.contexts_com_snowplowanalytics_mobile_application_1[0]:version::varchar(255) AS version,
    {% else %}
      cast(null as {{ dbt_utils.type_string() }}) as build,
      cast(null as {{ dbt_utils.type_string() }}) as version,
    {% endif %}
    -- session context
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionId::varchar(36) AS session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:sessionIndex::int AS session_index,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:previousSessionId::varchar(36) AS previous_session_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:userId::varchar(36) AS device_user_id,
    a.contexts_com_snowplowanalytics_snowplow_client_session_1[0]:firstEventId::varchar(36) AS session_first_event_id,
    -- select all from events except non-mobile fields.
    a.*

  from {{ var('snowplow__events') }} as a
  inner join {{ ref('snowplow_mobile_base_sessions_this_run') }} as b
  on {{ session_id }} = b.session_id

  where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
  and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
  and a.collector_tstamp >= {{ lower_limit }}
  and a.collector_tstamp <= {{ upper_limit }}
  and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
  and a.platform in ('{{ var("snowplow__platform")|join("','") }}') -- filters for 'mob' by default
)

, deduped_events AS (
  select
    e.*

  from events e

  qualify row_number() over (partition by e.event_id order by e.collector_tstamp) = 1
)

select
  d.*,
  row_number() over(partition by d.session_id order by d.derived_tstamp) as event_index_in_session

from deduped_events as d
