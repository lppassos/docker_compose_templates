<#
.SYNOPSIS

Describes a topic in the kafka broker

.DESCRIPTION

Describes a topic with the given name in the kafka broker

.PARAMETER Name

Name to give to the topic

#>
Param(
    [string]$Name
)

d
docker-compose exec kafka kafka-topics --bootstrap-server localhost:9092 `
    --describe --topic $Name
