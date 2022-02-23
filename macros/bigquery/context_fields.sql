{% macro screen_context_fields() %}
  
  {% set screen_context_fields = [
      {'field':('id', 'screen_id'), 'dtype':'string'},
      {'field':('name', 'screen_name'), 'dtype':'string'},
      {'field':('activity', 'screen_activity'), 'dtype':'string'},
      {'field':('fragment', 'screen_fragment'), 'dtype':'string'},
      {'field':('top_view_controller', 'screen_top_view_controller'), 'dtype':'string'},
      {'field':('type', 'screen_type'), 'dtype':'string'},
      {'field':('view_controller', 'screen_view_controller'), 'dtype':'string'}
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
    {'field':('latitude', 'device_latitude'), 'dtype':'float64'},
    {'field':('longitude', 'device_longitude'), 'dtype':'float64'},
    {'field':('latitude_longitude_accuracy', 'device_latitude_longitude_accuracy'), 'dtype':'float64'},
    {'field':('altitude', 'device_altitude'), 'dtype':'float64'},
    {'field':('altitude_accuracy', 'device_altitude_accuracy'), 'dtype':'float64'},
    {'field':('bearing', 'device_bearing'), 'dtype':'float64'},
    {'field':('speed', 'device_speed'), 'dtype':'float64'}
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
    {'field':('user_id', 'device_user_id'), 'dtype':'string'},
    {'field':('first_event_id', 'session_first_event_id'), 'dtype':'string'}
    ] %}

  {{ return(session_context_fields) }}

{% endmacro %}
