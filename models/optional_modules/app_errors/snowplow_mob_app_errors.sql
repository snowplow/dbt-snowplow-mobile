{{ 
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='screen_view_id',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='screen_view_id',
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=cluster_by_fields_screen_views(),
    tags=["derived"]
  ) 
}}


select * 
from {{ ref('snowplow_mob_app_errors_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mob') }} --returns false if run doesn't contain new events.
