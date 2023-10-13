{{
  config(
    sort='start_tstamp',
    dist='session_identifier',
    tags=["this_run"],
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt'))
  )
}}

{% set sessions_query = snowplow_utils.base_create_snowplow_sessions_this_run(
    lifecycle_manifest_table='snowplow_mobile_base_sessions_lifecycle_manifest',
    new_event_limits_table='snowplow_mobile_base_new_event_limits') %}

{{ sessions_query }}
