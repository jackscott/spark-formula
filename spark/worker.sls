{% from "spark/map.jinja" import spark with context %}

  
include:
  - spark


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
        - salt://files/spark-defaults.conf
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

spark-update-configs:
  file.managed:
    - name: {{ spark.config_dir }}/spark-env.sh
    - source:
        - salt://spark/files/spark-env_sh.jinja
        # fallback to the default (empty) from the distribution
        - file://{{ spark.real_root }}/conf/spark-env.sh.template
    - template: jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644
    - context:
        is_worker: true
    - watch_in:
        - service: {{ spark.worker_service }}-enabled
        
spark-logging:
  file.managed:
    - name: {{ spark.config_dir }}/log4j.properties
    - source:
        - salt://spark/files/log4j-properties.jinja
        - file://{{ spark.real_root }}/conf/log4j.properties.template
    - template: jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644


spark-defaults:
  file.managed:
    - name: {{ spark.config_dir }}/spark-defaults.conf
    - template: jinja
    - source: salt://spark/files/spark-defaults.conf.jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644
    - watch_in:
        - service: {{ spark.worker_service }}-enabled
          
