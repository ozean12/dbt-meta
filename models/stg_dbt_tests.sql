with meta as (

    select * from {{this.schema}}.dbt_tests

),

renamed as (

    select
        latest_record.id as id,
        latest_record.test_name as test_name,
        latest_record.test_type as test_type,
        latest_record.tested_model_id as tested_model_id,
        latest_record.created_at as created_at
    from
    (
      select
          *,
          ROW_NUMBER() OVER( PARTITION BY created_at ORDER BY created_at DESC ) as rn
      from meta
    ) AS latest_record
    where rn = 1


)

select * from renamed
