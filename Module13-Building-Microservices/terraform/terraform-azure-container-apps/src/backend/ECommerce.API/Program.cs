using ECommerce.API.Data;
using ECommerce.API.Services;
using ECommerce.API.Middleware;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Serilog;
using StackExchange.Redis;
using AutoMapper;
using FluentValidation;
using Microsoft.OpenApi.Models;
using Prometheus;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/api-.log", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container
builder.Services.AddControllers();

// Configure Entity Framework
builder.Services.AddDbContext<ECommerceDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    if (connectionString?.Contains("Server=", StringComparison.OrdinalIgnoreCase) == true)
    {
        // Use SQL Server if connection string contains "Server="
        options.UseSqlServer(connectionString);
    }
    else
    {
        // Default to SQLite
        options.UseSqlite(connectionString ?? "Data Source=ecommerce.db");
    }
});

// Configure Redis
builder.Services.AddSingleton<IConnectionMultiplexer>(provider =>
{
    var connectionString = builder.Configuration.GetConnectionString("Redis");
    return ConnectionMultiplexer.Connect(connectionString ?? "localhost:6379");
});

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        // Get allowed origins from configuration
        var corsOrigins = builder.Configuration.GetSection("CORS:AllowedOrigins").Get<string[]>() 
            ?? new[] { "http://localhost:3000" };
        
        policy.WithOrigins(corsOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Add AutoMapper
builder.Services.AddAutoMapper(typeof(Program));

// Add FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

// Register application services
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICartService, CartService>();
builder.Services.AddScoped<ICacheService, RedisCacheService>();
builder.Services.AddScoped<IMessageQueueService, RabbitMQService>();
builder.Services.AddScoped<INotificationService, NotificationService>();

// Add background services
builder.Services.AddHostedService<OrderProcessingService>();
builder.Services.AddHostedService<NotificationProcessingService>();

// Add SignalR for real-time updates
builder.Services.AddSignalR();

// Configure Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "E-Commerce API",
        Version = "v1",
        Description = "A comprehensive e-commerce API built with .NET 8",
        Contact = new OpenApiContact
        {
            Name = "Development Team",
            Email = "dev@ecommerce.com"
        }
    });

    // Add JWT authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Add health checks
var healthChecksBuilder = builder.Services.AddHealthChecks();
var dbConnectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (dbConnectionString?.Contains("Server=", StringComparison.OrdinalIgnoreCase) == true)
{
    healthChecksBuilder.AddSqlServer(dbConnectionString);
}
else
{
    healthChecksBuilder.AddSqlite(dbConnectionString ?? "Data Source=ecommerce.db");
}
healthChecksBuilder.AddCheck("redis", () =>
    {
        try
        {
            using var serviceProvider = builder.Services.BuildServiceProvider();
            var redis = serviceProvider.GetService<IConnectionMultiplexer>();
            return redis?.IsConnected == true ?
                Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy() :
                Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Unhealthy();
        }
        catch
        {
            return Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Unhealthy();
        }
    })
    .ForwardToPrometheus(); // Forward health check metrics to Prometheus

var app = builder.Build();

// Configure the HTTP request pipeline
// Enable Swagger in all environments for demo purposes
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "E-Commerce API v1");
    c.RoutePrefix = "swagger"; // Serve Swagger UI at /swagger
});

// Security middleware
app.UseMiddleware<SecurityHeadersMiddleware>();
app.UseMiddleware<RequestLoggingMiddleware>();
app.UseMiddleware<ExceptionHandlingMiddleware>();

// Prometheus metrics middleware
app.UseMetricServer(); // Expose /metrics endpoint
app.UseHttpMetrics(); // Collect HTTP metrics

app.UseHttpsRedirection();
app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => false // Don't include any checks, just return healthy
});

// Map SignalR hubs
app.MapHub<ECommerce.API.Hubs.NotificationHub>("/hubs/notifications");

// Ensure database is created and seeded
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ECommerceDbContext>();
    
    // For SQL Server, run migrations; for SQLite, ensure created
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    try
    {
        Log.Information("Initializing database...");
        
        if (connectionString?.Contains("Server=", StringComparison.OrdinalIgnoreCase) == true)
        {
            Log.Information("Detected SQL Server connection string");
            
            // For SQL Server, ensure database and schema are created
            Log.Information("Ensuring SQL Server database schema...");
            
            try
            {
                // Try to create the schema if it doesn't exist
                var created = await context.Database.EnsureCreatedAsync();
                if (created)
                {
                    Log.Information("SQL Server database schema created");
                }
                else
                {
                    Log.Information("SQL Server database already exists");
                }
                
                // Verify we have the Products table
                var productCount = await context.Products.CountAsync();
                Log.Information($"Found {productCount} products in database");
            }
            catch (Exception ex)
            {
                Log.Warning(ex, "Could not access database tables, they may not exist yet");
                
                // Try to create the schema
                try
                {
                    await context.Database.EnsureCreatedAsync();
                    Log.Information("Database schema created on retry");
                }
                catch (Exception retryEx)
                {
                    Log.Error(retryEx, "Failed to create database schema");
                }
            }
        }
        else
        {
            Log.Information("Using SQLite database");
            // For SQLite, just ensure the database exists
            await context.Database.EnsureCreatedAsync();
        }
        
        // Wait a moment for database to be ready
        await Task.Delay(1000);
        
        // Test database connection
        var canConnect = await context.Database.CanConnectAsync();
        Log.Information($"Database connection test: {(canConnect ? "Success" : "Failed")}");
        
        if (canConnect)
        {
            await SeedData.SeedAsync(context);
            Log.Information("Database seeded successfully");
        }
        else
        {
            Log.Warning("Cannot connect to database, skipping seed data");
        }
    }
    catch (Exception ex)
    {
        Log.Error(ex, "An error occurred while initializing the database");
        // Don't throw - let the app start and handle database errors at runtime
        // This allows health checks to report the issue
    }
}

Log.Information("E-Commerce API starting up...");

app.Run();

// Make the implicit Program class public so test projects can access it
public partial class Program { }
