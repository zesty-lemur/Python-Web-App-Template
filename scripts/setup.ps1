function Generate-RandomString {
    param (
        [int]$length = 32
    )
    $bytes = New-Object byte[] $length
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes)
    [BitConverter]::ToString($bytes) -replace '-', ''
}

$SECRET_KEY = Read-Host -Prompt 'Enter your SECRET_KEY (or press enter to generate a default)'
if ([string]::IsNullOrEmpty($SECRET_KEY)) {
    $SECRET_KEY = Generate-RandomString
    Write-Host "Generated SECRET_KEY: $SECRET_KEY"
}

$DB_USER = Read-Host -Prompt 'Enter your PostgreSQL user (or press enter to use "default_user")'
if ([string]::IsNullOrEmpty($DB_USER)) {
    $DB_USER = "default_user"
    Write-Host "Using default DB_USER: $DB_USER"
}

$DB_PASSWORD = Read-Host -Prompt 'Enter your PostgreSQL password (or press enter to generate a default)' -AsSecureString
if ($DB_PASSWORD.Length -eq 0) {
    $DB_PASSWORD = Generate-RandomString
    Write-Host "Generated DB_PASSWORD: $DB_PASSWORD"
} else {
    $DB_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DB_PASSWORD))
}

$DB_NAME = Read-Host -Prompt 'Enter your PostgreSQL database name (or press enter to use "default_db")'
if ([string]::IsNullOrEmpty($DB_NAME)) {
    $DB_NAME = "default_db"
    Write-Host "Using default DB_NAME: $DB_NAME"
}

$DATABASE_URL = "postgresql://${DB_USER}:${DB_PASSWORD}@postgres_db/${DB_NAME}"

@"
SECRET_KEY=$SECRET_KEY
DATABASE_URL=$DATABASE_URL
"@ > .env

docker-compose up -d --build