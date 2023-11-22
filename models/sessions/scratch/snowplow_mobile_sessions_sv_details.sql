{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    cluster_by=snowplow_utils.get_value_by_target_type(bigquery_val=["session_id"]),
    sort='session_id',
    dist='session_id',
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
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
