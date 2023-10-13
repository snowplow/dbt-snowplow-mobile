-- test dataset includes contexts_com_snowplowanalytics_snowplow_geolocation_context_1_1_0 due to a mutual solution covering other adapters
-- needs to be separated into its own table here

select
    *

from {{ ref("snowplow_mobile_geolocation_context") }}
