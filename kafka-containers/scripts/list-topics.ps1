<#
.SYNOPSIS

Lists all the topics in the kafka broker

.DESCRIPTION

Lists all the topics in the kafka broker

#>

docker-compose exec kafka kafka-topics --bootstrap localhost:9092 `
    --list
