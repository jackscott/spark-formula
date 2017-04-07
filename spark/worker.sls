{% from "spark/map.jinja" import spark with context %}

{% if spark.worker_role in grains.roles %}
{{ spark.worker_service }}-properties-file:
  file.managed:
    - name: {{ "%s/spark-defaults.conf"|format(spark.config_dir) }}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - source:
        - salt://spark/files/spark-defaults.conf
        - salt://spark/files/spark-defaults-conf.jinja
        - salt://spark/files/spark-defaults.conf.template
        - {{ spark.real_root }}/conf/spark-defaults.conf.template

{{ spark.worker_service }}-service-defaults:
  file.managed:
    - name: {{ "%s/%s"|format(spark.init_overrides, spark.worker_service) }}
    - source: salt://spark/files/systemd.defaults.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - context:
        filetype: worker

{{ spark.worker_service }}-service:
  file.managed:
    - name: {{ "%s/%s.service"|format(spark.init_scripts, spark.worker_service)}}
    - source: salt://spark/files/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - context:
        user: {{ spark.user }}
        spark_home: {{ spark.real_root }}
        service_type: slave
        service_name: {{ spark.worker_service }}
        environment_file: {{ "%s/%s"|format(spark.init_overrides, spark.worker_service) }}

#
{{ spark.worker_service }}-enabled:
  service.running:
    - name: {{ spark.worker_service }}
    - enable: true
    - init_delay: 10
    - watch:
        - file: {{ spark.worker_role }}-service
        - file: {{ spark.worker_role }}-service-defaults
{% endif %}
