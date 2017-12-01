#!jinja
{# Formatting individual java properties #}
{% macro value_format(key, value) -%}
{%- if value is mapping -%}
  {%- for k,v in value.items() -%}
{{ value_format('%s.%s'|format(key, k), v) }}
{% endfor -%}
{%- elif value is not string and value is iterable -%}
{{ key }}={{ value|join(',') }}
{%- elif value is none %}
# nil value set for {{ key }}
{%- elif value == True or value == False -%}
{{ key }}={{ '%s'|format(value)|lower }}
{%- else -%}
{{ key }}={{ value }}
{%- endif -%}
{%- endmacro %}

{# Create a "section" of java properties where {{ section }}
is prepended to the keys in {{ data }} and handles top-level
properties (java properties with no dots '.') #}
{% macro config_format(section, data) -%}
  {%- if data is mapping -%}
    {%- for k,v in data.items() -%}
{{ value_format('%s.%s'|format(section, k), v) }}
{% endfor -%}
  {%- else -%}
{{ value_format(section, data) }}
  {% endif -%}
{%- endmacro %}

