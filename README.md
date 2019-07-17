## dbt meta

Note: this packages has been forked from [fishtown-analytics/dbt-event-logging](https://github.com/fishtown-analytics/dbt-event-logging). Notable changes:
- the package has been renamed
- logging functionality has been preserved, but schema naming has changed
- model information is stored in the `models` table
- test information is stored in the `tests` table

---
- [What is dbt](https://dbt.readme.io/docs/overview)?
- Read the [dbt viewpoint](https://dbt.readme.io/docs/viewpoint)
- [Installation](https://dbt.readme.io/docs/installation)
- Join the [chat](http://ac-slackin.herokuapp.com/) on Slack for live questions and support.

---

Requires dbt >= 0.12.2

### Event logging

This package provides out-of-the-box functionality to log events for all dbt invocations, including run start, run end, model start, and model end. It outputs all data and models to schema `[target.schema]_meta`. There are three convenience models to make it easier to parse the event log data.

#### Setup

1. Include this package in your `packages.yml`.
2. Include the following in your `dbt_project.yml` directly within your `models:` directive (making sure to handle indenting appropriately):

```YAML
pre-hook: "{{ meta.log_model_start_event() }}"
post-hook: "{{ meta.log_model_end_event() }}"
```

That's it! You'll now have a stream of events for all dbt invocations in your warehouse.

#### Adapter support

This package is currently compatible with dbt's Snowflake, Redshift, and Postgres integrations.
