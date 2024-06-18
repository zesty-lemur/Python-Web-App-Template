# Helper functions for colored text output
function Write-ColoredText {
    param (
        [string]$text,
        [string]$color
    )
    switch ($color) {
        "blue" { Write-Host $text -ForegroundColor Blue }
        "green" { Write-Host $text -ForegroundColor Green }
        "amber" { Write-Host $text -ForegroundColor DarkYellow }
        "purple" { Write-Host $text -ForegroundColor Magenta }
        "default" { Write-Host $text -ForegroundColor White }
        default { Write-Host $text }
    }
}

function New-RandomString {
    param (
        [int]$length = 32
    )
    $bytes = New-Object byte[] $length
    (New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes)
    [BitConverter]::ToString($bytes) -replace '-', ''
}

# Check if environment variables are already set
function Check-EnvVars {
    param (
        [string]$envFilePath
    )
    if (Test-Path $envFilePath) {
        $envVars = Get-Content $envFilePath | ConvertFrom-StringData
        return $envVars
    }
    return $null
}

# Clear the terminal and print project details
function Print-ProjectDetails {
    Clear-Host
    Write-ColoredText "____    __    ____  _______ .______             ___      .______   .______          .___________. _______ .___  ___. .______    __          ___   .___________. _______ " "blue"
    Write-ColoredText "\   \  /  \  /   / |   ____||   _  \           /   \     |   _  \  |   _  \         |           ||   ____||   \/   | |   _  \  |  |        /   \  |           ||   ____|" "blue"
    Write-ColoredText " \   \/    \/   /  |  |__   |  |_)  |  ______ /  ^  \    |  |_)  | |  |_)  |  ______`---|  |----`|  |__   |  \  /  | |  |_)  | |  |       /  ^  \ `---|  |----`|  |__   " "blue"
    Write-ColoredText "  \            /   |   __|  |   _  <  |______/  /_\  \   |   ___/  |   ___/  |______|   |  |     |   __|  |  |\/|  | |   ___/  |  |      /  /_\  \    |  |     |   __|  " "blue"
    Write-ColoredText "   \    /\    /    |  |____ |  |_)  |       /  _____  \  |  |      |  |                 |  |     |  |____ |  |  |  | |  |      |  `----./  _____  \   |  |     |  |____ " "blue"
    Write-ColoredText "    \__/  \__/     |_______||______/       /__/     \__\ | _|      | _|                 |__|     |_______||__|  |__| | _|      |_______/__/     \__\  |__|     |_______|" "blue"
    
    # Print project details
    Write-ColoredText "`nCreated with ❤️ by Zesty Lemur - Licensed under GNU GPLv3. [README](https://github.com/zesty-lemur/Web-App-TemplateREADME.md)" "default"
    
    # Insert two blank lines
    Write-Host ""
    Write-Host ""
}

# Get user option
function Get-UserOption {
    param (
        [string[]]$options,
        [string]$prompt
    )

    while ($true) {
        $userInput = Read-Host -Prompt $prompt
        if ($options -contains $userInput) {
            return $userInput
        } else {
            Write-ColoredText "Invalid option. Please select a valid option." "red"
        }
    }
}

# Check if certificate and key files exist
function Check-CertificateFiles {
    param (
        [string]$certPath = "$PSScriptRoot\nginx\certs",
        [string]$certFile = "nginx-selfsigned.crt",
        [string]$keyFile = "nginx-selfsigned.key"
    )

    if (-Not (Test-Path "$certPath\$certFile") -or -Not (Test-Path "$certPath\$keyFile")) {
        Write-ColoredText "Certificate or key file is missing in $certPath. Please ensure both $certFile and $keyFile are present." "red"
        exit
    }
}

# Main script logic
Print-ProjectDetails

# Check if env files already exist
$devEnvFilePath = "$PSScriptRoot\setup\development\.env"
$prodEnvFilePath = "$PSScriptRoot\setup\production\.env"
$devEnvVars = Check-EnvVars $devEnvFilePath
$prodEnvVars = Check-EnvVars $prodEnvFilePath

