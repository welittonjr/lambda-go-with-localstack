#!/bin/bash

CONTAINER_NAME="go-lambda"

if docker ps --filter name="$CONTAINER_NAME" -q >/dev/null; then
  echo "Criando a pasta vendor..."

  # Verifica se a pasta "vendor" já existe antes de prosseguir
  if [ -d "vendor" ]; then
    echo "A pasta vendor já existe. Removendo..."
    rm -rf "vendor"
  fi

  mkdir -p "vendor"

  # Verifica se o arquivo go.mod existe antes de continuar
  if [ -f "go.mod" ]; then
    echo "Baixando as dependências do projeto..."
    # docker exec -it "$CONTAINER_NAME" sh -c "go mod download"
    docker exec -it "$CONTAINER_NAME" sh -c "go mod vendor -v"
    docker exec -it "$CONTAINER_NAME" sh -c "chown -R 1000:1000 vendor"
  else
    echo "Arquivo go.mod não encontrado. Certifique-se de que esteja no diretório do projeto Go."
  fi

else
  echo "O contêiner não está em execução."
fi
