#!/bin/bash

banner=$(cat << EOM
 _    _        _        ___                  _____                        _         _        
| |  | |      | |      / _ \                |_   _|                      | |       | |       
| |  | |  ___ | |__   / /_\ \ _ __   _ __     | |  ___  _ __ ___   _ __  | |  __ _ | |_  ___ 
| |/\| | / _ \| '_ \  |  _  || '_ \ | '_ \    | | / _ \| '_ ` _ \ | '_ \ | | / _` || __|/ _ \
\  /\  /|  __/| |_) | | | | || |_) || |_) |   | ||  __/| | | | | || |_) || || (_| || |_|  __/
 \/  \/  \___||_.__/  \_| |_/| .__/ | .__/    \_/ \___||_| |_| |_|| .__/ |_| \__,_| \__|\___|
                             | |    | |                           | |                        
                             |_|    |_|                           |_|                        
 _____        _                   _____              _         _                             
/  ___|      | |                 /  ___|            (_)       | |                            
\ `--.   ___ | |_  _   _  _ __   \ `--.   ___  _ __  _  _ __  | |_                           
 `--. \ / _ \| __|| | | || '_ \   `--. \ / __|| '__|| || '_ \ | __|                          
/\__/ /|  __/| |_ | |_| || |_) | /\__/ /| (__ | |   | || |_) || |_                           
\____/  \___| \__| \__,_|| .__/  \____/  \___||_|   |_|| .__/  \__|                          
                         | |                           | |                                   
                         |_|                           |_|                                   
EOM
)

generate_random_string() {
    echo $(openssl rand -hex 16)
}

# Function to generate SSL certificate and key
generate_ssl_certificate() {
    mkdir -p nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/ssl/nginx-selfsigned.key -out nginx/ssl/nginx-selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"
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

read -sp "Enter your PostgreSQL password (or press enter to generate a default): " POSTGRES_PASSWORD
if [ -z "$POSTGRES_PASSWORD" ]; then
    POSTGRES_PASSWORD=$(generate_random_string)
    echo "Generated POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
fi
echo

read -p "Enter your PostgreSQL database name (or press enter to use 'default_db'): " DB_NAME
if [ -z "$DB_NAME" ]; then
    DB_NAME="default_db"
    echo "Using default DB_NAME: $DB_NAME"
fi

DATABASE_URL="postgresql://${DB_USER}:${POSTGRES_PASSWORD}@postgres_db/${DB_NAME}"

cat <<EOF > .env
SECRET_KEY=$SECRET_KEY
DATABASE_URL=$DATABASE_URL
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DB_USER=$DB_USER
DB_NAME=$DB_NAME
EOF

docker-compose up -d --build