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
    snowplow_events_table=var('snowplow__events_table', 'events')
)%}

with base_query as (
  {{ base_events_query }}
), prep as (

  select
    -- screen view events
    {{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='unstruct_event_com_snowplowanalytics_mobile_screen_view_1_',
          fields=screen_view_event_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    -- screen context
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_screen_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_screen_1_',
          fields=screen_context_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    -- mobile context
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_mobile_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_mobile_context_1_',
          fields=mobile_context_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    -- geo context
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_geolocation_context', false),
          col_prefix='contexts_com_snowplowanalytics_snowplow_geolocation_context_1_',
          fields=geo_context_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    -- app context
    {{ snowplow_utils.get_optional_fields(
          enabled=var('snowplow__enable_application_context', false),
          col_prefix='contexts_com_snowplowanalytics_mobile_application_1_',
          fields=app_context_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    -- session context
    {{ snowplow_utils.get_optional_fields(
          enabled=true,
          col_prefix='contexts_com_snowplowanalytics_snowplow_client_session_1_',
          fields=session_context_fields(),
          relation=source('atomic','events'),
          relation_alias='a') }},
    a.*

  from base_query a
)
select
  * except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0, session_id, device_user_id),
  session_identifier as session_id,
  session_id as original_session_id,
  user_identifier as device_user_id,
  device_user_id as original_device_user_id,
  row_number() over(partition by session_id order by derived_tstamp) as event_index_in_session

from prep
