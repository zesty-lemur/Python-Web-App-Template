$banner = @"
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
"@

Write-Host $banner
Write-Host
function New-RandomString {
    param (
        [int]$length = 32
    )
    $bytes = New-Object byte[] $length
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes)
    [BitConverter]::ToString($bytes) -replace '-', ''
}
Write-Host
$SECRET_KEY = Read-Host -Prompt 'Enter your SECRET_KEY (or press enter to generate a default)'
if ([string]::IsNullOrEmpty($SECRET_KEY)) {
    $SECRET_KEY = New-RandomString
    Write-Host "Generated SECRET_KEY: $SECRET_KEY"
}
Write-Host
$DB_USER = Read-Host -Prompt 'Enter your PostgreSQL user (or press enter to use "default_user")'
if ([string]::IsNullOrEmpty($DB_USER)) {
    $DB_USER = "default_user"
    Write-Host "Using default DB_USER: $DB_USER"
}
Write-Host
$POSTGRES_PASSWORD = Read-Host -Prompt 'Enter your PostgreSQL password (or press enter to generate a default)' -AsSecureString
if ($POSTGRES_PASSWORD.Length -eq 0) {
    $POSTGRES_PASSWORD = New-RandomString
    Write-Host "Generated POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
} else {
    $POSTGRES_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($POSTGRES_PASSWORD))
}
Write-Host
$DB_NAME = Read-Host -Prompt 'Enter your PostgreSQL database name (or press enter to use "default_db")'
if ([string]::IsNullOrEmpty($DB_NAME)) {
    $DB_NAME = "default_db"
    Write-Host "Using default DB_NAME: $DB_NAME"
}
Write-Host
$DATABASE_URL = "postgresql://${DB_USER}:${POSTGRES_PASSWORD}@postgres_db/${DB_NAME}"
Write-Host
@"
SECRET_KEY=$SECRET_KEY
DATABASE_URL=$DATABASE_URL
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DB_USER=$DB_USER
DB_NAME=$DB_NAME
"@ > .env

Write-Host
docker-compose up -d --build