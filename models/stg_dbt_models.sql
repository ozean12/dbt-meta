with meta as (

    select * from {{this.schema}}.dbt_models

),

renamed as (

    select
        latest_record.id as id,
        latest_record.schema as schema,
        latest_record.name as name
    from
    (
      select
          *,
          ROW_NUMBER() OVER( PARTITION BY id ORDER BY created_at DESC ) as rn
      from meta
    ) AS latest_record
    where rn = 1
)

select * from renamed
