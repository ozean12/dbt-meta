{#
  iterate through node graph to
    - filter for models
    - filter for tests
      - distinguish between schema and data tests
      - find related models that are tested by each test
    - compile insertion values
    - insert to tests and models tables
#}
{% macro log_test_coverage() %}
    {% set nodes = graph.nodes %}
    {% set model_values = [] %}
    {% set test_values = [] %}
    {% set insert_timestamp = modules.datetime.datetime.now() %}

    {% for nodekey in nodes.keys() %}
        {% if nodes[nodekey]['resource_type'] == 'model' %}
            {% set value = meta.create_model_record(nodekey, nodes[nodekey]['schema'], nodes[nodekey]['name'], insert_timestamp) %}
            {% do model_values.append(value) %}
        {% endif %}
        {% if nodes[nodekey]['resource_type'] == 'test' %}
            {% if 'schema_test' in nodes[nodekey]['fqn'] and nodes[nodekey]['depends_on']['nodes'] %}
                {% for dependency in nodes[nodekey]['depends_on']['nodes'] %}
                    {% set value = meta.create_test_record(nodekey, nodes[nodekey]['name'], 'schema_test', dependency, insert_timestamp) %}
                    {% do test_values.append(value) %}
                {% endfor %}
            {% endif %}
            {% if 'data_test' in nodes[nodekey]['fqn'] %}
                {% for dependency in nodes[nodekey]['depends_on']['nodes'] %}
                    {% set value = meta.create_test_record(nodekey, nodes[nodekey]['name'], 'data_test', dependency, insert_timestamp) %}
                    {% do test_values.append(value) %}
                {% endfor %}
            {% endif %}
        {% endif %}
    {% endfor %}

    {{ meta.insert_models(','.join(model_values)) }}
    {{ meta.insert_tests(','.join(test_values)) }}
    commit;

{% endmacro %}
