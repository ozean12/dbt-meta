{# define table name to store model information #}
{% macro get_models_relation() %}
  {%- set models_table =
    api.Relation.create(
        identifier='dbt_models',
        schema=meta.get_meta_schema(),
        type='table'
    ) -%}
    {{ return(models_table) }}

{% endmacro %}


{# insert a set of records into the model table #}
{% macro insert_models(values) %}

    insert into {{ meta.get_models_relation() }} (
        id,
        schema,
        name,
        invocation_id,
        created_at
        )

    values {{ values }};

{% endmacro %}

{# format a single record for insertion #}
{% macro create_model_record(id, schema, name, insert_timestamp) %}

      (
      {% if variable != None %}'{{ id }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ schema }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ name }}'{% else %}null::varchar(1024){% endif %},
      '{{ invocation_id }}',
      {% if variable != None %}'{{ insert_timestamp }}'{% else %}'{{dbt_utils.current_timestamp_in_utc()}}'{% endif %}
      )

{% endmacro %}

{# create table #}
{% macro create_models_table() %}

    create table if not exists {{ meta.get_models_relation() }}
    (
       id             varchar(1024),
       schema         varchar(1024),
       name           varchar(1024),
       invocation_id  varchar(512),
       created_at  {{dbt_utils.type_timestamp()}}
    ); commit;

{% endmacro %}
