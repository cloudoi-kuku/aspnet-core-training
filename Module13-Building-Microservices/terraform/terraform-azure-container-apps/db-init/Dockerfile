FROM mcr.microsoft.com/mssql-tools:latest

WORKDIR /scripts

# Copy SQL scripts
COPY create-tables.sql .

# Copy and make the init script executable
COPY init-db.sh .
RUN chmod +x init-db.sh

CMD ["./init-db.sh"]