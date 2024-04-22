#!/bin/bash

if [[ $SPARK_MODE == "master" ]]; then
  /opt/spark/sbin/start-master.sh
  DAEMON_CLASS=org.apache.spark.deploy.master.Master
elif [[ $SPARK_MODE == "worker" ]]; then
  /opt/spark/sbin/start-slave.sh $SPARK_MASTER_URL
  DAEMON_CLASS=org.apache.spark.deploy.worker.Worker
else
  echo "Invalid SPARK_MODE: $SPARK_MODE"
  exit 1
fi

while /opt/spark/sbin/spark-daemon.sh status $DAEMON_CLASS 1; do
  sleep 1
done
