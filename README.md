[![early-release]][tracker-classificiation] [![License][license-image]][license] [![Discourse posts][discourse-image]][discourse]

![snowplow-logo](https://raw.githubusercontent.com/snowplow/dbt-snowplow-utils/main/assets/snowplow_logo.png)

# snowplow-mobile

This dbt package:

- Transforms and aggregates raw mobile event data collected from the Snowplow [iOS tracker][ios-tracker] or [Android tracker][android-tracker] (up to v3) into a set of derived tables: screen views, sessions, users, and optionally app errors.
- Processes **all mobile events incrementally**. It is not just constrained to screen view events - any custom events you are tracking will also be incrementally processed.
- Is designed in a modular manner, allowing you to easily integrate your own custom SQL into the incremental framework provided by the package.

Please refer to the [doc site][snowplow-mobile-docs] for a full breakdown of the package.

### Adapter Support

The snowplow-mobile v0.6.1 package currently supports BigQuery, Databricks, Redshift, Snowflake & Postgres.

|                         Warehouse                    |     dbt versions    | snowplow-mobile version |
|:----------------------------------------------------:|:-------------------:|:--------------------:|
| BigQuery, Databricks, Redshift, Snowflake & Postgres | >=1.3.0 to <2.0.0   |         0.6.1        |
| BigQuery, Databricks, Redshift, Snowflake & Postgres | >=1.0.0 to <1.3.0   |         0.5.5        |
|       BigQuery, Redshift, Snowflake & Postgres       | >=0.20.0 to <1.0.0  |         0.2.0        |

### Requirements

- A dataset of mobile events from the Snowplow [iOS tracker][ios-tracker] or [Android tracker][android-tracker] must be available in the database.
- Have the [session context (iOS)][ios-session-context] or [session context (Android)][android-session-context] and [screen view events (iOS)][ios-screen-views] or [screen view events (Android)][android-screen-views] enabled.

### Installation

Check dbt Hub for the latest installation instructions, or read the [dbt docs][dbt-package-docs] for more information on installing packages.

### Configuration & Operation

Please refer to the [doc site][snowplow-mobile-docs] for extensive details on how to configure and run the package.

#### Contexts

The following contexts can be enabled depending on your tracker configuration:

- Mobile context
- Geolocation context
- Application context
- Screen context

By default they are disabled. They can be enabled by configuring the `dbt_project.yml` file and setting the appropriate `snowplow__enable_{context_type}_context` variable to `true`.

#### Optional Modules

Currently the app errors module for crash reporting is the only optional module. More will be added in the future as the tracker's functionality expands.

Assuming your tracker is capturing `application_error` events, the module can be enabled by configuring the `dbt_project.yml` file as above.

### Models

The package contains multiple staging models however the mart models are as follows:

| Model                             | Description                                                                                  |
|-----------------------------------|----------------------------------------------------------------------------------------------|
| snowplow_mobile_app_errors        | A table of application errors.                                                               |
| snowplow_mobile_screen_views      | A table of screen views, including engagement metrics such as scroll depth and engaged time. |
| snowplow_mobile_sessions          | An aggregated table of page views, grouped on `session_id`.                                  |
| snowplow_mobile_users             | An aggregated table of sessions to a user level, grouped on `device_user_id`.                |
| snowplow_mobile_user_mapping      | Provides a mapping between user identifiers, `device_user_id` and `user_id`.                 |

Please refer to the [dbt doc site][snowplow-mobile-docs-dbt] for details on the model output tables.

# Join the Snowplow community

We welcome all ideas, questions and contributions!

For support requests, please use our community support [Discourse][discourse] forum.

If you find a bug, please report an issue on GitHub.

# Copyright and license

The snowplow-mobile package is Copyright 2021-2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[license]: http://www.apache.org/licenses/LICENSE-2.0
[license-image]: http://img.shields.io/badge/license-Apache--2-blue.svg?style=flat
[tracker-classificiation]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/tracker-maintenance-classification/
[early-release]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Early%20Release&color=014477&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC

[ios-tracker]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/objective-c-tracker/
[android-tracker]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/android-tracker/
[tracker-docs]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/

[ios-session-context]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/objective-c-tracker/ios-tracker-1-7-0/#Standard_contexts
[ios-screen-views]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/objective-c-tracker/ios-tracker-1-7-0/#tracking-features
[android-session-context]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/android-tracker/android-1-7-0/#Standard_contexts
[android-screen-views]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/android-tracker/android-1-7-0/#tracking-features


[dbt-package-docs]: https://docs.getdbt.com/docs/building-a-dbt-project/package-management

[discourse-image]: https://img.shields.io/discourse/posts?server=https%3A%2F%2Fdiscourse.snowplow.io%2F
[discourse]: http://discourse.snowplow.io/

[snowplow-mobile-docs-dbt]: https://snowplow.github.io/dbt-snowplow-mobile/#!/overview/snowplow_mobile
[snowplow-mobile-docs]: https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/
