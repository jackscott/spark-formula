{% from "spark/map.jinja" import spark with context %}

spark-preflight:
  group.present:
    - name: {{ spark.user }}
  user.present:
    - name: {{ spark.user }}
    - system: true
    - fullname: "Apache Spark user"
    - gid: {{ spark.user }}
    - system: True
  pkg.installed:
    - pkgs:
        - default-jre
    - unless:
        - which java
    
{% set archive_name = "%s.%s"|format(spark.archive_name, spark.archive_type) %}
spark-cache-archive:
  file.managed:
    - name: {{ "/tmp/%s"|format(archive_name) }}
    - source:
        - salt://{{ archive_name  }}        
        - salt://files/{{ archive_name  }}
        - {{ spark.archive_url }}
    - source_hash: {{ spark.archive_hash }}
    - user: root
    - group: root
    - unless:
        - test -f {{ "/tmp/%s"|format(archive_name) }}

spark-extract-archive:
  file.directory:
    - names:
        - {{ spark.log_dir }}
        - {{ spark.config_dir }}
        - {{ spark.work_dir }}
        - {{ spark.pid_dir }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 755
    - makedirs: true
      
  archive.extracted:
    - name: {{ spark.prefix }}
    - source:
        - file:///tmp/{{ archive_name }}
        - {{ spark.archive_url }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - if_missing: {{ spark.alt_root }}
    - archive_format: tar
    - require:
        - file: spark-cache-archive
          

spark-update-path:
  alternatives.install:
    - name: spark-home-link
    - link: {{ spark.alt_root }}
    - path: {{ spark.real_root }}
    - priority: 999
    - require:
        - archive: spark-extract-archive

spark-setup-profile:
  file.managed:
    - name: /etc/profile.d/spark.sh
    - source: salt://spark/files/profile.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 644

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
