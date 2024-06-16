# Web App Template

Template repo for secure web apps

## Usage

1. Clone the repo:

```bash
git clone <repository-url> <project-name>
```

2. From the root (`<project-name>`), either:

    a. create a self-signed certificate using openssl (this can be done via WSL if on Windows)
    ```bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/certs/selfsigned.key -out nginx/certs/selfsigned.crt -subj '/CN=0.0.0.0'
    ```

    or

    b. copy your SSL certificate and key to [nginx/certs](./nginx/certs).

3. Run the appropriate setup script (from [setup_scripts](./setup_scripts/)):

    a. For Linux etc:

    ```bash
    chmod +x scripts/setup.sh
    ./scripts/setup.sh
    ```

    b. For Windows:

    ```powershell
    .\scripts\setup.ps1
    ```
