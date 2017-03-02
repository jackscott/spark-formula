{% from "spark/map.jinja" import spark with context %}

spark-debugin:
  file.managed:
    - name: /tmp/spark-formula.log
    - contents: |
        {% for k,v in spark.items() %}
        {{ k }} => {{ v }}
        {% endfor %}
