{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}


select
  *

from {{ ref('snowplow_mobile_events') }}
where {{ edge_cases_to_ignore() }} --filter out any edge cases we havent yet solved for but are included in the test dataset.
