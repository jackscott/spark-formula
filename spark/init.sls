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
        - test -x pyspark 

spark-extract-archive:
  file.directory:
    - names:
        - {{ spark.prefix }}/spark
        - {{ spark.log_dir }}
        - {{ spark.config_dir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
  archive.extracted:
    - name: {{ spark.alt_root }}
    - source:
        - file://{{ archive_name }}
        - file://files/{{ archive_name }}
        - file:///tmp/{{ archive_name }}
    - user: {{ spark.user }}
    - group: {{ spark.user }}
    - if_missing: {{ spark.real_root }}
    - required:
        - file: spark-extract-archive
        - user: spark-preflight
  alternatives.install:
    - name: spark-home-link
    - link: {{ spark.alt_root }}
    - path: {{ spark.real_root }}
    - priority: 30
    - require:
        - archive: spark-extract-archive

spark-update-path:
  file.managed:
    - name: /etc/profile.d/apache-spark.sh
    - source: salt://spark/files/profile.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 644
