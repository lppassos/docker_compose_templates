# Hadoop cluster with a Spark client

> [!NOTE]
> This docker-compose is quite large and can take a lot of memory.
> Make sure the amount of memory assigned to docker containers is limited
> so that you don't have stability issues in your host machine.

This docker compose starts an entire hadoop cluster with the following
services:

* [HDFS](hdfs://localhost:9870)
* [Hive](http://localhost:10002)
* [Hue](http://localhost:8888)
* [Yarn](http://localhost:8088)
* [Spark](http://localhost:8080)

It also includes a mysql image to store the hive catalog.

