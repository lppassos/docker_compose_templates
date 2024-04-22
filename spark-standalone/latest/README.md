# Simple Spark Cluster

This very basic spark cluster just has a master and a worker node.
You can place your source files in the same directotry as the docker-compose file
and they will be available in the scripts directory within the docker container

To execute a script you can do

```
docker-compose exec -it spark spark-submit.sh scripts/my-script.py
```

I typically just include these services in a different docker-compose file on
my projects to have access to actual data that I need to process, such as:

* A Kafka Broker instance
* Some database instance

