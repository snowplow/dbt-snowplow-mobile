{% docs table_base_app_context %}

** This table only exists when working in a Redshift or Postgres warehouse. **

This optional table provides extra context on an event level and brings in data surrounding the application's build and version.
{% enddocs %}

{% docs table_base_geo_context %}

** This table only exists when working in a Redshift or Postgres warehouse. **

This optional table provides extra context on an event level and brings in data surrounding a device's geographical properties, such as latitude/longitude, altitude, and speed.

{% enddocs %}

{% docs table_base_mobile_context %}

** This table only exists when working in a Redshift or Postgres warehouse. **

This optional table provides extra context on an event level and brings in data surrounding a device's manufacturer, model, and carrier.

{% enddocs %}

{% docs table_base_screen_context %}

** This table only exists when working in a Redshift or Postgres warehouse. **

This optional table provides extra context on an event level and brings in data surrounding the screen that the application is on, such as the screen's id, activity, and type.

{% enddocs %}

{% docs table_base_session_context %}

** This table only exists when working in a Redshift or Postgres warehouse. **

This optional table provides extra context on an event level and brings in data surrounding the session that the application is in, such as the session's first event ID, and the ID of the previous session.

{% enddocs %}
