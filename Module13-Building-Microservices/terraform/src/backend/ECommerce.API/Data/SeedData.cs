using ECommerce.API.Models;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.API.Data;

public static class SeedData
{
    public static async Task SeedAsync(ECommerceDbContext context)
    {
        // Check if data already exists
        if (await context.Products.AnyAsync())
        {
            return;
        }

        // Seed categories if not seeded by migrations
        if (!await context.Categories.AnyAsync())
        {
            var categories = new[]
            {
                new Category { Name = "Electronics", Description = "Electronic devices and accessories" },
                new Category { Name = "Clothing", Description = "Apparel and fashion items" },
                new Category { Name = "Books", Description = "Books and reading materials" }
            };
            context.Categories.AddRange(categories);
            await context.SaveChangesAsync();
        }

        // Get categories for products
        var electronics = await context.Categories.FirstAsync(c => c.Name == "Electronics");
        var clothing = await context.Categories.FirstAsync(c => c.Name == "Clothing");
        var books = await context.Categories.FirstAsync(c => c.Name == "Books");

        // Seed products
        var products = new[]
        {
            new Product
            {
                Name = "Laptop",
                Description = "High-performance laptop for work and gaming",
                Price = 999.99m,
                Stock = 50,
                ImageUrl = "/images/laptop.jpg",
                CategoryId = electronics.Id
            },
            new Product
            {
                Name = "Smartphone",
                Description = "Latest smartphone with advanced features",
                Price = 699.99m,
                Stock = 100,
                ImageUrl = "/images/smartphone.jpg",
                CategoryId = electronics.Id
            },
            new Product
            {
                Name = "T-Shirt",
                Description = "Comfortable cotton t-shirt",
                Price = 19.99m,
                Stock = 200,
                ImageUrl = "/images/tshirt.jpg",
                CategoryId = clothing.Id
            },
            new Product
            {
                Name = "Jeans",
                Description = "Classic denim jeans",
                Price = 49.99m,
                Stock = 150,
                ImageUrl = "/images/jeans.jpg",
                CategoryId = clothing.Id
            },
            new Product
            {
                Name = "Programming Book",
                Description = "Learn programming with this comprehensive guide",
                Price = 39.99m,
                Stock = 75,
                ImageUrl = "/images/book.jpg",
                CategoryId = books.Id
            }
        };

        context.Products.AddRange(products);
        await context.SaveChangesAsync();
    }
}