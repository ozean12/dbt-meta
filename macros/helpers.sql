{% macro log_run_start() %}

  -- Log only if executed by dbt user
  {%- if target.name == 'prod' -%}
      -- Create tables if not already existing
      {{ meta.create_logging_table() }}

      -- Log start of execution
      {{ meta.log_run_start_event() }}

  {%- endif -%}

{% endmacro %}



{% macro log_run_end() %}

  -- Log only if executed by dbt user
  {%- if target.name == 'prod' -%}

      -- Log end of execution
      {{ meta.log_run_end_event() }}

  {%- endif -%}

{% endmacro %}


{% macro log_model_start() %}

  -- Log only if executed by dbt user
  {%- if target.name == 'prod' -%}

      -- Log start of model build
      {{ meta.log_model_start_event() }}

  {%- endif -%}

{% endmacro %}


{% macro log_model_end() %}

  -- Log only if executed by dbt user
  {%- if target.name == 'prod' -%}

      -- Log start of model build
      {{ meta.log_model_end_event() }}

  {%- endif -%}

{% endmacro %}
