{# Filters out edge cases in test data set which we havent yet solved for - currently illustration only #}
{% macro edge_cases_to_ignore() %}
  user_id not in (
    'NULL device_user_id' -- Case when `device_user_id` is null but `session_id` is not null. Shouldn't happen. Will solve if it arises.
    )
{% endmacro %}
