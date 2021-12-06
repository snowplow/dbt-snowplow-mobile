
with prep as (
  select 
    session_id, 
    count(distinct screen_views_in_session) as dist_svis_values,
    count(*) - count(distinct screen_view_in_session_index)  as all_minus_dist_svisi,
    count(*) - count(distinct screen_view_id) as all_minus_dist_svids 

  from {{ ref('snowplow_mobile_screen_views') }}
  group by 1
)

select
  session_id

from prep

where dist_svis_values != 1
or all_minus_dist_svisi != 0
or all_minus_dist_svids != 0
