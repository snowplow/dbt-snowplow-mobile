# snowplow-mobile-integration-tests

Integration test suite for the snowplow-mobile dbt package.

The `./scripts` directory contains two scripts:

- `integration_tests.sh`: This tests the standard modules of the snowplow-mobile package. It runs the Snowplow mobile package 4 times to replicate incremental loading of events, then performs an equality test between the actual vs expected output.

- `integration_tests_w_custom_module.sh`: This tests the standard modules of the snowplow-mobile package as well as the back-filling of custom modules. In total the package is run 6 times, with run 1-2 being the standard modules, runs 3-4 being the back-filling of the newly introduced custom module, and runs 5-6 being the both the standard and custom module. Once complete, equality checks are performed on the actual vs expected output of the standard modules.

Run the scripts using:

```bash
bash integration_tests.sh -d {warehouse}
```

Supported warehouses:

- bigquery
- databricks
- postgres
- redshift
- snowflake
- all (iterates through all supported warehouses)
