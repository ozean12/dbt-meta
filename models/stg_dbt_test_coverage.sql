SELECT
    models.id as model_id,
    models.schema as schema,
    models.name as name,
    models.created_at as created_at,
    count(tests.id) as nr_tests

FROM {{this.schema}}.dbt_models models
LEFT JOIN {{this.schema}}.dbt_tests tests
    ON tests.tested_model_id = models.id
    AND tests.invocation_id = models.invocation_id

GROUP BY
    models.id,
    models.schema,
    models.name,
    models.created_at
