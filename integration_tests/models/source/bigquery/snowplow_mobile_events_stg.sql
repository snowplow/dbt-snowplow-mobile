{{ config(
  materialized='table',
  )
}}

-- page view context is given as json string in csv. Extract array from json
with prep as (
select
  *
  except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0, contexts_com_snowplowanalytics_snowplow_client_session_1_0_1),
  JSON_EXTRACT_ARRAY(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) AS unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
  JSON_EXTRACT_ARRAY(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1) AS contexts_com_snowplowanalytics_snowplow_client_session_1_0_1

from {{ ref('snowplow_mobile_events') }}
)

-- recreate repeated record field i.e. array of structs as is originally in BQ events table
select
  * except(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0, contexts_com_snowplowanalytics_snowplow_client_session_1_0_1),
  array(
    select as struct JSON_EXTRACT_scalar(json_array,'$.id') as id,
                    JSON_EXTRACT_scalar(json_array,'$.name') as name,
                    JSON_EXTRACT_scalar(json_array,'$.previous_id') as previous_id,
                    JSON_EXTRACT_scalar(json_array,'$.previous_name') as previous_name,
                    JSON_EXTRACT_scalar(json_array,'$.previous_type') as previous_type,
                    JSON_EXTRACT_scalar(json_array,'$.transition_type') as transition_type,
                    JSON_EXTRACT_scalar(json_array,'$.type') as type
    from unnest(unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0) as json_array
    ) as unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0,
  array(
    select as struct JSON_EXTRACT_scalar(json_array,'$.session_id') as session_id,
                    JSON_EXTRACT_scalar(json_array,'$.user_id') as user_id,
                    JSON_EXTRACT_scalar(json_array,'$.session_index') as session_index,
                    JSON_EXTRACT_scalar(json_array,'$.first_event_id') as first_event_id,
                    JSON_EXTRACT_scalar(json_array,'$.previous_session_id') as previous_session_id
    from unnest(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1) as json_array
    ) as contexts_com_snowplowanalytics_snowplow_client_session_1_0_1

from prep

where {{ edge_cases_to_ignore() }} --filter out any edge cases we havent yet solved for but are included in the test dataset.
