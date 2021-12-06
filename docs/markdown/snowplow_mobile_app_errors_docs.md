{% docs table_app_errors %}

This derived table contains all app errors and should be the end point for any analysis or BI tools looking to investigate app errors. This is an optional table that will be empty if the `app_errors` module is not enabled.

{% enddocs %}

{% docs table_app_errors_this_run %}

This staging table contains all the app errors for the given run of the Mobile model. This is an optional table that will not be generated if the `app_errors` module is not enabled.

{% enddocs %}

{% docs col_message %}
The error message that the application showed when the app error occurred.
{% enddocs %}

{% docs col_programming_language %}
The name of the programming language used in which the app error occured.
{% enddocs %}

{% docs col_class_name %}
The name of the class where the app error occurred.
{% enddocs %}

{% docs col_exception_name %}
The name of the exception encountered in the app error.
{% enddocs %}

{% docs col_is_fatal %}
A boolean to describe whether the app error was fatal or not.
{% enddocs %}

{% docs col_line_number %}
The line number in the code where the app error occured.
{% enddocs %}

{% docs col_stack_trace %}
 The full stack trace that was presented when the app error occured.
{% enddocs %}

{% docs col_thread_id %}
The ID of the thread in which the app error occurred.
{% enddocs %}

{% docs col_thread_name %}
The name of the process that ran the thread when the app error occurred.
{% enddocs %}

{% docs col_event_index_in_session %}
A session index of the event.
{% enddocs %}
