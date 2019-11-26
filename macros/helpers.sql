{% macro log_run_start() %}


  {%- if target.user == 'dbt_user' -%}
      -- Log only if executed by dbt user

      -- Create tables if not already existing
      {{ meta.create_logging_table() }}

      -- Log start of execution
      {{ meta.log_run_start_event() }}
  {%- else -%}

  {%- endif -%}

{% endmacro %}



{% macro log_run_end() %}


  {%- if target.user == 'dbt_user' -%}
      -- Log only if executed by dbt user

      -- Log end of execution
      {{ meta.log_run_end_event() }}

  {%- endif -%}

{% endmacro %}


{% macro log_model_start() %}


  {%- if target.user == 'dbt_user' -%}
      -- Log only if executed by dbt user

      -- Log start of model build
      {{ meta.log_model_start_event() }}

  {%- endif -%}

{% endmacro %}


{% macro log_model_end() %}


  {%- if target.user == 'dbt_user' -%}
      -- Log only if executed by dbt user

      -- Log start of model build
      {{ meta.log_model_end_event() }}

  {%- endif -%}

{% endmacro %}
