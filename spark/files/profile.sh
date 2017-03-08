#!/bin/bash
{% from "spark/map.jinja" import spark with context %}
[[ ":$PATH:" == *":{{ spark.real_root }}:"* ]] || export PATH=$PATH:{{ '%s/bin:%s/sbin'|format(spark.real_root, spark.real_root) }}
export SPARK_HOME={{ spark.real_root }}
export SPARK_CONF_DIR={{ spark.config_dir }}

