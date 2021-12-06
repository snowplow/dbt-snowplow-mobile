{{ 
  config(
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["device_user_id"]),
    sort='device_user_id',
    dist='device_user_id'
  ) 
}}

select
  device_user_id,

   -- time
  user_start_tstamp as start_tstamp,
  user_end_tstamp as end_tstamp,

  last_screen_view_name,
  last_screen_view_transition_type,
  last_screen_view_type,
  carrier AS last_carrier,
  os_version AS last_os_version,

   -- first/last session. Max to resolve edge case with multiple sessions with the same start/end tstamp
  max(case when start_tstamp = user_start_tstamp then session_id end) as first_session_id,
  max(case when end_tstamp = user_end_tstamp then session_id end) as last_session_id,
     -- engagement
  sum(screen_views) as screen_views,
  count(distinct session_id) as sessions,
  sum(session_duration_s) as session_duration_s

from {{ ref('snowplow_mob_users_sessions_this_run') }}

group by 1,2,3