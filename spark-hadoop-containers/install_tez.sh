sleep 10
export HADOOP_CONF_DIR=/hive_conf
cd /opt/tez
hdfs dfs -mkdir -p /opt/tez
hdfs dfs -copyFromLocal /opt/tez/* /opt/tez
