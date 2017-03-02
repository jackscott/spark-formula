#!/bin/bash
{% from "spark/map.jinja" import spark with context %}
[[ ":$PATH:" == *":{{ spark.bin_dir }}:"* ]] || export PATH=$PATH:{{ spark.bin_dir }}
export SPARK_HOME={{ spark.real_root }}
export SPARK_CONF_DIR={{ spark.config_dir }}

