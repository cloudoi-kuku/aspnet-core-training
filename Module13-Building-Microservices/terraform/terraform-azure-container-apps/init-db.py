#!/usr/bin/env python3
import pyodbc
import sys

# Connection parameters
server = 'sql-microservices-woyh5029.database.windows.net'
database = 'ProductDb'
username = 'sqladmin'
password = 'P@ssw0rd123!'

# Connection string
conn_str = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;'

try:
    # Connect to database
    print("Connecting to database...")
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    
    # Create tables
    print("Creating tables...")
    
    # Categories table
    cursor.execute("""
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Categories' AND xtype='U')
    CREATE TABLE Categories (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        CreatedAt DATETIME2 DEFAULT GETDATE()
    )
    """)
    
    # Products table  
    cursor.execute("""
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
    CREATE TABLE Products (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(255) NOT NULL,
        Description NVARCHAR(MAX),
        Price DECIMAL(18,2) NOT NULL,
        CategoryId INT,
        Stock INT NOT NULL DEFAULT 0,
        ImageUrl NVARCHAR(500),
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
    )
    """)
    
    # Insert sample data
    print("Inserting sample data...")
    
    # Check if categories exist
    cursor.execute("SELECT COUNT(*) FROM Categories")
    if cursor.fetchone()[0] == 0:
        cursor.execute("""
        INSERT INTO Categories (Name, Description) VALUES
        ('Electronics', 'Electronic devices and accessories'),
        ('Clothing', 'Apparel and fashion items'),
        ('Books', 'Books and reading materials')
        """)
    
    # Check if products exist
    cursor.execute("SELECT COUNT(*) FROM Products")
    if cursor.fetchone()[0] == 0:
        cursor.execute("""
        INSERT INTO Products (Name, Description, Price, CategoryId, Stock, ImageUrl) VALUES
        ('Laptop Pro 15', 'High-performance laptop with 16GB RAM', 1299.99, 1, 50, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853'),
        ('Wireless Headphones', 'Noise-cancelling Bluetooth headphones', 199.99, 1, 100, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e'),
        ('T-Shirt', 'Comfortable cotton t-shirt', 19.99, 2, 200, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab')
        """)
    
    conn.commit()
    print("Database initialization completed successfully!")
    
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
    
finally:
    if 'conn' in locals():
        conn.close()