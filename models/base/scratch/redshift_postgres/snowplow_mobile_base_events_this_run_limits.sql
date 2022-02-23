select
  min(s.start_tstamp) as lower_limit,
  max(s.end_tstamp) as upper_limit

from {{ ref('snowplow_mobile_base_sessions_this_run') }} s
