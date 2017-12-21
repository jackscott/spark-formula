{% from "spark/map.jinja" import spark with context %}
{% with archive_name = "%s.%s"|format(spark.archive_name, spark.archive_type) %}
{% set artifact = '/tmp/%s'|format(archive_name) %}
{% set pub_key = '/tmp/spark-pub-keys.asc' %}

{% set pkg_deps = spark.get('package_deps', [])  %}
{% set java_deps = spark.get('java_deps', [])  %}

bootstrap-spark:
  group.present:
    - name: {{ spark.user }}
  user.present:
    - name: {{ spark.user }}
    - system: true
    - fullname: "Apache Spark user"
    - gid: {{ spark.user }}
    - system: True
  pkg.installed:
    - pkgs: {{ pkg_deps | json }}
  cmd.run:
    - name: |
        curl -s https://archive.apache.org/dist/spark/KEYS -o {{ pub_key }}
    - require:
        - pkg: bootstrap-spark
        - user: bootstrap-spark

          
{{ '%s.asc'|format(artifact) }}:  
  file.managed:
    - name: {{ '%s.asc'|format(artifact) }}
    - source: {{ spark.archive_hash_url }}
    - skip_verify: true

check-for-java:
  pkg.installed:
    - pkgs: {{ java_deps | json }}
    - unless:
        - which java
    
import-apache-keys:
  module.run:
    - name: gpg.import_key
    - kwargs:
        user: salt
        filename: {{ pub_key }}
    - watch_in:
      - cmd: spark-cache-archive

spark-cache-archive:
  file.managed:
    - name: {{ artifact }}
    - source: {{ spark.archive_url }}
    - skip_verify: true
    - unless:
        - test -f {{ artifact }}

  cmd.run:
    - name: |
        gpg --homedir=/etc/salt/gpgkeys --verify {{ '%s.asc'|format(artifact) }} {{ artifact }}
    - require:
        - file: {{ '%s.asc'|format(artifact) }}
        - file: spark-cache-archive
          
spark-extract-archive:
  file.directory:
    - names:
        - {{ spark.log_dir }}
        - {{ spark.work_dir }}
        - {{ spark.pid_dir }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 755
    - makedirs: true
      
  archive.extracted:
    - name: {{ spark.prefix }}
    - source:
        - file://{{ artifact }}
        - salt://{{ archive_name }}
        - {{ spark.archive_url }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - if_missing: {{ spark.real_root }}
    - archive_format: tar
    - require:
        - cmd: spark-cache-archive

spark-setup-config:
  file.directory:
    - name: {{ spark.config_dir }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 755
    - unless:
        - test -d {{ spark.config_dir }}
    - require:
        - archive: spark-extract-archive
        - alternatives: spark-update-path
          
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

spark-env:
  file.managed:
    - name: {{ spark.config_dir }}/spark-env.sh
    - source:
        - salt://spark/files/spark-env_sh.jinja
        # fallback to the default (empty) from the distribution
        - file://{{ spark.real_root }}/conf/spark-env.sh.template
    - template: jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 755
    - require:
        - file: spark-setup-config
    - context:
        is_worker: true

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
    - require:
        - file: spark-setup-config

spark-defaults:
  file.managed:
    - name: {{ "%s/spark-defaults.conf"|format(spark.config_dir) }}
    - template: jinja
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - mode: 644
    - force: true
    - replace: true
    - require:
        - file: spark-setup-config
          
    - source:
        - salt://spark/files/spark-defaults.conf.jinja
        - salt://spark/files/spark-defaults.conf.template
        - {{ spark.real_root }}/conf/spark-defaults.conf.template

{% endwith %}
