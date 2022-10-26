{{
  config(
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
      "field": "start_tstamp",
      "data_type": "timestamp"
    }),
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["session_id"]),
    sort='session_id',
    dist='session_id',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
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

  from {{ ref('snowplow_mobile_base_events_this_run') }}   es
)

, session_aggs AS (
  select
    e.session_id,
    --last dimensions
    MAX(case when e.event_index_in_session = e.events_in_session then e.build end) as last_build,
    MAX(case when e.event_index_in_session = e.events_in_session then e.version end) as last_version,
    MAX(case when e.event_index_in_session = e.events_in_session then e.event_name end) as last_event_name,
    {% if target.type == 'postgres' %}
      cast(MAX(case when e.event_index_in_session = e.events_in_session then cast(e.event_id as {{ type_string() }}) end) as uuid) as session_last_event_id,
    {% else %}
      MAX(case when e.event_index_in_session = e.events_in_session then e.event_id end) as session_last_event_id,
    {% endif %}

    -- time
    MIN(e.derived_tstamp) as start_tstamp,
    MAX(e.derived_tstamp) as end_tstamp,
    {{ snowplow_mobile.bool_or("e.event_name = 'application_install'") }} as has_install

  from events e

  group by 1
)

, app_errors as (
  {% if var("snowplow__enable_app_errors_module", false) %}
    select
      ae.session_id,
      COUNT(distinct ae.event_id) AS app_errors,
      COUNT(distinct case when ae.is_fatal then ae.event_id end) as fatal_app_errors

    from {{ ref('snowplow_mobile_app_errors_this_run') }} ae

    group by 1
  {% else %}
    select
      {% if target.type == 'postgres' %}
        cast(null as uuid) as session_id,
      {% else %}
        cast(null as {{type_string() }}) as session_id,
      {% endif %}
      cast(null as {{ type_int() }}) as app_errors,
      cast(null as {{ type_int() }}) as fatal_app_errors
  {% endif %}
)


select
  sa.session_id,
  sa.last_build,
  sa.last_version,
  sa.last_event_name,
  sa.session_last_event_id,
  sa.start_tstamp,
  sa.end_tstamp,
  {{ snowplow_utils.timestamp_diff('sa.start_tstamp', 'sa.end_tstamp', 'second') }} as session_duration_s,
  sa.has_install,
  ae.app_errors,
  ae.fatal_app_errors

from session_aggs sa
left join app_errors ae
on sa.session_id = ae.session_id
