{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{# Filters out edge cases in test data set which we havent yet solved for - currently illustration only #}
{% macro edge_cases_to_ignore() %}
  user_id not in (
    'NULL device_user_id' -- Case when `device_user_id` is null but `session_id` is not null. Shouldn't happen. Will solve if it arises.
    )
{% endmacro %}
