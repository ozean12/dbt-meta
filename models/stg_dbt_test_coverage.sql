SELECT
    models.id,
    models.schema,
    models.name,
    tests.created_at,
    count(tests.id)

FROM {{this.schema}}.dbt_tests tests
LEFT JOIN {{ ref(stg_dbt_models) }} models
    ON tests.tested_model_id = models.id

GROUP BY
    models.id,
    models.schema,
    models.name,
    tests.created_at
