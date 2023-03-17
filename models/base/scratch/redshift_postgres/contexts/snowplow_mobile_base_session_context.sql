{{
  config(
    enabled=(target.type in ['redshift','postgres'] | as_bool()),
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
  s.root_id,
  s.root_tstamp,
  s.session_id,
  s.session_index,
  s.previous_session_id,
  s.user_id as device_user_id,
  s.first_event_id as session_first_event_id,
  row_number() over (partition by root_id order by root_tstamp) dedupe_index

from {{ var("snowplow__session_context") }} s

where s.root_tstamp between {{ lower_limit }} and {{ upper_limit }}

)

select *

from base

where dedupe_index = 1
