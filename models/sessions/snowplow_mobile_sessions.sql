{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='session_id',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='session_id',
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
       "field": "start_tstamp",
       "data_type": "timestamp"
     }, databricks_partition_by='start_tstamp_date'),
    cluster_by=snowplow_mobile.mobile_cluster_by_fields_sessions(),
    tags=["derived"],
    post_hook="{{ snowplow_mobile.stitch_user_identifiers(
      enabled=var('snowplow__session_stitching')
      ) }}",
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}


select *
  {% if target.type == 'databricks' -%}
   , DATE(start_tstamp) as start_tstamp_date
   {%- endif %}
from {{ ref('snowplow_mobile_sessions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
