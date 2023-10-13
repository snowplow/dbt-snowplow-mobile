-- test dataset includes unstruct_event_com_snowplowanalytics_mobile_screen_view_1_0_0 due to a mutual solution covering other adapters
-- needs to be separated into its own table here


select
  *

from {{ ref("snowplow_mobile_screen_view_context") }}
