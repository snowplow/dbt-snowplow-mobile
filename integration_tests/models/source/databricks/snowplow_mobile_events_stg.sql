-- page view context is given as json string in csv. Parse json
 {{ config(
  materialized='table',
  )
}}

with prep as (
 select
   *,
   from_json(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0, 'array<struct<id:string, name:string, previous_id:string, previous_name:string, previous_type:string, transition_type:string, type:string>>') as unstruct_event_com_snowplowanalytics_mobile_screen_view_1,
   from_json(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, 'array<struct<session_id:string, session_index:string, previous_session_id:string, user_id:string, first_event_id:string>>') as contexts_com_snowplowanalytics_snowplow_client_session_1

  from {{ ref('snowplow_mobile_events') }}
 )


  select
   *

  from prep

  where {{ edge_cases_to_ignore() }} --filter out any edge cases we havent yet solved for but are included in the test dataset.
