{{ 
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='event_id',
    upsert_date_key='derived_tstamp',
    sort='derived_tstamp',
    dist='event_id',
    partition_by = {
      "field": "derived_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_mobile.cluster_by_fields_app_errors(),
    tags=["derived"],
    enabled=var("snowplow__enable_app_errors_module", false),
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  ) 
}}


select * 
from {{ ref('snowplow_mobile_app_errors_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
