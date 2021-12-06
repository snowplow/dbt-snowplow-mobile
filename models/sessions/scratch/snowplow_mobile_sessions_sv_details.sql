{{ 
  config(
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["session_id"]),
    sort='session_id',
    dist='session_id'
  ) 
}}

select
  sv.session_id,
  COUNT(distinct sv.screen_view_id) as screen_views,
  COUNT(distinct sv.screen_view_name) as screen_names_viewed,
  --Could split below into first/last scratch tables. Trying to minimise joins to sessions.
  MAX(case when sv.screen_view_in_session_index = 1 then sv.screen_view_name end) as first_screen_view_name,
  MAX(case when sv.screen_view_in_session_index = 1 then sv.screen_view_transition_type end) as first_screen_view_transition_type,
  MAX(case when sv.screen_view_in_session_index = 1 then sv.screen_view_type end) as first_screen_view_type,
  MAX(case when sv.screen_view_in_session_index = sv.screen_views_in_session then sv.screen_view_name end) as last_screen_view_name,
  MAX(case when sv.screen_view_in_session_index = sv.screen_views_in_session then sv.screen_view_transition_type end) as last_screen_view_transition_type,
  MAX(case when sv.screen_view_in_session_index = sv.screen_views_in_session then sv.screen_view_type end) as last_screen_view_type

from {{ ref('snowplow_mobile_screen_views_this_run') }} sv

group by 1
