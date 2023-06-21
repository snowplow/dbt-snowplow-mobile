{{
  config(
    tags=["this_run"]
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(ref('snowplow_mobile_base_sessions_this_run'),
                                                                          'start_tstamp',
                                                                          'end_tstamp') %}

{% set session_id = snowplow_mobile.get_session_id_path_sql(relation_alias='a') %}

with events as (
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

  from {{ var('snowplow__events') }} as a
  inner join {{ ref('snowplow_mobile_base_sessions_this_run') }} as b
  on {{ session_id }} = b.session_id

  where a.collector_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'b.start_tstamp') }}
  and a.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'a.dvce_created_tstamp') }}
  and a.collector_tstamp >= {{ lower_limit }}
  and a.collector_tstamp <= {{ upper_limit }}
  {% if var('snowplow__derived_tstamp_partitioned', true) and target.type == 'bigquery' | as_bool() %} -- BQ only
    and a.derived_tstamp >= {{ snowplow_utils.timestamp_add('hour', -1, lower_limit) }}
    and a.derived_tstamp <= {{ upper_limit }}
  {% endif %}
  and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
  and a.platform in ('{{ var("snowplow__platform")|join("','") }}') -- filters for 'mob' by default
)

, deduped_events as (
  -- without downstream joins, it's safe to dedupe by picking the first event_id found.
  select
    array_agg(e order by e.collector_tstamp limit 1)[offset(0)].*

  from events as e

  group by e.event_id
)

select
  d.*,
  row_number() over(partition by d.session_id order by d.derived_tstamp) as event_index_in_session

from deduped_events as d
