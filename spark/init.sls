{% from "spark/map.jinja" import spark with context %}

spark-preflight:
  group.present:
    - name: {{ spark.user }}

spark-cache-archive:
  file.managed:
    name: /tmp/{{ spark.archive_name }}
    source: {{ spark.archive_url }}
    source_hash: {{ spark.archive_hash }}
    user: root
    group: root
    unless:
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
        
    
