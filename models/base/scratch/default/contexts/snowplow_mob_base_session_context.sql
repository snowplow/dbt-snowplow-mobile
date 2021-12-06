{{ 
  config(materialized='view') 
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mob_base_events_this_run_limits'),
                                      'lower_limit',
                                      'upper_limit') %}
select
  s.root_id,
  s.root_tstamp,
  s.session_id,
  s.session_index,
  s.previous_session_id,
  s.user_id as device_user_id,
  s.first_event_id as session_first_event_id

from {{ var("snowplow__session_context") }} s

where s.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
