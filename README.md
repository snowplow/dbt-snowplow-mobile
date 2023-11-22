[![early-release]][tracker-classification] [![License][license-image]][license] [![Discourse posts][discourse-image]][discourse]

![snowplow-logo](https://raw.githubusercontent.com/snowplow/dbt-snowplow-utils/main/assets/snowplow_logo.png)

# snowplow-mobile

This dbt package:

- Transforms and aggregates raw mobile event data collected from the Snowplow [iOS tracker][ios-tracker] or [Android tracker][android-tracker] (up to v3) into a set of derived tables: screen views, sessions, users, and optionally app errors.
- Processes **all mobile events incrementally**. It is not just constrained to screen view events - any custom events you are tracking will also be incrementally processed.
- Is designed in a modular manner, allowing you to easily integrate your own custom SQL into the incremental framework provided by the package.

Please refer to the [doc site](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-models/dbt-mobile-data-model/) for a full breakdown of the package.

### Getting Started

The easiest way to get started is to follow our [QuickStart guide](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-quickstart/mobile/), or to use our [Advanced Analytics for Mobile Accelerator](https://docs.snowplow.io/accelerators/mobile/) which includes steps for setting up tracking as well as modeling.


### Adapter Support

The latest version of the snowplow-mobile package supports BigQuery, Databricks, Redshift, Snowflake & Postgres. For previous versions see our [package docs](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/).

### Requirements

- A dataset of mobile events from the Snowplow [iOS tracker][ios-tracker] or [Android tracker][android-tracker] must be available in the database.
- Have the [session context (iOS)][ios-session-context] or [session context (Android)][android-session-context] and [screen view events (iOS)][ios-screen-views] or [screen view events (Android)][android-screen-views] enabled.

### Installation

Check [dbt Hub](https://hub.getdbt.com/snowplow/snowplow_web/latest/) for the latest installation instructions.

### Configuration & Operation

Please refer to the [doc site](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/) for details on how to [configure](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-configuration/mobile/) and [run](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-quickstart/mobile/) the package.

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

Please refer to the [dbt doc site](https://snowplow.github.io/dbt-snowplow-mobile/#!/overview/snowplow_mobile) for details on the model output tables.

# Join the Snowplow community

We welcome all ideas, questions and contributions!

For support requests, please use our community support [Discourse][discourse] forum.

If you find a bug, please report an issue on GitHub.

# Copyright and license

The snowplow-mobile package is Copyright 2021-present Snowplow Analytics Ltd.

This distribution is all licensed under the [Snowplow Community License, Version 1.0][license] . (If you are uncertain how it applies to your use case, check our answers to [frequently asked questions](https://docs.snowplow.io/docs/contributing/community-license-faq/).)

[license]: https://docs.snowplow.io/community-license-1.0/
[license-image]: http://img.shields.io/badge/license-Snowplow--Community--1-blue.svg?style=flat
[tracker-classification]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/tracker-maintenance-classification/
[early-release]: https://img.shields.io/static/v1?style=flat&label=Snowplow&message=Early%20Release&color=014477&labelColor=9ba0aa&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAeFBMVEVMaXGXANeYANeXANZbAJmXANeUANSQAM+XANeMAMpaAJhZAJeZANiXANaXANaOAM2WANVnAKWXANZ9ALtmAKVaAJmXANZaAJlXAJZdAJxaAJlZAJdbAJlbAJmQAM+UANKZANhhAJ+EAL+BAL9oAKZnAKVjAKF1ALNBd8J1AAAAKHRSTlMAa1hWXyteBTQJIEwRgUh2JjJon21wcBgNfmc+JlOBQjwezWF2l5dXzkW3/wAAAHpJREFUeNokhQOCA1EAxTL85hi7dXv/E5YPCYBq5DeN4pcqV1XbtW/xTVMIMAZE0cBHEaZhBmIQwCFofeprPUHqjmD/+7peztd62dWQRkvrQayXkn01f/gWp2CrxfjY7rcZ5V7DEMDQgmEozFpZqLUYDsNwOqbnMLwPAJEwCopZxKttAAAAAElFTkSuQmCC

[ios-tracker]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/objective-c-tracker/
[android-tracker]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/android-tracker/
[tracker-docs]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/

[ios-session-context]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/objective-c-tracker/ios-tracker-1-7-0/#Standard_contexts
[ios-screen-views]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/objective-c-tracker/ios-tracker-1-7-0/#tracking-features
[android-session-context]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/android-tracker/android-1-7-0/#Standard_contexts
[android-screen-views]: https://docs.snowplow.io/docs/collecting-data/collecting-from-own-applications/mobile-trackers/previous-versions/android-tracker/android-1-7-0/#tracking-features

[discourse-image]: https://img.shields.io/discourse/posts?server=https%3A%2F%2Fdiscourse.snowplow.io%2F
[discourse]: http://discourse.snowplow.io/
