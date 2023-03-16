{{
  config(
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
       "field": "start_tstamp",
       "data_type": "timestamp"
     }),
    cluster_by=snowplow_utils.get_value_by_target_type(bigquery_val=["device_user_id"]),
    sort='device_user_id',
    dist='device_user_id',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  device_user_id,
   -- time
  user_start_tstamp as start_tstamp,
  user_end_tstamp as end_tstamp,
  -- first/last session. Max to resolve edge case with multiple sessions with the same start/end tstamp
  {% if target.type == 'postgres' %}
    cast(max(case when start_tstamp = user_start_tstamp then cast(session_id as {{ type_string() }} ) end) as uuid) as first_session_id,
    cast(max(case when end_tstamp = user_end_tstamp then cast(session_id as {{ type_string() }} ) end) as uuid) as last_session_id,
  {% else %}
    max(case when start_tstamp = user_start_tstamp then session_id end) as first_session_id,
    max(case when end_tstamp = user_end_tstamp then session_id end) as last_session_id,
  {% endif %}
  -- engagement
  sum(screen_views) as screen_views,
  sum(screen_names_viewed) as screen_names_viewed,
  count(distinct session_id) as sessions,
  sum(session_duration_s) as sessions_duration_s,
  count(distinct {{ date_trunc('day', 'start_tstamp') }}) as active_days,

  sum(app_errors) as app_errors,
  sum(fatal_app_errors) as fatal_app_errors

from {{ ref('snowplow_mobile_users_sessions_this_run') }}

group by 1,2,3
