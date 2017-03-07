#!/usr/bin/env bats

source /etc/profile.d/apache-spark.sh

@test "spark-shell is installed" {
			test -x /opt/spark/spark-2.1.0-bin-hadoop/bin/spark-shell
}

@test "pyspark is installed" {
  [[ "$(type -t /opt/spark/spark-2.1.0-bin-without-hadoop/bin/pyspark)" == "file" ]]
				test -x /opt/spark/spark-2.1.0-bin-without-hadoop/bin/pyspark
}
