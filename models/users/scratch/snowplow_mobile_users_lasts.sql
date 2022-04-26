{{ 
  config(
    sort='device_user_id',
    dist='device_user_id',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  ) 
}}

select
  a.device_user_id,
  a.last_screen_view_name,
  a.last_screen_view_transition_type,
  a.last_screen_view_type,

  a.carrier AS last_carrier,
  a.os_version AS last_os_version

from {{ ref('snowplow_mobile_users_sessions_this_run') }} a

inner join {{ ref('snowplow_mobile_users_aggs') }} b
on a.session_id = b.last_session_id
