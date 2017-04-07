{% from "spark/map.jinja" import spark with context %}

include:
  - spark
  - spark.debug
  
{% if spark.master_role in grains.roles %}
{% with srv = spark.master_service %}
{{ srv }}-properties-file:
  file.managed:
    - name: {{ "%s/spark-defaults.conf"|format(spark.config_dir) }}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - source:
        - salt://files/spark-defaults.conf
        - salt://spark/files/spark-defaults.conf
        - salt://spark/files/spark-defaults-conf.jinja
        - salt://spark/files/spark-defaults.conf.template
        - {{ spark.real_root }}/conf/spark-defaults.conf.template

{{ srv }}-defaults:
  file.managed:
    - name: {{ "%s/%s"|format(spark.init_overrides, spark.master_service) }}
    - source: salt://spark/files/systemd.defaults.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - context:
        filetype: master

{{ srv }}-service:
  file.managed:
    - name: {{ "%s/%s.service"|format(spark.init_scripts, spark.master_service)}}
    - source: salt://spark/files/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - force: true
    - replace: true
    - mode: 644
    - context:
        user: {{ spark.user }}
        spark_home: {{ spark.real_root }}
        service_type: master
        service_name: {{ spark.master_service }}
        environment_file: {{ "%s/%s"|format(spark.init_overrides, spark.master_service) }}
  service.running:
    - name: {{ srv }}
    - enable: true
    - init_delay: 10
    - watch:
        - file: {{ srv }}-service
        - file: {{ srv }}-defaults
{% endwith %}
{% endif %}
