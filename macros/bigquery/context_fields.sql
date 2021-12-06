{% macro screen_context_fields() %}
  
  {% set screen_context_fields = [
      {'field':'id', 'renamed_field':'screen_id', 'dtype':'string'},
      {'field':'name', 'renamed_field':'screen_name', 'dtype':'string'},
      {'field':'activity', 'renamed_field':'screen_activity', 'dtype':'string'},
      {'field':'fragment', 'renamed_field':'screen_fragment', 'dtype':'string'},
      {'field':'top_view_controller', 'renamed_field':'screen_top_view_controller', 'dtype':'string'},
      {'field':'type', 'renamed_field':'screen_type', 'dtype':'string'},
      {'field':'view_controller', 'renamed_field':'screen_view_controller', 'dtype':'string'}
    ] %}

  {{ return(screen_context_fields) }}

{% endmacro %}

{% macro mobile_context_fields() %}
  
  {% set mobile_context_fields = [
    {'field':'device_manufacturer', 'dtype':'string'},
    {'field':'device_model', 'dtype':'string'},
    {'field':'os_type', 'dtype':'string'},
    {'field':'os_version', 'dtype':'string'},
    {'field':'android_idfa', 'dtype':'string'},
    {'field':'apple_idfa', 'dtype':'string'},
    {'field':'apple_idfv', 'dtype':'string'},
    {'field':'carrier', 'dtype':'string'},
    {'field':'open_idfa', 'dtype':'string'},
    {'field':'network_technology', 'dtype':'string'},
    {'field':'network_type', 'dtype':'string'}
    ] %}

  {{ return(mobile_context_fields) }}

{% endmacro %}

{% macro app_error_context_fields() %}
  
  {% set app_error_context_fields = [
    {'field':'message', 'dtype':'string'},
    {'field':'programming_language', 'dtype':'string'},
    {'field':'class_name', 'dtype':'string'},
    {'field':'exception_name', 'dtype':'string'},
    {'field':'file_name', 'dtype':'string'},
    {'field':'is_fatal', 'dtype':'boolean'},
    {'field':'line_column', 'dtype':'integer'},
    {'field':'line_number', 'dtype':'integer'},
    {'field':'stack_trace', 'dtype':'string'},
    {'field':'thread_id', 'dtype':'integer'},
    {'field':'thread_name', 'dtype':'string'}
    ] %}

  {{ return(app_error_context_fields) }}

{% endmacro %}

{% macro geo_context_fields() %}
  
  {% set geo_context_fields = [
    {'field':'latitude', 'renamed_field':'device_latitude', 'dtype':'float'},
    {'field':'longitude', 'renamed_field':'device_longitude', 'dtype':'float'},
    {'field':'latitude_longitude_accuracy', 'renamed_field':'device_latitude_longitude_accuracy', 'dtype':'float'},
    {'field':'altitude', 'renamed_field':'device_altitude', 'dtype':'float'},
    {'field':'altitude_accuracy', 'renamed_field':'device_altitude_accuracy', 'dtype':'float'},
    {'field':'bearing', 'renamed_field':'device_bearing', 'dtype':'float'},
    {'field':'speed', 'renamed_field':'device_speed', 'dtype':'float'}
    ] %}

  {{ return(geo_context_fields) }}

{% endmacro %}

{% macro app_context_fields() %}
  
  {% set app_context_fields = [
    {'field':'build', 'dtype':'string'},
    {'field':'version', 'dtype':'string'}
    ] %}

  {{ return(app_context_fields) }}

{% endmacro %}

{% macro session_context_fields() %}
  
  {% set session_context_fields = [
    {'field':'session_id', 'dtype':'string'},
    {'field':'session_index', 'dtype':'integer'},
    {'field':'previous_session_id', 'dtype':'string'},
    {'field':'user_id', 'renamed_field':'device_user_id', 'dtype':'string'},
    {'field':'first_event_id', 'renamed_field':'session_first_event_id', 'dtype':'string'}
    ] %}

  {{ return(session_context_fields) }}

{% endmacro %}

{% macro to_datatype(datatype) %}

  {% set datatype = datatype|lower %}

  {% if datatype == 'string' %}

    {{ return(dbt_utils.type_string()) }}

  {% elif datatype == 'float' %}

    {{ return(dbt_utils.type_float()) }}

  {% elif datatype == 'timestamp' %}

    {{ return(dbt_utils.type_timestamp()) }}

  {% elif datatype == 'numeric' %}

    {{ return(dbt_utils.type_numeric()) }}

  {% elif datatype in ['integer','int'] %}

    {{ return(dbt_utils.type_int()) }}

  {% else %}

    {{ return(datatype) }}

  {% endif %}
  
{% endmacro %}

{% macro get_fields_from_col(col_prefix, fields, relation, relation_alias, enabled=true) -%}

  {%- if enabled -%}

    {%- set source_fields = fields|map(attribute='field')|list -%}
    {%- set raw_renamed_fields = fields|map(attribute='renamed_field')|list -%}
    {%- set renamed_fields = [] -%}

    {# If renamed_field not given, use source_field name #}
    {# TODO: Hacky, improve combine_column_versions #}
    {%- for field in raw_renamed_fields -%}
      {%- if field is not defined -%}
        {%- do renamed_fields.append(source_fields[loop.index0]) -%}
      {%- else -%}
        {%- do renamed_fields.append(field) -%}
      {%- endif -%}
    {%- endfor -%}

    {%- set combined_fields = snowplow_utils.combine_column_versions(
                                    relation=relation,
                                    column_prefix=col_prefix,
                                    source_fields=source_fields,
                                    renamed_fields=renamed_fields,
                                    relation_alias=relation_alias
                                    ) -%}

    {{ combined_fields|join(',\n') }}

  {%- else -%}

    {%- for field in fields -%}
      {%- set renamed_field = field.field if field.renamed_field is not defined else field.renamed_field -%}
      {%- set dtype = to_datatype(field.dtype) -%}
      cast(null as {{ dtype }}) as {{ renamed_field }} {% if not loop.last %}, {% endif %}
    {% endfor %}

  {%- endif -%}

{% endmacro %}
