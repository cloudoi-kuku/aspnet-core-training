#!/bin/bash

echo "Starting database initialization..."

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
sleep 10

# Run the SQL script
echo "Running SQL script to create tables..."
/opt/mssql-tools/bin/sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -i create-tables.sql

if [ $? -eq 0 ]; then
    echo "Database initialization completed successfully!"
else
    echo "Database initialization failed!"
    exit 1
fi