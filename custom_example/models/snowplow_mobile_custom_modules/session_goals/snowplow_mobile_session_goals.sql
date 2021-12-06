{{ 
  config(
    unique_key='session_id',
    sort='max_tstamp',
    dist='session_id',
    cluster_by=snowplow_mobile.cluster_by_fields_sessions(),
    upsert_date_key='max_tstamp',
    materialized='snowplow_incremental',
    tags=["derived"]
  ) 
}}


select * 
from {{ ref('snowplow_mobile_session_goals_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
