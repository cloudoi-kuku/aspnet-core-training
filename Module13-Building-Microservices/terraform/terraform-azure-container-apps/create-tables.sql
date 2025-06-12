-- Create Categories table first (referenced by Products)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Categories' AND xtype='U')
BEGIN
    CREATE TABLE Categories (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500),
        CreatedAt DATETIME2 DEFAULT GETDATE()
    );
END

-- Create Products table for Azure SQL Database
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
BEGIN
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
    );
END

-- Create Users table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
BEGIN
    CREATE TABLE Users (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(100) NOT NULL UNIQUE,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(500) NOT NULL,
        FullName NVARCHAR(255),
        Role NVARCHAR(50) DEFAULT 'User',
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE()
    );
END

-- Create Orders table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
BEGIN
    CREATE TABLE Orders (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL,
        OrderDate DATETIME2 DEFAULT GETDATE(),
        Status NVARCHAR(50) DEFAULT 'Pending',
        TotalAmount DECIMAL(18,2) NOT NULL,
        ShippingAddress NVARCHAR(500),
        PaymentMethod NVARCHAR(50),
        FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
END

-- Create OrderItems table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderItems' AND xtype='U')
BEGIN
    CREATE TABLE OrderItems (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrderId INT NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(18,2) NOT NULL,
        TotalPrice DECIMAL(18,2) NOT NULL,
        FOREIGN KEY (OrderId) REFERENCES Orders(Id),
        FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
END

-- Create Carts table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Carts' AND xtype='U')
BEGIN
    CREATE TABLE Carts (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        UserId INT NOT NULL UNIQUE,
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
END

-- Create CartItems table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CartItems' AND xtype='U')
BEGIN
    CREATE TABLE CartItems (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CartId INT NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL,
        AddedAt DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (CartId) REFERENCES Carts(Id),
        FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
END

-- Insert sample categories
IF NOT EXISTS (SELECT * FROM Categories)
BEGIN
    SET IDENTITY_INSERT Categories ON;
    INSERT INTO Categories (Id, Name, Description) VALUES
    (1, 'Electronics', 'Electronic devices and accessories'),
    (2, 'Clothing', 'Apparel and fashion items'),
    (3, 'Books', 'Books and reading materials');
    SET IDENTITY_INSERT Categories OFF;
END

-- Insert sample products
IF NOT EXISTS (SELECT * FROM Products)
BEGIN
    INSERT INTO Products (Name, Description, Price, CategoryId, Stock, ImageUrl) VALUES
    ('Laptop Pro 15', 'High-performance laptop with 16GB RAM and 512GB SSD', 1299.99, 1, 50, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853'),
    ('Wireless Headphones', 'Noise-cancelling Bluetooth headphones with 30-hour battery', 199.99, 1, 100, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e'),
    ('Smart Watch', 'Fitness tracker with heart rate monitor and GPS', 299.99, 1, 75, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30'),
    ('T-Shirt', 'Comfortable cotton t-shirt', 19.99, 2, 200, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab'),
    ('Jeans', 'Classic denim jeans', 49.99, 2, 150, 'https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a'),
    ('Programming Book', 'Learn programming with this comprehensive guide', 39.99, 3, 75, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f'),
    ('Bluetooth Speaker', 'Portable waterproof speaker with 12-hour battery', 49.99, 1, 80, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1'),
    ('Digital Camera', 'Mirrorless camera with 4K video recording', 899.99, 1, 25, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32');
END

-- Insert sample user
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'demo')
BEGIN
    INSERT INTO Users (Username, Email, PasswordHash, FullName, Role) VALUES
    ('demo', 'demo@example.com', 'AQAAAAEAACcQAAAAEH4QJYzY7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y==', 'Demo User', 'User');
END