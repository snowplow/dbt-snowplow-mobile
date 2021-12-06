{{ 
  config(materialized='table') 
}}

select
  min(s.start_tstamp) as lower_limit,
  max(s.end_tstamp) as upper_limit

from {{ ref('snowplow_mob_base_sessions_this_run') }} s
