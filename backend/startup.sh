#!/bin/bash
# Startup script for Azure App Service

echo "Starting FastAPI application..."

# Install ODBC Driver for SQL Server (if not already installed)
if ! odbcinst -q -d -n "ODBC Driver 18 for SQL Server" > /dev/null 2>&1; then
    echo "Installing ODBC Driver 18 for SQL Server..."
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list
    apt-get update
    ACCEPT_EULA=Y apt-get install -y msodbcsql18
fi

# Start the application
echo "Starting Uvicorn server..."
python -m uvicorn main:app --host 0.0.0.0 --port 8000