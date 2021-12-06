{{ 
  config(materialized='view',
         enabled=(var('snowplow__enable_screen_context') 
                  and target.type in ['redshift','postgres'] | as_bool())
         ) 
}}

{%- set lower_limit, upper_limit = snowplow_utils.return_limits_from_model(
                                      ref('snowplow_mob_base_events_this_run_limits'),
                                      'lower_limit',
                                      'upper_limit') %}
select
  sc.root_id,
  sc.root_tstamp,
  sc.id AS screen_id,
  sc.name AS screen_name,
  sc.activity AS screen_activity,
  sc.fragment AS screen_fragment,
  sc.top_view_controller AS screen_top_view_controller,
  sc.type AS screen_type,
  sc.view_controller AS screen_view_controller

from {{ var("snowplow__screen_context") }} sc

where sc.root_tstamp between {{ lower_limit }} and {{ upper_limit }}
