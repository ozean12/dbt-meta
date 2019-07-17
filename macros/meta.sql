{#-
  Use schema_name as provided in macro call, use target.schema only
  if no schema is provided at all
-#}
{% macro generate_schema_name(schema_name,node) -%}
    {%- set default_schema = target.schema -%}
    {%- if schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

{% macro get_meta_schema() %}
    {%- set meta_schema=generate_schema_name('dbt_meta') -%}
    {{ return(meta_schema) }}
{% endmacro %}


{% macro create_meta_schema() %}
    create schema if not exists {{ meta.get_meta_schema() }}
{% endmacro %}
