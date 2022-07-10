{{
  config(
    materialized=var("snowplow__incremental_materialization"),
    unique_key='screen_view_id',
    upsert_date_key='derived_tstamp',
    sort='derived_tstamp',
    dist='screen_view_id',
    partition_by = snowplow_utils.get_partition_by(bigquery_partition_by={
       "field": "derived_tstamp",
       "data_type": "timestamp"
     }, databricks_partition_by='derived_tstamp_date'),
    cluster_by=snowplow_mobile.mobile_cluster_by_fields_screen_views(),
    tags=["derived"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}


select *
    {% if target.type in ['databricks', 'spark'] -%}
    , DATE(derived_tstamp) as derived_tstamp_date
    {%- endif %}
from {{ ref('snowplow_mobile_screen_views_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
