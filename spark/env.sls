{% from "spark/map.jinja" import spark with context %}
{% with archive_name = "%s.%s"|format(spark.archive_name, spark.archive_type) %}
{% set artifact = '/tmp/%s'|format(archive_name) %}
{% set pub_key = '/tmp/spark-pub-keys.asc' %}

spark-env-setup:
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
  cmd.run:
    - name: |
        curl -s https://archive.apache.org/dist/spark/KEYS -o {{ pub_key }}
    - require:
        - pkg: spark-env-setup
        - user: spark-env-setup

install-gpg:
  pkg.installed:
    - pkgs:
        - gpg
        - python-gnupg
    - require:
        - cmd: spark-env-setup
          
{{ '%s.asc'|format(artifact) }}:  
  file.managed:
    - name: {{ '%s.asc'|format(artifact) }}
    - source: {{ spark.archive_hash_url }}
    - skip_verify: true
      
import-apache-keyes:
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
        - test -d {{ spark.real_root }}

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
        - file://{{ artifact }}
        - salt://{{ archive_name }}
        - {{ spark.archive_url }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - if_missing: {{ spark.alt_root }}
    - archive_format: tar
    - require:
        - cmd: spark-cache-archive
          

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

      
{% endwith %}
