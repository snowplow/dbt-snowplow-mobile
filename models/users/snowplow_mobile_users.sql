{{ 
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='device_user_id',
    upsert_date_key='start_tstamp',
    disable_upsert_lookback=true,
    sort='start_tstamp',
    dist='device_user_id',
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_mobile.cluster_by_fields_users(),
    tags=["derived"]
  ) 
}}

select * 
from {{ ref('snowplow_mobile_users_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
