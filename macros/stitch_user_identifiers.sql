{#
Copyright (c) 2021-present Snowplow Analytics Ltd. All rights reserved.
This program is licensed to you under the Snowplow Community License Version 1.0,
and you may not use this file except in compliance with the Snowplow Community License Version 1.0.
You may obtain a copy of the Snowplow Community License Version 1.0 at https://docs.snowplow.io/community-license-1.0
#}

{% macro stitch_user_identifiers(enabled, relation=this, user_mapping_relation='snowplow_mobile_user_mapping') %}

  {% if enabled and target.type not in ['databricks', 'spark'] | as_bool() %}

    -- Update sessions table with mapping
    update {{ relation }} as s
    set stitched_user_id = um.user_id
    from {{ ref(user_mapping_relation) }} as um
    where s.device_user_id = um.device_user_id;

{% elif enabled and target.type in ['databricks', 'spark']  | as_bool() %}

    -- Update sessions table with mapping
    merge into {{ relation }} as s
    using {{ ref(user_mapping_relation) }} as um
    on s.device_user_id = um.device_user_id
    when matched then
      update set s.stitched_user_id = um.user_id;

  {% endif %}

{% endmacro %}
