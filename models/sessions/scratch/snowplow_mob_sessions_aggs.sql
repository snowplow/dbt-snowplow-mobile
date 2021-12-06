{{ 
  config(
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["session_id"]),
    sort='session_id',
    dist='session_id'
  ) 
}}

with events as (
 select
      es.session_id,
      es.event_id,
      es.event_name,
      es.derived_tstamp,
      es.build,
      es.version,
      es.event_index_in_session,
      MAX(es.event_index_in_session) over (partition by es.session_id) as events_in_session

    from {{ ref('snowplow_mob_base_events_this_run') }}   es
)

, session_aggs AS (
    select
      e.session_id,
      --last dimensions
      MAX(case when e.event_index_in_session = e.events_in_session then e.build end) as last_build,
      MAX(case when e.event_index_in_session = e.events_in_session then e.version end) as last_version,
      MAX(case when e.event_index_in_session = e.events_in_session then e.event_name end) as last_event_name,
      MAX(case when e.event_index_in_session = e.events_in_session then e.event_id end) as session_last_event_id,
      -- time
      MIN(e.derived_tstamp) as start_tstamp,
      MAX(e.derived_tstamp) as end_tstamp,
      LOGICAL_OR(e.event_name = 'application_install') has_install

    from
      events e

    group by 1
    )

, app_errors as (
    select
      ae.session_id,
      COUNT(distinct ae.event_id) AS app_errors,
      COUNT(distinct case when ae.is_fatal then ae.event_id end) as fatal_app_errors

    from {{ ref('snowplow_mob_app_errors_this_run') }} ae

    group by 1
    )


    select
    sa.session_id,
    sa.last_build,
    sa.last_version,
    sa.last_event_name,
    sa.session_last_event_id,
    sa.start_tstamp,
    sa.end_tstamp,
    TIMESTAMP_DIFF(sa.end_tstamp, sa.start_tstamp, SECOND) session_duration_s,
    sa.has_install,
    ae.app_errors,
    ae.fatal_app_errors

  from
    session_aggs sa
  left join
    {{ ref('snowplow_mob_app_errors_this_run') }} ae
  on sa.session_id = ae.session_id  