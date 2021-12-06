{{ 
  config(
    enabled=(var("snowplow__enable_application_context", false) 
      and target.type in ['redshift','postgres'] | as_bool()),
    dist='root_id',
    sort='root_tstamp'
  )
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mobile_base_events_this_run_limits'),
                                      'lower_limit',
                                      'upper_limit') %}
select
  ac.root_id,
  ac.root_tstamp,
  ac.build,
  ac.version

from {{ var("snowplow__application_context") }} ac

where ac.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
