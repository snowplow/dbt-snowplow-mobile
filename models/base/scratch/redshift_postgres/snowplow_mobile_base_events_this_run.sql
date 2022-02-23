{{ 
  config(
    sort='collector_tstamp',
    dist='event_id',
    tags=["this_run"]
  ) 
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_mobile_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}

/* Dedupe logic: Per dupe event_id keep earliest row ordered by collector_tstamp.
   If multiple earliest rows, i.e. matching collector_tstamp, remove entirely. */

with events_this_run AS (
  select
    sc.session_id,
    sc.session_index,
    sc.previous_session_id,
    sc.device_user_id,
    sc.session_first_event_id,
    
    e.*,
    dense_rank() over (partition by e.event_id order by e.collector_tstamp) as event_id_dedupe_index --dense_rank so rows with equal tstamps assigned same #

  from {{ source('atomic', 'events') }} e
  inner join {{ ref('snowplow_mobile_base_session_context') }} sc
  on e.event_id = sc.root_id
  and e.collector_tstamp = sc.root_tstamp
  inner join {{ ref('snowplow_mobile_base_sessions_this_run') }} str
  on sc.session_id = str.session_id

  where {{ snowplow_utils.timestamp_diff('e.collector_tstamp', 'str.start_tstamp', 'day')}} <= {{ var("snowplow__max_session_days", 3) }}
  and {{ snowplow_utils.timestamp_diff('e.dvce_created_tstamp', 'e.dvce_sent_tstamp', 'day') }} <= {{ var("snowplow__days_late_allowed", 3) }}
  and e.collector_tstamp >= {{ lower_limit }}
  and e.collector_tstamp <= {{ upper_limit }}
  and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
  and e.platform in ('{{ var("snowplow__platform")|join("','") }}') -- filters for 'mob' by default
)

, events_dedupe as (
  select
    *,
    count(*) over(partition by e.event_id) as row_count

  from events_this_run e
  
  where e.event_id_dedupe_index = 1 -- Keep row(s) with earliest collector_tstamp per dupe event
)

, cleaned_events as (
  select *
  from events_dedupe
  where row_count = 1 -- Only keep dupes with single row per earliest collector_tstamp
)

select
  -- screen context
  {% if var("snowplow__enable_screen_context", false) %}
    sc.screen_id,
    sc.screen_name,
    sc.screen_activity,
    sc.screen_fragment,
    sc.screen_top_view_controller,
    sc.screen_type,
    sc.screen_view_controller,
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
  {% if var("snowplow__enable_mobile_context", false) %}
    mc.device_manufacturer,
    mc.device_model,
    mc.os_type,
    mc.os_version,
    mc.android_idfa,
    mc.apple_idfa,
    mc.apple_idfv,
    mc.carrier,
    mc.open_idfa,
    mc.network_technology,
    mc.network_type,
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
  {% if var("snowplow__enable_geolocation_context", false) %}
    gc.device_latitude,
    gc.device_longitude,
    gc.device_latitude_longitude_accuracy,
    gc.device_altitude,
    gc.device_altitude_accuracy,
    gc.device_bearing,
    gc.device_speed,
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
  {% if var("snowplow__enable_application_context", false) %}
    ac.build,
    ac.version,
  {% else %}
    cast(null as {{ dbt_utils.type_string() }}) as build,
    cast(null as {{ dbt_utils.type_string() }}) as version,
  {% endif %}
  e.*,
  row_number() over(partition by e.session_id order by e.derived_tstamp) as event_index_in_session

from cleaned_events e

{% if var("snowplow__enable_screen_context", false) %}
  left join {{ ref('snowplow_mobile_base_screen_context') }} sc
  on e.event_id = sc.root_id
  and e.collector_tstamp = sc.root_tstamp
{% endif %}

{% if var("snowplow__enable_mobile_context", false) %}
  left join {{ ref('snowplow_mobile_base_mobile_context') }} mc
  on e.event_id = mc.root_id
  and e.collector_tstamp = mc.root_tstamp
{% endif %}

{% if var("snowplow__enable_geolocation_context", false) %}
  left join {{ ref('snowplow_mobile_base_geo_context') }} gc
  on e.event_id = gc.root_id
  and e.collector_tstamp = gc.root_tstamp
{% endif %}

{% if var("snowplow__enable_application_context", false) %}
  left join {{ ref('snowplow_mobile_base_app_context') }} ac
  on e.event_id = ac.root_id
  and e.collector_tstamp = ac.root_tstamp
{% endif %}
