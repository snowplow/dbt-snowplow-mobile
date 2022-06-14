{% macro stitch_user_identifiers(enabled, relation=this, user_mapping_relation=ref('snowplow_mobile_user_mapping')) %}

  {% if enabled and target.type != 'databricks' | as_bool() %}

    -- Update sessions table with mapping
    update {{ relation }} as s
    set stitched_user_id = um.user_id
    from {{ user_mapping_relation }} as um
    where s.device_user_id = um.device_user_id;

  {% endif %}

{% endmacro %}
