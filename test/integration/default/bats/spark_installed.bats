#!/usr/bin/env bats

source /etc/profile.d/spark.sh

@test "spark-shell is installed" {
			test -x /opt/spark/spark-2.1.0-bin-hadoop2.7/bin/spark-shell
}

@test "pyspark is installed" {
  [[ "$(type -t /opt/spark/spark-2.1.0-bin-hadoop2.7/bin/pyspark)" == "file" ]]
				test -x /opt/spark/spark-2.1.0-bin-hadoop2.7/bin/pyspark
}

@test "start-master.sh is on our path" {
			command -v start-master.sh
}
