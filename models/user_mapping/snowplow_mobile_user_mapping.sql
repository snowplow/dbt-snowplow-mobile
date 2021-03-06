{{
  config(
    materialized='incremental',
    unique_key='device_user_id',
    sort='end_tstamp',
    dist='device_user_id',
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
      "field": "end_tstamp",
      "data_type": "timestamp"
    }),
    tags=["derived"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}


select distinct
  device_user_id,
  last_value(user_id) over(
    partition by device_user_id
    order by collector_tstamp
    rows between unbounded preceding and unbounded following
  ) as user_id,
  max(collector_tstamp) over (partition by device_user_id) as end_tstamp

from {{ ref('snowplow_mobile_base_events_this_run') }}

where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
and user_id is not null
and device_user_id is not null
