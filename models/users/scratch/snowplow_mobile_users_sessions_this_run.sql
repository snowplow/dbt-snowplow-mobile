{{
  config(
    sort='start_tstamp',
    dist='device_user_id',
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

select
  a.*,
  min(a.start_tstamp) over(partition by a.device_user_id) as user_start_tstamp,
  max(a.end_tstamp) over(partition by a.device_user_id) as user_end_tstamp

from {{ var('snowplow__sessions_table') }} a
where exists (select 1 from {{ ref('snowplow_mobile_base_sessions_this_run') }} b where a.device_user_id = b.user_identifier)
