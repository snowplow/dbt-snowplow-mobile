# Snowplow Custom Example

This is a dummy dbt project demonstrating how to integrate custom modules into the Snowplow Mobile dbt package.

We highlight two methods to add custom modules.

## Set Up

- Install the Snowplow Mobile dbt package by [adding the package](https://docs.getdbt.com/docs/building-a-dbt-project/package-management) to the your `package.yml` file. See [dbt's package hub](https://hub.getdbt.com/snowplow/snowplow_mobile/latest/) for the latest instruction.
- Create a sub directory under `/models` to contain all your custom modules. We recommend `snowplow_mobile_custom_modules`.
- Add the tag `snowplow_mobile_incremental` to your custom modules directory. This ensures all models in this directory are included in the incremental logic of the Snowplow Mobile package.

```yml
# dbt_project.yml
models:
  snowplow_mobile_custom_example:
    snowplow_mobile_custom_modules:
      +tags: snowplow_mobile_incremental # Adds tag to all models in the 'snowplow_mobile_custom_modules' directory
```

- Redshift/Postgres only: Add sources for any context or unstructured events tables that you need for your custom module:

```yml
# snowplow_sources.yml
sources:
  - name: atomic
    schema: "{{ var('snowplow__atomic_schema', 'atomic') }}"
    database: "{{ var('snowplow__database', target.database) }}"
    tables:
      - name: com_snowplowanalytics_snowplow_client_session_1
```

## Method 1 - Create standalone incremental custom module

This method takes your custom SQL and produces an incremental 'derived' custom table. This can then be joined back onto the standard derived tables produced by the Snowplow Mobile dbt package (screen views, sessions, users). This methodology lends itself well to niche metrics or fields that are used infrequently during analysis. By having stand alone modules, you avoid bloating your derived tables with rarely used columns.

Another advantage of this method is if you want to change the logic in your custom module and replay all events through the new version, you don't have to also tear down the 'standard' table with corresponding level of aggregation as the two are independent.

An example of such a set up can be seen in [snowplow_mobile_session_goals.sql](models/snowplow_mobile_custom_modules/session_goals/snowplow_mobile_session_goals.sql). This model calculates screen view milestones on a session level from screen view events.

### Points to note

- We select events from `snowplow_mobile_base_events_this_run` rather than `atomic.events`. This ensures we only have the events required for this run, as well as not having to worry about de-duping events.
- We include the `is_run_with_new_events()` macro in the where clause. This ensures that no old data is inserted into the table during back-fills. This improves performance and protects against inaccurate data in the table during batched back-fills.
- The model is materialized using the `snowplow_incremental` materialization. This reduces the table scan on the target table during the upsert procedure. You could equally use the out-the-box `incremental` materialization if you so wanted.
- This incremental table can then be joined back to the `snowplow_mobile_sessions` table to produce a bespoke session view catered for your business needs, `snowplow_mobile_sessions_custom`. Notice how this is materialized as a view, saving on storage cost.

## Method 2 - Replace a standard derived table with your own custom version

We do not yet have an example of this for the mobile model. We do however have an example in the [web model](https://github.com/snowplow/dbt-snowplow-web), under the identically named `custom_example` directory, which works in much the same way as it would in the mobile model.