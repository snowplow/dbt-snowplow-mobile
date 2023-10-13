#!/bin/bash

# Expected input:
# -d (database) target database for dbt

while getopts 'd:' opt
do
  case $opt in
    d) DATABASE=$OPTARG
  esac
done

declare -a SUPPORTED_DATABASES=("bigquery" "databricks" "postgres" "redshift" "snowflake")

# set to lower case
DATABASE="$(echo $DATABASE | tr '[:upper:]' '[:lower:]')"

VARS=""

if [[ $DATABASE == "all" ]]; then
  DATABASES=( "${SUPPORTED_DATABASES[@]}" )
else
  DATABASES=$DATABASE
fi

for db in ${DATABASES[@]}; do

  echo "Snowplow mobile integration tests: Seeding data"

  eval "dbt seed --full-refresh --target $db" || exit 1;

  echo "Snowplow mobile integration tests: Execute models - run 1/4"

  if [ "$db" == "postgres" ] || [ "$db" == "redshift" ] ; then

    VARS="{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'snowplow_mobile_session_context_stg', 'field' : 'session_id', 'prefix': 'sc'}], snowplow__user_identifiers: [{'schema' : 'snowplow_mobile_session_context_stg', 'field' : 'user_id', 'prefix': 'sc'}]}"

  elif [ "$db" == "databricks" ]; then

    VARS="{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'session_id'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'user_id'}]}"

  elif [ "$db" == "bigquery" ]; then

    VARS="{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1_0_1', 'field' : 'session_id'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1_0_1', 'field' : 'user_id'}]}"

  elif [ "$db" == "snowflake" ]; then

    VARS="{snowplow__allow_refresh: true, snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'sessionId'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'userId'}]}"

  fi

  eval "dbt run --full-refresh --vars '$VARS' --target $db" || exit 1;

  if [ "$db" == "postgres" ] || [ "$db" == "redshift" ] ; then

    VARS="{snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'snowplow_mobile_session_context_stg', 'field' : 'session_id', 'prefix': 'sc'}], snowplow__user_identifiers: [{'schema' : 'snowplow_mobile_session_context_stg', 'field' : 'user_id', 'prefix': 'sc'}]}"

  elif [ "$db" == "databricks" ]; then

    VARS="{snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'session_id'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'user_id'}]}"

  elif [ "$db" == "bigquery" ]; then

    VARS="{snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1_0_1', 'field' : 'session_id'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1_0_1', 'field' : 'user_id'}]}"

  elif [ "$db" == "snowflake" ]; then

    VARS="{snowplow__backfill_limit_days: 60, snowplow__session_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'sessionId'}], snowplow__user_identifiers: [{'schema' : 'contexts_com_snowplowanalytics_snowplow_client_session_1', 'field' : 'userId'}]}"

  fi

  for i in {2..4}
  do
    echo "Snowplow mobile integration tests: Execute models - run $i/4"

    eval "dbt run --vars '$VARS' --target $db" || exit 1;
  done

  echo "Snowplow mobile integration tests: Test models"

  eval "dbt test --target $db" || exit 1;

  echo "Snowplow mobile integration tests: All tests passed"

done
