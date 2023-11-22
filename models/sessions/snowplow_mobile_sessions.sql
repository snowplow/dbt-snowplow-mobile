{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    materialized="incremental",
    unique_key='session_id',
    upsert_date_key='start_tstamp',
    sort='start_tstamp',
    dist='session_id',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val={
      "field": "start_tstamp",
      "data_type": "timestamp"
    }, databricks_val='start_tstamp_date'),
    cluster_by=snowplow_mobile.mobile_cluster_by_fields_sessions(),
    tags=["derived"],
    post_hook="{{ snowplow_mobile.stitch_user_identifiers(
      enabled=var('snowplow__session_stitching')
      ) }}",
    sql_header=snowplow_utils.set_query_tag(var('snowplow__query_tag', 'snowplow_dbt')),
    tblproperties={
      'delta.autoOptimize.optimizeWrite' : 'true',
      'delta.autoOptimize.autoCompact' : 'true'
    },
    snowplow_optimize=true
  )
}}


select *
  {% if target.type in ['databricks', 'spark'] -%}
    , DATE(start_tstamp) as start_tstamp_date
  {%- endif %}
from {{ ref('snowplow_mobile_sessions_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
