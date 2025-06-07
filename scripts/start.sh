#!/bin/bash

set -e

echo "Subindo containers"
docker-compose up -d --build

echo "Instalando gems"
docker-compose exec backend bundle install

echo "Criando e migrando banco de dados"
docker-compose exec backend bundle exec rails db:setup

echo "Projeto iniciado com sucesso!"
echo "Acesse: http://localhost:3000"
