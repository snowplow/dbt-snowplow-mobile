{% macro screen_view_event_fields() %}
  
  {% set screen_view_event_fields = [
    {'field':'id', 'renamed_field':'screen_view_id', 'dtype':'string'},
    {'field':'name', 'renamed_field':'screen_view_name', 'dtype':'string'},
    {'field':'previous_id', 'renamed_field':'screen_view_previous_id', 'dtype':'string'},
    {'field':'previous_name', 'renamed_field':'screen_view_previous_name', 'dtype':'string'},
    {'field':'previous_type', 'renamed_field':'screen_view_previous_type', 'dtype':'string'},
    {'field':'transition_type', 'renamed_field':'screen_view_transition_type', 'dtype':'string'},
    {'field':'type', 'renamed_field':'screen_view_type', 'dtype':'string'}
    ] %}

  {{ return(screen_view_event_fields) }}

{% endmacro %}
