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
        created_at
        )

    values {{ values }};
    commit;

{% endmacro %}

{# format a single record for insertion #}
{% macro create_test_record(id, name, type, tested_model_id) %}

      (
      {% if variable != None %}'{{ id }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ name }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ type }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ tested_model_id }}'{% else %}null::varchar(1024){% endif %},
      {{dbt_utils.current_timestamp_in_utc()}}
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
       created_at  {{dbt_utils.type_timestamp()}}
    ); commit;

{% endmacro %}

{#
  iterate through node graph to
    - filter for tests
    - distinguish between schema and data tests
    - find related models that are tested by each test
    - compile insertion values
    - insert to tests table
#}
{% macro log_tests() %}
    {% set nodes = graph.nodes %}
    {% set test_values = [] %}

    {% for nodekey in nodes.keys() %}
        {% if nodes[nodekey]['resource_type'] == 'test' %}
            {% if 'schema_test' in nodes[nodekey]['fqn'] and nodes[nodekey]['depends_on']['nodes'] %}
                {% for dependency in nodes[nodekey]['depends_on']['nodes'] %}
                    {% set value = meta.create_test_record(nodekey, nodes[nodekey]['name'], 'schema_test', dependency) %}
                    {% do test_values.append(value) %}
                {% endfor %}
            {% endif %}
            {% if 'data_test' in nodes[nodekey]['fqn'] %}
                {% for dependency in nodes[nodekey]['depends_on']['nodes'] %}
                    {% set value = meta.create_test_record(nodekey, nodes[nodekey]['name'], 'data_test', dependency) %}
                    {% do test_values.append(value) %}
                {% endfor %}
            {% endif %}
        {% endif %}
    {% endfor %}

    {{ meta.insert_tests(','.join(test_values)) }}


{% endmacro %}
