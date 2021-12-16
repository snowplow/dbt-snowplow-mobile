{{ 
  config(
    materialized='table',
    partition_by = {
      "field": "start_tstamp",
      "data_type": "timestamp"
    },
    cluster_by=snowplow_utils.get_cluster_by(bigquery_cols=["device_user_id"]),
    sort='start_tstamp',
    dist='device_user_id',
    tags=["this_run"]
  ) 
}}

 
with user_ids_this_run as (
select distinct device_user_id from {{ ref('snowplow_mob_base_sessions_this_run') }}
)


select
  a.*,
  min(a.start_tstamp) over(partition by a.device_user_id) as user_start_tstamp,
  max(a.end_tstamp) over(partition by a.device_user_id) as user_end_tstamp 

from {{ var('snowplow__sessions_table') }} a
inner join user_ids_this_run b
on a.device_user_id = b.device_user_id