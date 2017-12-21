#!jinja
{# Formatting individual java properties #}
{% macro value_format(key, value) -%}
{%- if value is mapping -%}
  {%- for k,v in value.items() -%}
{{ value_format('%s.%s'|format(key, k), v) }}
{% endfor -%}
{%- elif value is not string and value is iterable -%}
{%- if 'extraJavaOptions' in key %}
{# nest the conditions to prevent extraJavaOptions from being rendered in the else block #}
{%- if value|length > 0 %}
{{ key }}   {% for val in value %}{% for k,v in val.items() %}-D {{ k|urlencode }}={{ v|urlencode }} {% endfor %}{% endfor %}
{%- endif %}
{% elif 'extraClassPath' in key %}
{# nest the conditions to prevent extraClassPath from being rendered in the else block #}
{%- if value|length > 0 %}
{{ key }}   {{ value|join(':') }}
{% endif %}
{% else %}
{{ key }}   {{ value|join(',') }}
{% endif %}
{%- elif value is none %}
# nil value set for {{ key }}={{ value }}
{%- elif value == True or value == False -%}
{{ key }}   {{ '%s'|format(value)|lower }}
{%- else -%}
{{ key }}   {{ value }}
{%- endif -%}
{%- endmacro %}

{% macro config_format(section, data) -%}
{#- Create a "section" of java properties where {{ section }}
is prepended to the keys in {{ data }} and handles top-level
properties (java properties with no dots '.') #}
  {%- if data is mapping -%}
    {%- for k,v in data.items() -%}
{{ value_format('%s.%s'|format(section, k), v) }}
{% endfor -%}
  {%- else -%}
{{ value_format(section, data) }}
  {% endif -%}
{%- endmacro %}


