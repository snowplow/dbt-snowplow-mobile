{{ 
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='screen_view_id',
    upsert_date_key='derived_tstamp',
    sort='derived_tstamp',
    dist='screen_view_id',
    partition_by = {
      "field": "derived_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_mobile.cluster_by_fields_screen_views(),
    tags=["derived"]
  ) 
}}


select * 
from {{ ref('snowplow_mobile_screen_views_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
