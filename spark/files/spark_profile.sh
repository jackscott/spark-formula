#!/usr/bin/env bash
{% from "spark/map.jinja" import spark with context -%}
# WARNING!!   This file is managed by Salt
# All edits will be lost on the next highstate
export PATH=$PATH:{{ spark.bin_dir }}
