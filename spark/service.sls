{% from "spark/map.jinja" import spark with context %}

  
include:
  - spark.env

{% set roles = salt['grains.get']('roles', []) %}
{% if spark.worker_service in roles %}
{% set svcname  = spark.worker_service %}
{% elif spark.master_service in roles %}
{% set svcname  = spark.master_service %}
{% endif %}

{{ svcname }}-service:
  file.managed:
    - name: {{ "%s/%s.service"|format(spark.init_scripts, svcname)}}
    - source: salt://spark/files/systemd.service.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - force: true
    - replace: true
    - require:
        - sls: spark.env
    - context:
        user: {{ spark.user }}
        spark_home: {{ spark.real_root }}
        service_type: slave
        service_name: {{ svcname }}
        environment_file: {{ '%s/spark-env.sh'|format(spark.config_dir )}}

#
{{ svcname }}-enabled:
  service.running:
    - name: {{ svcname }}
    - enable: true
    - init_delay: 10
    - require:
        - sls: spark.env
    - watch:
        - file: {{ svcname }}-service
        - file: {{ svcname }}-defaults.conf

{{ svcname }}-spark-env.sh:
  file.exists:
    - require:
        - sls: spark.env
    - name: {{ spark.config_dir }}/spark-env.sh

{{ svcname }}-logging:
  file.exists:
    - require:
        - sls: spark.env
    - name: {{ spark.config_dir }}/log4j.properties

{{ svcname }}-defaults.conf:
  file.exists:
    - require:
        - sls: spark.env
    - name: {{ spark.config_dir }}/spark-defaults.conf


/etc/default/{{ svcname }}:
  cmd.run:
    - name: |
        cp {{ spark.config_dir }}/spark-env.sh /etc/default/{{ svcname  }}
        sed -i 's/export //g' /etc/default/{{ svcname }}
        chown root:root /etc/default/{{ svcname }}
        chmod 644 /etc/default/{{ svcname }}
      
