CREATE DATABASE IF NOT EXISTS hue;
CREATE DATABASE IF NOT EXISTS metastore;
drop user if exists hive;
CREATE USER hive IDENTIFIED BY 'hivepassword';
GRANT ALL PRIVILEGES ON metastore.* TO hive IDENTIFIED BY 'hivepassword';
