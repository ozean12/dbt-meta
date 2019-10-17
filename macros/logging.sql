
{% macro get_logging_relation() %}
  {#-
  A project's version of the generate_schema_name macro will take precedence
  over the global version
  -#}
  {%- set logging_table =
    api.Relation.create(
        identifier='dbt_audit_log',
        schema=meta.get_meta_schema(),
        type='table'
    ) -%}
    {{ return(logging_table) }}
{% endmacro %}


{% macro log_event(event_name, schema, relation) %}

    insert into {{ meta.get_logging_relation() }} (
        event_name,
        event_timestamp,
        event_schema,
        event_model,
        invocation_id,
        username
        )

    values (
        '{{ event_name }}',
        {{dbt_utils.current_timestamp_in_utc()}},
        {% if variable != None %}'{{ schema }}'{% else %}null::varchar(512){% endif %},
        {% if variable != None %}'{{ relation }}'{% else %}null::varchar(512){% endif %},
        '{{ invocation_id }}',
        CURRENT_USER
      )

{% endmacro %}


{% macro create_logging_table() %}

    create table if not exists {{ meta.get_logging_relation() }}
    (
       event_name       varchar(512),
       event_timestamp  {{dbt_utils.type_timestamp()}},
       event_schema     varchar(512),
       event_model      varchar(512),
       invocation_id    varchar(512),
       username    varchar(512)
    )

{% endmacro %}


{% macro log_run_start_event() %}
  {%- if target.user == 'dbt_user' -%}
    {{meta.log_event('run started')}}
  {%- endif -%}
{% endmacro %}


{% macro log_run_end_event() %}
  {%- if target.user == 'dbt_user' -%}
    {{meta.log_event('run completed')}}; commit;
  {%- endif -%}
{% endmacro %}


{% macro log_model_start_event() %}
  {%- if target.user == 'dbt_user' -%}
  {{meta.log_event(
      'model deployment started', this.schema, this.name
      )}}
  {%- endif -%}

{% endmacro %}


{% macro log_model_end_event() %}
  {%- if target.user == 'dbt_user' -%}
    {{meta.log_event(
        'model deployment completed', this.schema, this.name
        )}}
  {%- endif -%}
{% endmacro %}
