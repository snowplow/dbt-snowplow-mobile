{{ 
  config(
    enabled=(var("snowplow__enable_mobile_context", false) 
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
  m.root_id,
  m.root_tstamp,
  m.device_manufacturer,
  m.device_model,
  m.os_type,
  m.os_version,
  m.android_idfa,
  m.apple_idfa,
  m.apple_idfv,
  m.carrier,
  m.open_idfa,
  m.network_technology,
  m.network_type

from {{ var("snowplow__mobile_context") }} m

where m.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
