{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

-- test dataset includes contexts_com_snowplowanalytics_snowplow_client_session_1_0_1 due to a mutual solution covering other adapters
-- needs to be separated into its own table here

select
  *

from {{ ref("snowplow_mobile_client_session_context") }}
