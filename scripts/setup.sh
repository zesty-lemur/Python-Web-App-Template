#!/bin/bash

generate_random_string() {
    echo $(openssl rand -hex 16)
}

read -p "Enter your SECRET_KEY (or press enter to generate a default): " SECRET_KEY
if [ -z "$SECRET_KEY" ]; then
    SECRET_KEY=$(generate_random_string)
    echo "Generated SECRET_KEY: $SECRET_KEY"
fi

read -p "Enter your PostgreSQL user (or press enter to use 'default_user'): " DB_USER
if [ -z "$DB_USER" ]; then
    DB_USER="default_user"
    echo "Using default DB_USER: $DB_USER"
fi

read -sp "Enter your PostgreSQL password (or press enter to generate a default): " DB_PASSWORD
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(generate_random_string)
    echo "Generated DB_PASSWORD: $DB_PASSWORD"
fi
echo

read -p "Enter your PostgreSQL database name (or press enter to use 'default_db'): " DB_NAME
if [ -z "$DB_NAME" ]; then
    DB_NAME="default_db"
    echo "Using default DB_NAME: $DB_NAME"
fi

DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@postgres_db/${DB_NAME}"

cat <<EOF > .env
SECRET_KEY=$SECRET_KEY
DATABASE_URL=$DATABASE_URL
EOF

docker-compose up -d --build