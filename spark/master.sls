{% from "spark/map.jinja" import spark with context %}

include:
  - spark
  - spark.debug
  
{% if spark.master_role in grains.roles %}
spark-master-defaults:
  file.managed:
    - name: {{ "%s/%s"|format(spark.init_overrides, spark.master_service) }}
    - source:
        - salt://files/systemd.defaults.jinja
        - salt://spark/files/systemd.defaults.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        filetype: master

spark-master-service:
  file.managed:
    - name: {{ "%s/%s.service"|format(spark.init_scripts, spark.master_service)}}
    - source: salt://spark/files/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        user: {{ spark.user }}
        spark_home: {{ spark.real_root }}
        service_type: master
        service_name: {{ spark.master_service }}
        environment_file: {{ "%s/%s"|format(spark.init_overrides, spark.master_service) }}
  service.running:
    - name: {{ spark.master_service }}
    - enable: true
    - init_delay: 10
    - watch:
        - file: spark-master-service
        - file: spark-master-defaults
{% endif %}
