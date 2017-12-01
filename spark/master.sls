{% from "spark/map.jinja" import spark with context %}

include:
  - spark
  
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

{{ srv }}-spark-env.sh:
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

{{ srv }}-logging:
  file.managed:
    - name: {{ spark.config_dir }}/log4j.properties
    - source:
        - salt://spark/files/log4j-properties.jinja
        - file://{{ spark.real_root }}/conf/log4j.properties.template
    - template: jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644


{{ srv }}-defaults.conf:
  file.managed:
    - name: {{ spark.config_dir }}/spark-defaults.conf
    - template: jinja
    - source: salt://spark/files/spark-defaults.conf.jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644

{% endwith %}
