-- test dataset includes contexts_com_snowplowanalytics_snowplow_client_session_1_0_1 due to a mutual solution covering other adapters
-- needs to be separated into its own table here

with prep as (

  select
    event_id as root_id,
    collector_tstamp as root_tstamp,

  {%- if target.type == 'postgres' %}
    substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'session_id' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 13, 36)::uuid as session_id, -- test dataset uses json format. Extract.

  {%- else -%}
    substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'session_id' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 13, 36) as session_id, -- test dataset uses json format. Extract.

  {%- endif %}

    case when right(substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'session_index' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 16, 3), 1) = ','
      then substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'session_index' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 16, 1)
      else substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'session_index' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 16, 2)
      end as session_index,
    substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'previous_session_id' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 22, 36) as previous_session_id,
    substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'user_id' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 10, 36) as user_id,
    substring(contexts_com_snowplowanalytics_snowplow_client_session_1_0_1, position( 'first_event_id' in contexts_com_snowplowanalytics_snowplow_client_session_1_0_1)+ 17, 36) as first_event_id

  from {{ ref("snowplow_mobile_events") }}

)

select * from prep
