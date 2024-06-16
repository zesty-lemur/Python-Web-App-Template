# Start with the official Nginx image
FROM nginx:alpine

# Copy custom Nginx configuration file
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Copy SSL certificates
COPY ./nginx/certs/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
COPY ./nginx/certs/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key