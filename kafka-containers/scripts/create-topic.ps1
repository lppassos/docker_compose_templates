<#
.SYNOPSIS

Creates a topic in the kafka broker

.DESCRIPTION

Creates a topic with the given name in the kafka broker

.PARAMETER Name

Name to give to the topic

#>
Param(
    [string]$Name
)

docker-compose exec kafka kafka-topics --bootstrap-server localhost:9092 `
    --create --topic $name
