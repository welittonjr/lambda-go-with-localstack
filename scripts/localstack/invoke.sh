#!/bin/bash

ENDPOINT_LOCALSTACK="http://localhost:4566"
FUNCTION_NAME="lambidinha"
PAYLOAD=$(cat ./scripts/localstack/payload.json)


aws --endpoint-url=$ENDPOINT_LOCALSTACK lambda invoke \
    --function-name $FUNCTION_NAME \
    --payload "$PAYLOAD" response.json \
    --log-type Tail --query 'LogResult' --output text |  base64 -d

# Verifique se o arquivo `response.json` existe
if [ -f response.json ]; then
    # Use o cat para imprimir o conteúdo do arquivo
    echo "Reponse"
    cat response.json && echo
fi