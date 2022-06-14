{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='session_id',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='session_id',
    full_refresh=snowplow_mobile.allow_refresh(),
    tags=["manifest"]
  )
}}

{% set lower_limit, upper_limit, _ = snowplow_utils.return_base_new_event_limits(ref('snowplow_mobile_base_new_event_limits')) %}
{% set session_lookback_limit = snowplow_utils.get_session_lookback_limit(lower_limit) %}
{% set is_run_with_new_events = snowplow_utils.is_run_with_new_events('snowplow_mobile') %}

with session_context as (
  select
    s.root_id,
    s.root_tstamp,
    s.session_id,
    s.user_id as device_user_id

  from {{ var('snowplow__session_context') }} s
  where s.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
)

, new_events_session_ids as (
  select
    sc.session_id,
    max(sc.device_user_id) as device_user_id,
    min(e.collector_tstamp) as start_tstamp,
    max(e.collector_tstamp) as end_tstamp

  from {{ var('snowplow__events') }} e
  inner join session_context sc
  on e.event_id = sc.root_id
  and e.collector_tstamp = sc.root_tstamp

  where
    sc.session_id is not null
    and e.dvce_sent_tstamp <= {{ snowplow_utils.timestamp_add('day', var("snowplow__days_late_allowed", 3), 'dvce_created_tstamp') }} -- don't process data that's too late
    and e.collector_tstamp >= {{ lower_limit }}
    and e.collector_tstamp <= {{ upper_limit }}
    and {{ snowplow_utils.app_id_filter(var("snowplow__app_id",[])) }}
    and e.platform in ('{{ var("snowplow__platform")|join("','") }}') -- filters for 'mob' by default
    and {{ is_run_with_new_events }} --don't reprocess sessions that have already been processed.

  group by 1
  )

{% if snowplow_utils.snowplow_is_incremental() %}

, previous_sessions as (
  select *

  from {{ this }}

  where start_tstamp >= {{ session_lookback_limit }}
  and {{ is_run_with_new_events }} --don't reprocess sessions that have already been processed.
)

, session_lifecycle as (
  select
    ns.session_id,
    ns.device_user_id,
    least(ns.start_tstamp, coalesce(self.start_tstamp, ns.start_tstamp)) as start_tstamp,
    greatest(ns.end_tstamp, coalesce(self.end_tstamp, ns.end_tstamp)) as end_tstamp -- BQ 1 NULL will return null hence coalesce

  from new_events_session_ids ns
  left join previous_sessions as self
    on ns.session_id = self.session_id

  where
    self.session_id is null -- process all new sessions
    or self.end_tstamp < {{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'self.start_tstamp') }} --stop updating sessions exceeding 3 days
  )

{% else %}

, session_lifecycle as (

  select * from new_events_session_ids

)

{% endif %}

select
  sl.session_id,
  sl.device_user_id,
  sl.start_tstamp,
  least({{ snowplow_utils.timestamp_add('day', var("snowplow__max_session_days", 3), 'sl.start_tstamp') }}, sl.end_tstamp) as end_tstamp -- limit session length to max_session_days

from session_lifecycle sl
