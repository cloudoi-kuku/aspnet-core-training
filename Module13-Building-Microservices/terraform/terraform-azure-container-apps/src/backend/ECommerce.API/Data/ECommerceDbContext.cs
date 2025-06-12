using Microsoft.EntityFrameworkCore;
using ECommerce.API.Models;

namespace ECommerce.API.Data;

public class ECommerceDbContext : DbContext
{
    public ECommerceDbContext(DbContextOptions<ECommerceDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Cart> Carts { get; set; }
    public DbSet<CartItem> CartItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Product configuration
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId);

        modelBuilder.Entity<Product>()
            .Property(p => p.Price)
            .HasColumnType("decimal(18,2)");

        // Order configuration
        modelBuilder.Entity<Order>()
            .HasOne(o => o.User)
            .WithMany(u => u.Orders)
            .HasForeignKey(o => o.UserId);

        modelBuilder.Entity<Order>()
            .Property(o => o.TotalAmount)
            .HasColumnType("decimal(18,2)");

        // OrderItem configuration
        modelBuilder.Entity<OrderItem>()
            .HasOne(oi => oi.Order)
            .WithMany(o => o.OrderItems)
            .HasForeignKey(oi => oi.OrderId);

        modelBuilder.Entity<OrderItem>()
            .HasOne(oi => oi.Product)
            .WithMany()
            .HasForeignKey(oi => oi.ProductId);

        modelBuilder.Entity<OrderItem>()
            .Property(oi => oi.Price)
            .HasColumnType("decimal(18,2)");

        // Cart configuration
        modelBuilder.Entity<Cart>()
            .HasOne(c => c.User)
            .WithOne(u => u.Cart)
            .HasForeignKey<Cart>(c => c.UserId);

        // CartItem configuration
        modelBuilder.Entity<CartItem>()
            .HasOne(ci => ci.Cart)
            .WithMany(c => c.Items)
            .HasForeignKey(ci => ci.CartId);

        modelBuilder.Entity<CartItem>()
            .HasOne(ci => ci.Product)
            .WithMany()
            .HasForeignKey(ci => ci.ProductId);

        // User configuration
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        // Seed data
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Electronics", Description = "Electronic devices and accessories" },
            new Category { Id = 2, Name = "Clothing", Description = "Apparel and fashion items" },
            new Category { Id = 3, Name = "Books", Description = "Books and reading materials" }
        );
    }
}