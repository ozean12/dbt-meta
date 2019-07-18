{# define table name to store test information #}
{% macro get_tests_relation() %}
  {%- set tests_table =
    api.Relation.create(
        identifier='dbt_tests',
        schema=meta.get_meta_schema(),
        type='table'
    ) -%}
    {{ return(tests_table) }}
{% endmacro %}

{# insert a set of records into the tests table #}
{% macro insert_tests(values) %}

    insert into {{ meta.get_tests_relation() }} (
        id,
        test_name,
        test_type,
        tested_model_id,
        invocation_id,
        created_at
        )

    values {{ values }};

{% endmacro %}

{# format a single record for insertion #}
{% macro create_test_record(id, name, type, tested_model_id, insert_timestamp) %}

      (
      {% if variable != None %}'{{ id }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ name }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ type }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ tested_model_id }}'{% else %}null::varchar(1024){% endif %},
      '{{ invocation_id }}',
      {% if variable != None %}'{{ insert_timestamp }}'{% else %}'{{dbt_utils.current_timestamp_in_utc()}}'{% endif %}
      )

{% endmacro %}

{# create table #}
{% macro create_tests_table() %}

    create table if not exists {{ meta.get_tests_relation() }}
    (
       id         varchar(1024),
       test_name       varchar(1024),
       test_type       varchar(1024),
       tested_model_id  varchar(1024),
       invocation_id  varchar(512),
       created_at  {{dbt_utils.type_timestamp()}}
    ); commit;

{% endmacro %}
