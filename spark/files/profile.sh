#!/bin/bash
{% from "spark/map.jinja" import spark with context %}
[[ ":$PATH:" == *":{{ spark.alt_root }}:"* ]] || export PATH=$PATH:{{ '%s/bin:%s/sbin'|format(spark.alt_root, spark.alt_root) }}
export SPARK_HOME={{ spark.alt_root }}
export SPARK_CONF_DIR={{ spark.config_dir }}
export SPARK_MASTER_HOST={{ spark.master_host }}
export SPARK_MASTER_PORT={{ spark.master_port }}
export SPARK_MASTER_URI=spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT
