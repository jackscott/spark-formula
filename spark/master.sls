{% from "spark/map.jinja" import spark with context %}

{% if spark.master_role in grains.roles %}

{% endif %}
