-- test dataset includes contexts_com_snowplowanalytics_snowplow_client_session_1_0_1 due to a mutual solution covering other adapters
-- needs to be separated into its own table here

select
  *

from {{ ref("snowplow_mobile_client_session_context") }}
