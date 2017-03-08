{% from "spark/map.jinja" import spark with context %}

{% if spark.worker_role in grains.roles %}
spark-worker-defaults:
  file.managed:
    - name: {{ "%s/%s"|format(spark.init_overrides, spark.worker_service) }}
    - source:
        - salt://files/systemd.defaults.jinja
        - salt://spark/files/systemd.defaults.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        filetype: worker

spark-worker-service:
  file.managed:
    - name: {{ "%s/%s.service"|format(spark.init_scripts, spark.worker_service)}}
    - source: salt://spark/files/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        user: {{ spark.user }}
        spark_home: {{ spark.real_root }}
        service_type: worker
        service_name: {{ spark.worker_service }}
        environment_file: {{ "%s/%s"|format(spark.init_overrides, spark.worker_service) }}

{{ spark.worker_service }}-service:
  service.running:
    - name: {{ spark.worker_service }}
    - enable: true
    - init_delay: 10
    - watch:
        - file: spark-worker-service
        - file: spark-worker-defaults
{% endif %}
