{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    materialized='incremental',
    enabled=var('snowplow__enable_custom_example'),
    unique_key='max_tstamp',
    upsert_date_key='max_tstamp',
    sort='max_tstamp',
    dist='session_id',
    partition_by = snowplow_utils.get_value_by_target_type(bigquery_val= {
      "field": "max_tstamp",
      "data_type": "timestamp"
    }),
    cluster_by=["session_id"],
    snowplow_optimize=true
  )
}}

with goals as (
    select
        sv.session_id,
        MAX(sv.derived_tstamp) as max_tstamp,
        {{ snowplow_mobile.bool_or("sv.screen_view_name = 'registration'") }} AS has_started_registration,
        {{ snowplow_mobile.bool_or("sv.screen_view_name = 'my_account'") }} AS has_completed_registration,
        {{ snowplow_mobile.bool_or("sv.screen_view_name = 'search_results'") }} AS has_used_search,
        {{ snowplow_mobile.bool_or("sv.screen_view_name = 'products'") }} AS has_viewed_products

    from {{ ref('snowplow_mobile_screen_views_this_run' ) }} sv
    group by 1
)

select
    g.session_id,
    g.max_tstamp,
    g.has_started_registration,
    g.has_completed_registration,
    g.has_used_search,
    g.has_viewed_products,
    case
        when g.has_started_registration and g.has_completed_registration
            and g.has_used_search and g.has_viewed_products then TRUE
    else FALSE end as has_completed_goals

from goals g
