{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{{
  config(
    unique_key='session_id',
    sort='max_tstamp',
    dist='session_id',
    cluster_by=snowplow_mobile.mobile_cluster_by_fields_sessions(),
    upsert_date_key='max_tstamp',
    materialized='incremental',
    tags=["derived"],
    snowplow_optimize=true
  )
}}


select *
from {{ ref('snowplow_mobile_session_goals_this_run') }}
where {{ snowplow_utils.is_run_with_new_events('snowplow_mobile') }} --returns false if run doesn't contain new events.
