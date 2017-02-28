#!/usr/bin/env bats

@test "spark-shell is in our \$PATH" {
  command -v spark-shell
}

@test "pyspark is in our \$PATH" {
  command -v pyspark
}