# Determine the setup mode
if ($devEnvVars -and $prodEnvVars) {
    $mode = Get-UserOption -options @("1", "2", "3") -prompt "It looks like you've already run the setup for both modes. Select from the following options:`n1. Run setup for development and overwrite it`n2. Run setup for production and overwrite it`n3. Continue without overwriting and rebuild`nEnter your choice [1/2/3]:"
    if ($mode -eq "3") {
        $continueMode = Get-UserOption -options @("1", "2") -prompt "Which mode would you like to rebuild?`n1. Development`n2. Production`nEnter your choice [1/2]:"
        if ($continueMode -eq "1") {
            $mode = "development"
        } else {
            $mode = "production"
        }
        Set-Location "$PSScriptRoot\setup\$mode"
        docker-compose up -d --build
        exit
    }
} elseif ($devEnvVars) {
    $mode = Get-UserOption -options @("1", "2") -prompt "It looks like you've already run the setup for development mode. Select from the following options:`n1. Run setup for development and overwrite it`n2. Run setup for production`nEnter your choice [1/2]:"
} elseif ($prodEnvVars) {
    $mode = Get-UserOption -options @("1", "2") -prompt "It looks like you've already run the setup for production mode. Select from the following options:`n1. Run setup for production and overwrite it`n2. Run setup for development`nEnter your choice [1/2]:"
} else {
    $mode = Get-UserOption -options @("1", "2") -prompt "Select from the following options:`n1. Run setup for development`n2. Run setup for production`nEnter your choice [1/2]:"
}

# Set the mode based on user choice
if ($mode -eq "1") {
    $mode = "development"
    $envFilePath = $devEnvFilePath
    $useRandomDefaults = Read-Host -Prompt "[Option:] Use randomly-generated values for SECRET_KEY, DB_USER, POSTGRES_PASSWORD, DB_NAME? [y/N]"
    $useRandomDefaults = $useRandomDefaults -eq 'y'
} else {
    $mode = "production"
    $envFilePath = $prodEnvFilePath
    $useRandomDefaults = $false
}

# Get the app name from the user
$appName = Read-Host -Prompt "[Option:] Provide a name for your app"
$appName = $appName -replace " ", "-"
Write-ColoredText "App Name: $appName" "green"

# Insert a blank line
Write-Host ""

# Handle environment variable setup
$envVars = @{
    SECRET_KEY = ""
    DB_USER = ""
    POSTGRES_PASSWORD = ""
    DB_NAME = ""
}

$envVarKeys = @($envVars.Keys) # Create a static list of keys

foreach ($var in $envVarKeys) {
    if ($useRandomDefaults -and $mode -eq "development") {
        $envVars[$var] = New-RandomString
        Write-ColoredText "${var}: $envVars[$var]" "amber"
    } else {
        if ($mode -eq "production" -and ($var -eq "SECRET_KEY" -or $var -eq "POSTGRES_PASSWORD")) {
            $userInput = Read-Host -Prompt "[Option:] Specify a value for $var or press Enter to generate a default"
        } else {
            $userInput = Read-Host -Prompt "[Option:] Specify a value for $var"
        }

        if ([string]::IsNullOrEmpty($userInput)) {
            $envVars[$var] = New-RandomString
            Write-ColoredText "${var}: $envVars[$var]" "amber"
        } else {
            $envVars[$var] = $userInput
            Write-ColoredText "${var}: $envVars[$var]" "green"
        }
    }
    # Insert a blank line between each option
    Write-Host ""
}

# Write to the .env file
$envVars.GetEnumerator() | ForEach-Object { Add-Content -Path $envFilePath -Value "$($_.Key)=$($_.Value)" }

# Set the 'container_name' value in the docker-compose files
$composeFilePath = "$PSScriptRoot\setup\$mode\docker-compose.yml"
(Get-Content $composeFilePath) -replace 'container_name: flask_app_dev', "container_name: ${appName}_dev" |
    Set-Content $composeFilePath
(Get-Content $composeFilePath) -replace 'container_name: flask_app_prod', "container_name: ${appName}_prod" |
    Set-Content $composeFilePath

# Check for certificate files if in production mode
if ($mode -eq "production") {
    Check-CertificateFiles
}

# Run the appropriate docker-compose file to build the app
Set-Location "$PSScriptRoot\setup\$mode"
docker-compose up -d --build
