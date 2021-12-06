{{ 
  config(
    sort='max_tstamp',
    dist='session_id',
    tags=["this_run"]
  ) 
}}

with goals as (
    select
        sv.session_id,
        MAX(sv.derived_tstamp) as max_tstamp,
        BOOL_OR(sv.screen_view_name = 'registration') AS has_started_registration,
        BOOL_OR(sv.screen_view_name = 'my_account') AS has_completed_registration,
        BOOL_OR(sv.screen_view_name = 'search_results') AS has_used_search,
        BOOL_OR(sv.screen_view_name = 'products') AS has_viewed_products

    from {{ var('snowplow__screen_views_table') }} as sv
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
