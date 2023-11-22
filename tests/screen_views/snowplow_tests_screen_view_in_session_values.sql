{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}


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
