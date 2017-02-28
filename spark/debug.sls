{% from "spark/map.jinja" import config with context %}

spark-debugin:
  file.managed:
    - name: /tmp/spark-formula.log
    - contents: |
        {% for k,v in config.items() %}
        {{ k }} => {{ v }}
        {% endfor %}
