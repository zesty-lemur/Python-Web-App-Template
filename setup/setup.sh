#!/bin/bash

# Helper functions for colored text output
function write_colored_text() {
    local text=$1
    local color=$2
    case $color in
        blue) echo -e "\033[34m$text\033[0m" ;;
        green) echo -e "\033[32m$text\033[0m" ;;
        amber) echo -e "\033[33m$text\033[0m" ;;
        purple) echo -e "\033[35m$text\033[0m" ;;
        default) echo -e "\033[37m$text\033[0m" ;;
        *) echo "$text" ;;
    esac
}

# Random String
function new_random_string() {
    local length=${1:-32}
    head -c "$length" /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# Check if environment variables are already set
function check_env_vars() {
    local env_file_path=$1
    if [ -f "$env_file_path" ]; then
        cat "$env_file_path"
    else
        echo ""
    fi
}

# Check if the SSL Certificates exit in the right place
function check_certificate_files() {
    local cert_path="./nginx/certs"
    local cert_file="nginx-sslCertificate.crt"
    local key_file="nginx-sslKey.key"

    if [[ ! -f "$cert_path/$cert_file" || ! -f "$cert_path/$key_file" ]]; then
        write_colored_text "Certificate or key file is missing in $cert_path. Please ensure both $cert_file and $key_file are present." "red"
        exit 1
    fi
}


# Clear the terminal and print project details
function print_project_details() {
    clear
    write_colored_text "____    __    ____  _______ .______               ___      .______   .______          .___________. _______ .___  ___. .______    __          ___   .___________. _______ " "blue"
    write_colored_text "\   \  /  \  /   / |   ____||   _  \             /   \     |   _  \  |   _  \         |           ||   ____||   \/   | |   _  \  |  |        /   \  |           ||   ____|" "blue"
    write_colored_text " \   \/    \/   /  |  |__   |  |_)  |  ______   /  ^  \    |  |_)  | |  |_)  |  ______'---|  |----'|  |__   |  \  /  | |  |_)  | |  |       /  ^  \ '---|  |----'|  |__   " "blue"
    write_colored_text "  \            /   |   __|  |   _  <  |______| /  /_\  \   |   ___/  |   ___/  |______|   |  |     |   __|  |  |\/|  | |   ___/  |  |      /  /_\  \    |  |     |   __|  " "blue"
    write_colored_text "   \    /\    /    |  |____ |  |_)  |         /  _____  \  |  |      |  |                 |  |     |  |____ |  |  |  | |  |      |  '----./  _____  \   |  |     |  |____ " "blue"
    write_colored_text "    \__/  \__/     |_______||______/         /__/     \__\ | _|      | _|                 |__|     |_______||__|  |__| | _|      |_______/__/     \__\  |__|     |_______|" "blue"
    write_colored_text "\nCreated with ❤️ by Zesty Lemur - Licensed under GNU GPLv3. README @ https://github.com/zesty-lemur/Web-App-TemplateREADME.md" "default"
    echo ""
    echo ""
}


# Get user option
function get_user_option() {
    local options=("$@")
    local prompt=${options[-1]}
    unset options[-1]
    while true; do
        read -rp "$prompt" user_input
        if [[ " ${options[*]} " == *" $user_input "* ]]; then
            echo "$user_input"
            break
        else
            write_colored_text "Invalid option. Please select a valid option." "red"
        fi
    done
}

# Main script logic
print_project_details

# Check if env files already exist
dev_env_file_path="./setup/development/.env"
prod_env_file_path="./setup/production/.env"
dev_env_vars=$(check_env_vars "$dev_env_file_path")
prod_env_vars=$(check_env_vars "$prod_env_file_path")

# Determine the setup mode
if [[ -n "$dev_env_vars" && -n "$prod_env_vars" ]]; then
    mode=$(get_user_option "1" "2" "3" "It looks like you've already run the setup for both modes. Select from the following options:
1. Run setup for development and overwrite it
2. Run setup for production and overwrite it
3. Continue without overwriting and rebuild
Enter your choice [1/2/3]:")
    if [[ "$mode" == "3" ]]; then
        continue_mode=$(get_user_option "1" "2" "Which mode would you like to rebuild?
1. Development
2. Production
Enter your choice [1/2]:")
        if [[ "$continue_mode" == "1" ]]; then
            mode="development"
        else
            mode="production"
        fi
        cd "./setup/$mode" || exit
        docker-compose up -d --build
        exit
    fi
elif [[ -n "$dev_env_vars" ]]; then
    mode=$(get_user_option "1" "2" "It looks like you've already run the setup for development mode. Select from the following options:
1. Run setup for development and overwrite it
2. Run setup for production
Enter your choice [1/2]:")
elif [[ -n "$prod_env_vars" ]]; then
    mode=$(get_user_option "1" "2" "It looks like you've already run the setup for production mode. Select from the following options:
1. Run setup for production and overwrite it
2. Run setup for development
Enter your choice [1/2]:")
else
    mode=$(get_user_option "1" "2" "Select from the following options:
1. Run setup for development
2. Run setup for production
Enter your choice [1/2]:")
fi

# Set the mode based on user choice
if [[ "$mode" == "1" ]]; then
    mode="development"
    env_file_path="$dev_env_file_path"
    read -rp "[Option:] Use randomly-generated values for SECRET_KEY, DB_USER, POSTGRES_PASSWORD, DB_NAME? [y/N]" use_random_defaults
    use_random_defaults=${use_random_defaults,,}  # tolower
    use_random_defaults=$([[ "$use_random_defaults" == "y" ]] && echo "true" || echo "false")
else
    mode="production"
    env_file_path="$prod_env_file_path"
    use_random_defaults="false"
fi

# Check if the certificates are present for production builds
if [[ "$mode" == "production" ]]; then
    check_certificate_files
fi

# Get the app name from the user
read -rp "[Option:] Provide a name for your app: " app_name
app_name=${app_name// /-}
write_colored_text "App Name: $app_name" "green"

# Insert a blank line
echo ""

# Handle environment variable setup
declare -A env_vars=(
    ["SECRET_KEY"]=""
    ["DB_USER"]=""
    ["POSTGRES_PASSWORD"]=""
    ["DB_NAME"]=""
)

for var in "${!env_vars[@]}"; do
    if [[ "$use_random_defaults" == "true" && "$mode" == "development" ]]; then
        env_vars[$var]=$(new_random_string)
        write_colored_text "$var: ${env_vars[$var]}" "amber"
    else
        if [[ "$mode" == "production" && ( "$var" == "SECRET_KEY" || "$var" == "POSTGRES_PASSWORD" ) ]]; then
            read -rp "[Option:] Specify a value for $var or press Enter to generate a default: " user_input
        else
            read -rp "[Option:] Specify a value for $var: " user_input
        fi
        if [[ -z "$user_input" ]]; then
            env_vars[$var]=$(new_random_string)
            write_colored_text "$var: ${env_vars[$var]}" "amber"
        else
            env_vars[$var]=$user_input
            write_colored_text "$var: ${env_vars[$var]}" "green"
        fi
    fi
    # Insert a blank line between each option
    echo ""
done

# Write to the .env file
for var in "${!env_vars[@]}"; do
    echo "$var=${env_vars[$var]}" >> "$env_file_path"
done

# Set the 'container_name' value in the docker-compose files
compose_file_path="./setup/$mode/docker-compose.yml"
sed -i "s/container_name: flask_app_dev/container_name: ${app_name}_dev/" "$compose_file_path"
sed -i "s/container_name: flask_app_prod/container_name: ${app_name}_prod/" "$compose_file_path"

# Run the appropriate docker-compose file to build the app
cd "./setup/$mode" || exit
docker-compose up -d --build
