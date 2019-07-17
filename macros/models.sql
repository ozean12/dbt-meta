
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
        created_at
        )

    values {{ values }};
    commit;

{% endmacro %}

{# format a single record for insertion #}
{% macro create_model_record(id, schema, name) %}

      (
      {% if variable != None %}'{{ id }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ schema }}'{% else %}null::varchar(1024){% endif %},
      {% if variable != None %}'{{ name }}'{% else %}null::varchar(1024){% endif %},
      {{dbt_utils.current_timestamp_in_utc()}}
      )

{% endmacro %}

{# create table #}
{% macro create_models_table() %}

    create table if not exists {{ meta.get_models_relation() }}
    (
       id         varchar(1024),
       schema       varchar(1024),
       name       varchar(1024),
       created_at  {{dbt_utils.type_timestamp()}}
    ); commit;

{% endmacro %}

{#
  iterate through node graph to
    - filter for models
    - compile insertion values
    - insert to models table
#}
{% macro log_models() %}
    {% set nodes = graph.nodes %}
    {% set model_values = [] %}

    {# Collect all tests compile values to insert later #}
    {% for nodekey in nodes.keys() %}
        {% if nodes[nodekey]['resource_type'] == 'model' %}
            {% set value = meta.create_model_record(nodekey, nodes[nodekey]['schema'], nodes[nodekey]['name']) %}
            {% do model_values.append(value) %}
        {% endif %}
    {% endfor %}

    {{ meta.insert_models(','.join(model_values)) }}

{% endmacro %}
