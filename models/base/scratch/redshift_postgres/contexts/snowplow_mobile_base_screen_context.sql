{{
  config(
    enabled=(var("snowplow__enable_screen_context", false)
      and target.type in ['redshift','postgres'] | as_bool()),
    dist='root_id',
    sort='root_tstamp'
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mobile_base_events_this_run_limits'),
                                      'lower_limit',
                                      'upper_limit') %}

with base as (

  select
    sc.root_id,
    sc.root_tstamp,
    sc.id AS screen_id,
    sc.name AS screen_name,
    sc.activity AS screen_activity,
    sc.fragment AS screen_fragment,
    sc.top_view_controller AS screen_top_view_controller,
    sc.type AS screen_type,
    sc.view_controller AS screen_view_controller,
    row_number() over (partition by root_id order by root_tstamp) dedupe_index

  from {{ var("snowplow__screen_context") }} sc

  where sc.root_tstamp between {{ lower_limit }} and {{ upper_limit }}

)

select *

from base

where dedupe_index = 1
