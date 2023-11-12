#!/bin/bash

CONTAINER_NAME="go-lambda"
LAMBDA_FILE="lambda"
LAMBDA_FILE_ZIP="lambda-full.zip"
ENDPOINT_LOCALSTACK="http://localhost:4566"
BUCKET_S3_NAME="lambdas3"
FUNCTION_NAME="lambidinha"
REGION="us-east-2"

# Verifica se o contêiner está em execução
if docker ps --filter name="$CONTAINER_NAME" -q >/dev/null; then
    if [ -f $LAMBDA_FILE ]; then
        rm $LAMBDA_FILE
    fi
    if [ -f $LAMBDA_FILE_ZIP ]; then
        rm $LAMBDA_FILE_ZIP
    fi

    if docker ps --filter name="$CONTAINER_LOCALSTACK" -q >/dev/null; then
        # Compila o código Lambda
        docker exec -it "$CONTAINER_NAME" sh -c "GOOS=linux go build -o $LAMBDA_FILE ./cmd/main.go"
        # Empacota o código Lambda em um arquivo ZIP
        docker exec -it "$CONTAINER_NAME" sh -c "zip -r $LAMBDA_FILE_ZIP $LAMBDA_FILE"

        # Permissões para os arquivos
        docker exec -it "$CONTAINER_NAME" sh -c "chown -R 1000:1000 $LAMBDA_FILE"
        docker exec -it "$CONTAINER_NAME" sh -c "chown -R 1000:1000 $LAMBDA_FILE_ZIP"

        # Verifica se o bucket S3 existe
        if aws --endpoint-url=$ENDPOINT_LOCALSTACK s3 ls s3://$BUCKET_S3_NAME | grep "$LAMBDA_FILE_ZIP" 2>&1 >/dev/null; then
            echo "O bucket S3 já existe."
        else
            echo "O bucket S3 não existe. Criando..."
            aws --endpoint-url=$ENDPOINT_LOCALSTACK s3 mb s3://$BUCKET_S3_NAME
        fi

        # Copia o código Lambda para o bucket S3
        aws --endpoint-url=$ENDPOINT_LOCALSTACK s3 cp $LAMBDA_FILE_ZIP s3://$BUCKET_S3_NAME/$LAMBDA_FILE_ZIP


        # Verifica se a função Lambda existe
        if aws --endpoint-url=$ENDPOINT_LOCALSTACK lambda get-function --function-name $FUNCTION_NAME | grep "FunctionArn" >/dev/null; then
            # Remove a função Lambda existente
            aws --endpoint-url=$ENDPOINT_LOCALSTACK lambda delete-function --function-name $FUNCTION_NAME
        fi

        # Cria a função Lambda
        # handler nome do arquivo executavel
        aws --endpoint-url=$ENDPOINT_LOCALSTACK lambda create-function \
            --function-name $FUNCTION_NAME \
            --runtime go1.x \
            --handler $LAMBDA_FILE \
            --memory-size 128 \
            --code S3Bucket=$BUCKET_S3_NAME,S3Key=$LAMBDA_FILE_ZIP \
            --role arn:aws:iam::000000000000:role/lambidinha-role

        # Imprime o nome da função Lambda criada
        echo "A função Lambda foi criada com sucesso."
        echo "Nome da função Lambda: $FUNCTION_NAME"
    else
        echo "O Localstack não está em execução."
    fi
else
    echo "O contêiner não está em execução."
fi
