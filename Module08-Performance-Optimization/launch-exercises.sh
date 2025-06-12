#!/bin/bash

# Module 8 Interactive Exercise Launcher
# Performance Optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Interactive mode flag
INTERACTIVE_MODE=true

# Function to pause and wait for user
pause_for_user() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    fi
}

# Function to show what will be created
preview_file() {
    local file_path=$1
    local description=$2
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Will create: $file_path${NC}"
    echo -e "${YELLOW}📝 Purpose: $description${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to create file with preview
create_file_interactive() {
    local file_path=$1
    local content=$2
    local description=$3
    
    preview_file "$file_path" "$description"
    
    # Show first 20 lines of content
    echo -e "${GREEN}Content preview:${NC}"
    echo "$content" | head -20
    if [ $(echo "$content" | wc -l) -gt 20 ]; then
        echo -e "${YELLOW}... (content truncated for preview)${NC}"
    fi
    echo ""
    
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${YELLOW}Create this file? (Y/n/s to skip all):${NC} \c"
        read -r response
        
        case $response in
            [nN])
                echo -e "${RED}⏭️  Skipped: $file_path${NC}"
                return
                ;;
            [sS])
                INTERACTIVE_MODE=false
                echo -e "${CYAN}📌 Switching to automatic mode...${NC}"
                ;;
        esac
    fi
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    # Write content to file
    echo "$content" > "$file_path"
    echo -e "${GREEN}✅ Created: $file_path${NC}"
    echo ""
}

# Function to show learning objectives
show_learning_objectives() {
    local exercise=$1
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}🎯 Learning Objectives${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${CYAN}In this exercise, you will learn:${NC}"
            echo "  🚀 1. Implementing in-memory and distributed caching strategies"
            echo "  🚀 2. Response caching and output caching techniques"
            echo "  🚀 3. Cache invalidation and expiration policies"
            echo "  🚀 4. Redis integration for distributed scenarios"
            echo ""
            echo -e "${YELLOW}Key caching concepts:${NC}"
            echo "  • Memory cache vs distributed cache"
            echo "  • Cache-aside and write-through patterns"
            echo "  • Cache key design and naming strategies"
            echo "  • Performance monitoring and metrics"
            ;;
        "exercise02")
            echo -e "${CYAN}Building on Exercise 1, you will add:${NC}"
            echo "  📊 1. Database query optimization techniques"
            echo "  📊 2. Entity Framework performance tuning"
            echo "  📊 3. Connection pooling and query batching"
            echo "  📊 4. Database indexing strategies"
            echo ""
            echo -e "${YELLOW}Database optimization:${NC}"
            echo "  • Query execution plan analysis"
            echo "  • N+1 query problem solutions"
            echo "  • Lazy vs eager loading strategies"
            echo "  • Database connection management"
            ;;
        "exercise03")
            echo -e "${CYAN}Advanced performance patterns:${NC}"
            echo "  ⚡ 1. Asynchronous programming best practices"
            echo "  ⚡ 2. Memory management and garbage collection"
            echo "  ⚡ 3. CPU-bound vs I/O-bound optimization"
            echo "  ⚡ 4. Parallel processing and Task optimization"
            echo ""
            echo -e "${YELLOW}Performance concepts:${NC}"
            echo "  • Thread pool optimization"
            echo "  • Memory allocation patterns"
            echo "  • Async/await performance implications"
            echo "  • Resource pooling strategies"
            ;;
        "exercise04")
            echo -e "${CYAN}Monitoring and profiling:${NC}"
            echo "  📈 1. Application performance monitoring (APM)"
            echo "  📈 2. Custom metrics and telemetry"
            echo "  📈 3. Performance profiling tools"
            echo "  📈 4. Load testing and capacity planning"
            echo ""
            echo -e "${YELLOW}Monitoring tools:${NC}"
            echo "  • Built-in .NET performance counters"
            echo "  • Custom metrics with EventCounters"
            echo "  • Memory and CPU profiling"
            echo "  • Distributed tracing patterns"
            ;;
    esac
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show what will be created overview
show_creation_overview() {
    local exercise=$1
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Overview: What will be created${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    case $exercise in
        "exercise01")
            echo -e "${GREEN}🎯 Exercise 01: Caching Implementation${NC}"
            echo ""
            echo -e "${YELLOW}📋 What you'll build:${NC}"
            echo "  ✅ High-performance API with multiple caching layers"
            echo "  ✅ In-memory caching with IMemoryCache"
            echo "  ✅ Distributed caching with Redis"
            echo "  ✅ Response caching and output caching"
            echo ""
            echo -e "${BLUE}🚀 RECOMMENDED: Use the Complete Working Example${NC}"
            echo "  ${CYAN}cd SourceCode/PerformanceDemo && dotnet run${NC}"
            echo "  Then visit: ${CYAN}http://localhost:5000${NC} for performance testing"
            echo ""
            echo -e "${GREEN}📁 Template Structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Controllers/"
            echo "  │   ├── ProductsController.cs   ${YELLOW}# Cached API endpoints${NC}"
            echo "  │   └── CacheController.cs      ${YELLOW}# Cache management${NC}"
            echo "  ├── Services/"
            echo "  │   ├── CacheService.cs         ${YELLOW}# Caching abstraction${NC}"
            echo "  │   └── ProductService.cs       ${YELLOW}# Business logic${NC}"
            echo "  ├── Middleware/"
            echo "  │   └── ResponseCacheMiddleware.cs ${YELLOW}# Custom caching${NC}"
            echo "  └── docker-compose.yml          ${YELLOW}# Redis setup${NC}"
            ;;
            
        "exercise02")
            echo -e "${GREEN}🎯 Exercise 02: Database Optimization${NC}"
            echo ""
            echo -e "${YELLOW}📋 Building on Exercise 1:${NC}"
            echo "  ✅ Entity Framework performance tuning"
            echo "  ✅ Query optimization and indexing"
            echo "  ✅ Connection pooling configuration"
            echo "  ✅ Database performance monitoring"
            echo ""
            echo -e "${GREEN}📁 New additions:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Data/"
            echo "  │   ├── OptimizedDbContext.cs   ${YELLOW}# Performance-tuned context${NC}"
            echo "  │   └── QueryOptimizer.cs       ${YELLOW}# Query analysis tools${NC}"
            echo "  ├── Repositories/"
            echo "  │   └── OptimizedRepository.cs  ${YELLOW}# High-performance queries${NC}"
            echo "  └── Migrations/"
            echo "      └── AddIndexes.cs           ${YELLOW}# Database indexes${NC}"
            ;;
            
        "exercise03")
            echo -e "${GREEN}🎯 Exercise 03: Async and Memory Optimization${NC}"
            echo ""
            echo -e "${YELLOW}📋 Advanced performance patterns:${NC}"
            echo "  ✅ Asynchronous programming optimization"
            echo "  ✅ Memory management and pooling"
            echo "  ✅ CPU-bound task optimization"
            echo "  ✅ Resource pooling implementations"
            echo ""
            echo -e "${GREEN}📁 Performance structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Services/"
            echo "  │   ├── AsyncOptimizedService.cs ${YELLOW}# Async best practices${NC}"
            echo "  │   └── MemoryPoolService.cs     ${YELLOW}# Memory optimization${NC}"
            echo "  ├── Utilities/"
            echo "  │   ├── ObjectPool.cs            ${YELLOW}# Object pooling${NC}"
            echo "  │   └── MemoryManager.cs         ${YELLOW}# Memory management${NC}"
            echo "  └── Benchmarks/"
            echo "      └── PerformanceBenchmarks.cs ${YELLOW}# Performance tests${NC}"
            ;;
            
        "exercise04")
            echo -e "${GREEN}🎯 Exercise 04: Monitoring and Profiling${NC}"
            echo ""
            echo -e "${YELLOW}📋 Performance monitoring tools:${NC}"
            echo "  ✅ Application Performance Monitoring (APM)"
            echo "  ✅ Custom metrics and telemetry"
            echo "  ✅ Performance profiling integration"
            echo "  ✅ Load testing and benchmarking"
            echo ""
            echo -e "${GREEN}📁 Monitoring structure:${NC}"
            echo "  PerformanceDemo/"
            echo "  ├── Monitoring/"
            echo "  │   ├── PerformanceCounters.cs  ${YELLOW}# Custom metrics${NC}"
            echo "  │   ├── TelemetryService.cs     ${YELLOW}# Telemetry collection${NC}"
            echo "  │   └── HealthMetrics.cs        ${YELLOW}# Health monitoring${NC}"
            echo "  ├── LoadTests/"
            echo "  │   └── ApiLoadTests.cs         ${YELLOW}# Load testing scripts${NC}"
            echo "  └── Profiling/"
            echo "      └── ProfilerConfiguration.cs ${YELLOW}# Profiler setup${NC}"
            ;;
    esac
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to explain a concept
explain_concept() {
    local concept=$1
    local explanation=$2
    
    echo -e "${MAGENTA}💡 Concept: $concept${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "$explanation"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    pause_for_user
}

# Function to show available exercises
show_exercises() {
    echo -e "${CYAN}Module 8 - Performance Optimization${NC}"
    echo -e "${CYAN}Available Exercises:${NC}"
    echo ""
    echo "  - exercise01: Caching Implementation"
    echo "  - exercise02: Database Optimization"
    echo "  - exercise03: Async and Memory Optimization"
    echo "  - exercise04: Monitoring and Profiling"
    echo ""
    echo "Usage:"
    echo "  ./launch-exercises.sh <exercise-name> [options]"
    echo ""
    echo "Options:"
    echo "  --list          Show all available exercises"
    echo "  --auto          Skip interactive mode"
    echo "  --preview       Show what will be created without creating"
}

# Main script starts here
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Usage: $0 <exercise-name> [options]${NC}"
    echo ""
    show_exercises
    exit 1
fi

# Handle --list option
if [ "$1" == "--list" ]; then
    show_exercises
    exit 0
fi

EXERCISE_NAME=$1
PROJECT_NAME="PerformanceDemo"
PREVIEW_ONLY=false

# Parse options
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            INTERACTIVE_MODE=false
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Validate exercise name
case $EXERCISE_NAME in
    "exercise01"|"exercise02"|"exercise03"|"exercise04")
        ;;
    *)
        echo -e "${RED}❌ Unknown exercise: $EXERCISE_NAME${NC}"
        echo ""
        show_exercises
        exit 1
        ;;
esac

# Welcome screen
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}🚀 Module 8: Performance Optimization${NC}"
echo -e "${MAGENTA}Exercise: $EXERCISE_NAME${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show the recommended approach
echo -e "${GREEN}🎯 RECOMMENDED APPROACH:${NC}"
echo -e "${CYAN}For the best learning experience, use the complete working implementation:${NC}"
echo ""
echo -e "${YELLOW}1. Use the working source code:${NC}"
echo -e "   ${CYAN}cd SourceCode/PerformanceDemo${NC}"
echo -e "   ${CYAN}dotnet run${NC}"
echo -e "   ${CYAN}# Visit: http://localhost:5000 for performance testing${NC}"
echo ""
echo -e "${YELLOW}2. Or use Docker for complete setup with Redis:${NC}"
echo -e "   ${CYAN}cd SourceCode${NC}"
echo -e "   ${CYAN}docker-compose up --build${NC}"
echo -e "   ${CYAN}# Includes Redis, monitoring, and load testing tools${NC}"
echo ""
echo -e "${YELLOW}⚠️  The template created by this script is basic and may not match${NC}"
echo -e "${YELLOW}   all exercise requirements. The SourceCode version is complete!${NC}"
echo ""

if [ "$INTERACTIVE_MODE" = true ]; then
    echo -e "${YELLOW}🎮 Interactive Mode: ON${NC}"
    echo -e "${CYAN}You'll see what each file does before it's created${NC}"
else
    echo -e "${YELLOW}⚡ Automatic Mode: ON${NC}"
fi

echo ""
echo -n "Continue with template creation? (y/N): "
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}💡 Great choice! Use the SourceCode version for the best experience.${NC}"
    exit 0
fi

# Show learning objectives
show_learning_objectives $EXERCISE_NAME

# Show creation overview
show_creation_overview $EXERCISE_NAME

if [ "$PREVIEW_ONLY" = true ]; then
    echo -e "${YELLOW}Preview mode - no files will be created${NC}"
    exit 0
fi

# Check if project exists in current directory
if [ -d "$PROJECT_NAME" ]; then
    if [[ $EXERCISE_NAME == "exercise02" ]] || [[ $EXERCISE_NAME == "exercise03" ]] || [[ $EXERCISE_NAME == "exercise04" ]]; then
        echo -e "${GREEN}✓ Found existing $PROJECT_NAME from previous exercise${NC}"
        echo -e "${CYAN}This exercise will build on your existing work${NC}"
        cd "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=true
    else
        echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists!${NC}"
        echo -n "Do you want to overwrite it? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
        rm -rf "$PROJECT_NAME"
        SKIP_PROJECT_CREATION=false
    fi
else
    SKIP_PROJECT_CREATION=false
fi

# Exercise-specific implementation
if [[ $EXERCISE_NAME == "exercise01" ]]; then
    # Exercise 1: Caching Implementation

    explain_concept "Performance Optimization Fundamentals" \
"Performance optimization is about making applications faster and more efficient:
• Identify bottlenecks before optimizing
• Measure performance before and after changes
• Focus on the most impactful optimizations first
• Use caching to reduce expensive operations
• Optimize database queries and network calls"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${CYAN}Creating high-performance Web API project...${NC}"
        dotnet new webapi -n "$PROJECT_NAME" --framework net8.0
        cd "$PROJECT_NAME"
        rm -f WeatherForecast.cs Controllers/WeatherForecastController.cs

        # Install performance packages
        echo -e "${CYAN}Installing performance optimization packages...${NC}"
        dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
        dotnet add package Microsoft.AspNetCore.ResponseCompression
        dotnet add package Microsoft.EntityFrameworkCore.InMemory
        # Note: Microsoft.Extensions.Caching.Memory is built into .NET 8.0
        # Note: BenchmarkDotNet removed due to version conflicts with EF Core Design
        # For performance testing, use built-in Stopwatch or external tools

        # Update Program.cs with performance configuration
        create_file_interactive "Program.cs" \
'using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.Extensions.Caching.Memory;
using PerformanceDemo.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Add caching services
builder.Services.AddMemoryCache(options =>
{
    options.SizeLimit = 1024; // Limit cache size
});

// Add distributed caching (Redis)
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379";
    options.InstanceName = "PerformanceDemo";
});

// Add response compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
    options.MimeTypes = ResponseCompressionDefaults.MimeTypes.Concat(new[]
    {
        "application/json",
        "text/json"
    });
});

// Add output caching (new in .NET 8)
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(builder => builder.Cache());
    options.AddPolicy("Products", builder =>
        builder.Tag("products").Expire(TimeSpan.FromMinutes(10)));
});

// Register custom services
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddScoped<IProductService, ProductService>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Performance Demo API", Version = "v1" });
});

// Add CORS for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Performance Demo API v1");
        c.RoutePrefix = "swagger";
    });
}

// Add performance middleware
app.UseResponseCompression();
app.UseOutputCache();

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add a root redirect to swagger
app.MapGet("/", () => Results.Redirect("/swagger"));

app.Run();' \
"Program.cs with comprehensive performance configuration"
    fi

    explain_concept "Caching Strategies" \
"Different caching approaches for different scenarios:
• Memory Cache: Fast, in-process caching for single instances
• Distributed Cache: Shared cache across multiple instances
• Response Cache: HTTP-level caching with proper headers
• Output Cache: New .NET 8 feature for endpoint caching
• Cache invalidation: Keeping cache data fresh and consistent"

    # Create Product model
    create_file_interactive "Models/Product.cs" \
'namespace PerformanceDemo.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? SKU { get; set; }
    public int? CategoryId { get; set; }
    public int StockQuantity { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedDate { get; set; }

    // Navigation property
    public virtual Category? Category { get; set; }
}

// Category class is defined in DatabaseModels.cs to avoid duplication

public class ProductSummary
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
}

public class CacheStatistics
{
    public int TotalRequests { get; set; }
    public int CacheHits { get; set; }
    public int CacheMisses { get; set; }
    public double HitRatio => TotalRequests > 0 ? (double)CacheHits / TotalRequests * 100 : 0;
    public TimeSpan AverageResponseTime { get; set; }
}' \
"Product models optimized for caching scenarios"

    # Create cache service interface and implementation
    create_file_interactive "Services/ICacheService.cs" \
'namespace PerformanceDemo.Services;

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key) where T : class;
    Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class;
    Task RemoveAsync(string key);
    Task RemoveByPatternAsync(string pattern);
    Task<bool> ExistsAsync(string key);
}' \
"Cache service interface for abstraction"

    # Create cache service implementation
    create_file_interactive "Services/CacheService.cs" \
'using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Memory;
using System.Text.Json;

namespace PerformanceDemo.Services;

public class CacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly IDistributedCache _distributedCache;
    private readonly ILogger<CacheService> _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    public CacheService(
        IMemoryCache memoryCache,
        IDistributedCache distributedCache,
        ILogger<CacheService> logger)
    {
        _memoryCache = memoryCache;
        _distributedCache = distributedCache;
        _logger = logger;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };
    }

    public async Task<T?> GetAsync<T>(string key) where T : class
    {
        try
        {
            // Try memory cache first (L1 cache)
            if (_memoryCache.TryGetValue(key, out T? cachedValue))
            {
                _logger.LogDebug("Cache hit (Memory): {Key}", key);
                return cachedValue;
            }

            // Try distributed cache (L2 cache)
            var distributedValue = await _distributedCache.GetStringAsync(key);
            if (!string.IsNullOrEmpty(distributedValue))
            {
                var deserializedValue = JsonSerializer.Deserialize<T>(distributedValue, _jsonOptions);

                // Store in memory cache for faster access
                _memoryCache.Set(key, deserializedValue, TimeSpan.FromMinutes(5));

                _logger.LogDebug("Cache hit (Distributed): {Key}", key);
                return deserializedValue;
            }

            _logger.LogDebug("Cache miss: {Key}", key);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache value for key: {Key}", key);
            return null;
        }
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null) where T : class
    {
        try
        {
            var defaultExpiry = expiry ?? TimeSpan.FromMinutes(30);

            // Set in memory cache
            _memoryCache.Set(key, value, defaultExpiry);

            // Set in distributed cache
            var serializedValue = JsonSerializer.Serialize(value, _jsonOptions);
            var options = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = defaultExpiry
            };

            await _distributedCache.SetStringAsync(key, serializedValue, options);

            _logger.LogDebug("Cache set: {Key} (expires in {Expiry})", key, defaultExpiry);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error setting cache value for key: {Key}", key);
        }
    }

    public async Task RemoveAsync(string key)
    {
        try
        {
            _memoryCache.Remove(key);
            await _distributedCache.RemoveAsync(key);
            _logger.LogDebug("Cache removed: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cache value for key: {Key}", key);
        }
    }

    public async Task RemoveByPatternAsync(string pattern)
    {
        // TODO: Implement pattern-based cache invalidation
        // This is a simplified implementation
        _logger.LogWarning("Pattern-based cache removal not fully implemented: {Pattern}", pattern);
        await Task.CompletedTask;
    }

    public async Task<bool> ExistsAsync(string key)
    {
        try
        {
            if (_memoryCache.TryGetValue(key, out _))
                return true;

            var distributedValue = await _distributedCache.GetStringAsync(key);
            return !string.IsNullOrEmpty(distributedValue);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking cache existence for key: {Key}", key);
            return false;
        }
    }
}' \
"Multi-layer cache service with memory and distributed caching"

    # Create ProductService with caching
    create_file_interactive "Services/ProductService.cs" \
'using PerformanceDemo.Models;

namespace PerformanceDemo.Services;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task<IEnumerable<ProductSummary>> GetProductSummariesAsync();
    Task<Product> CreateProductAsync(Product product);
    Task UpdateProductAsync(int id, Product product);
    Task DeleteProductAsync(int id);
    Task<CacheStatistics> GetCacheStatisticsAsync();
}

public class ProductService : IProductService
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<ProductService> _logger;
    private static readonly List<Product> _products = new();
    private static int _nextId = 1;
    private static readonly CacheStatistics _stats = new();

    // Cache keys
    private const string AllProductsCacheKey = "products:all";
    private const string ProductCacheKeyPrefix = "product:";
    private const string ProductSummariesCacheKey = "products:summaries";

    public ProductService(ICacheService cacheService, ILogger<ProductService> logger)
    {
        _cacheService = cacheService;
        _logger = logger;

        // Initialize with sample data if empty
        if (!_products.Any())
        {
            InitializeSampleData();
        }
    }

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        _stats.TotalRequests++;

        try
        {
            var cachedProducts = await _cacheService.GetAsync<List<Product>>(AllProductsCacheKey);
            if (cachedProducts != null)
            {
                _stats.CacheHits++;
                _logger.LogInformation("Cache hit for all products");
                return cachedProducts;
            }

            _stats.CacheMisses++;
            _logger.LogInformation("Cache miss for all products - fetching from data source");

            // Simulate database delay
            await Task.Delay(100);

            var products = _products.ToList();
            await _cacheService.SetAsync(AllProductsCacheKey, products, TimeSpan.FromMinutes(10));

            return products;
        }
        finally
        {
            stopwatch.Stop();
            _stats.AverageResponseTime = TimeSpan.FromMilliseconds(
                (_stats.AverageResponseTime.TotalMilliseconds * (_stats.TotalRequests - 1) + stopwatch.ElapsedMilliseconds) / _stats.TotalRequests);
        }
    }

    public async Task<Product?> GetProductByIdAsync(int id)
    {
        var cacheKey = $"{ProductCacheKeyPrefix}{id}";
        _stats.TotalRequests++;

        var cachedProduct = await _cacheService.GetAsync<Product>(cacheKey);
        if (cachedProduct != null)
        {
            _stats.CacheHits++;
            return cachedProduct;
        }

        _stats.CacheMisses++;

        // Simulate database delay
        await Task.Delay(50);

        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product != null)
        {
            await _cacheService.SetAsync(cacheKey, product, TimeSpan.FromMinutes(15));
        }

        return product;
    }

    public async Task<IEnumerable<ProductSummary>> GetProductSummariesAsync()
    {
        var cachedSummaries = await _cacheService.GetAsync<List<ProductSummary>>(ProductSummariesCacheKey);
        if (cachedSummaries != null)
        {
            return cachedSummaries;
        }

        // Simulate expensive operation
        await Task.Delay(200);

        var summaries = _products.Select(p => new ProductSummary
        {
            Id = p.Id,
            Name = p.Name,
            Price = p.Price,
            Category = p.Category?.Name ?? "Unknown"
        }).ToList();

        await _cacheService.SetAsync(ProductSummariesCacheKey, summaries, TimeSpan.FromMinutes(5));
        return summaries;
    }

    public async Task<Product> CreateProductAsync(Product product)
    {
        product.Id = _nextId++;
        product.CreatedAt = DateTime.UtcNow;
        product.UpdatedAt = DateTime.UtcNow;

        _products.Add(product);

        // Invalidate related caches
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Created product {ProductId} and invalidated caches", product.Id);
        return product;
    }

    public async Task UpdateProductAsync(int id, Product product)
    {
        var existingProduct = _products.FirstOrDefault(p => p.Id == id);
        if (existingProduct == null)
        {
            throw new KeyNotFoundException($"Product with ID {id} not found");
        }

        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.Category = product.Category;
        existingProduct.StockQuantity = product.StockQuantity;
        existingProduct.IsActive = product.IsActive;
        existingProduct.UpdatedAt = DateTime.UtcNow;

        // Invalidate related caches
        await _cacheService.RemoveAsync($"{ProductCacheKeyPrefix}{id}");
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Updated product {ProductId} and invalidated caches", id);
    }

    public async Task DeleteProductAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product == null)
        {
            throw new KeyNotFoundException($"Product with ID {id} not found");
        }

        _products.Remove(product);

        // Invalidate related caches
        await _cacheService.RemoveAsync($"{ProductCacheKeyPrefix}{id}");
        await _cacheService.RemoveAsync(AllProductsCacheKey);
        await _cacheService.RemoveAsync(ProductSummariesCacheKey);

        _logger.LogInformation("Deleted product {ProductId} and invalidated caches", id);
    }

    public async Task<CacheStatistics> GetCacheStatisticsAsync()
    {
        await Task.CompletedTask;
        return _stats;
    }

    private void InitializeSampleData()
    {
        var sampleProducts = new[]
        {
            new Product { Id = _nextId++, Name = "Laptop Pro", Description = "High-performance laptop", Price = 1299.99m, CategoryId = 1, StockQuantity = 50 },
            new Product { Id = _nextId++, Name = "Wireless Mouse", Description = "Ergonomic wireless mouse", Price = 29.99m, CategoryId = 1, StockQuantity = 200 },
            new Product { Id = _nextId++, Name = "Coffee Mug", Description = "Ceramic coffee mug", Price = 12.99m, CategoryId = 2, StockQuantity = 100 },
            new Product { Id = _nextId++, Name = "Desk Chair", Description = "Comfortable office chair", Price = 199.99m, CategoryId = 3, StockQuantity = 25 },
            new Product { Id = _nextId++, Name = "Notebook", Description = "Spiral-bound notebook", Price = 4.99m, CategoryId = 4, StockQuantity = 500 }
        };

        _products.AddRange(sampleProducts);
    }
}' \
"ProductService with comprehensive caching implementation"

    # Create ProductsController with caching
    create_file_interactive "Controllers/ProductsController.cs" \
'using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OutputCaching;
using PerformanceDemo.Models;
using PerformanceDemo.Services;

namespace PerformanceDemo.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    /// <summary>
    /// Get all products with caching
    /// </summary>
    [HttpGet]
    [OutputCache(PolicyName = "Products")]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = new[] { "*" })]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();

        try
        {
            var products = await _productService.GetAllProductsAsync();

            stopwatch.Stop();
            _logger.LogInformation("GetProducts completed in {ElapsedMs}ms", stopwatch.ElapsedMilliseconds);

            return Ok(products);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting products");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product by ID with caching
    /// </summary>
    [HttpGet("{id}")]
    [OutputCache(Duration = 900)] // 15 minutes
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        try
        {
            var product = await _productService.GetProductByIdAsync(id);

            if (product == null)
            {
                return NotFound($"Product with ID {id} not found");
            }

            return Ok(product);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get product summaries (lightweight cached data)
    /// </summary>
    [HttpGet("summaries")]
    [OutputCache(Duration = 300)]
    public async Task<ActionResult<IEnumerable<ProductSummary>>> GetProductSummaries()
    {
        try
        {
            var summaries = await _productService.GetProductSummariesAsync();
            return Ok(summaries);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting product summaries");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Create a new product (invalidates cache)
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var createdProduct = await _productService.CreateProductAsync(product);

            return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating product");
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Update a product (invalidates cache)
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] Product product)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            await _productService.UpdateProductAsync(id, product);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound($"Product with ID {id} not found");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Delete a product (invalidates cache)
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        try
        {
            await _productService.DeleteProductAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound($"Product with ID {id} not found");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting product {ProductId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    /// <summary>
    /// Get cache performance statistics
    /// </summary>
    [HttpGet("cache/stats")]
    public async Task<ActionResult<CacheStatistics>> GetCacheStatistics()
    {
        try
        {
            var stats = await _productService.GetCacheStatisticsAsync();
            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting cache statistics");
            return StatusCode(500, "Internal server error");
        }
    }
}' \
"ProductsController with comprehensive caching and performance monitoring"

    # Create appsettings.json with performance configuration
    create_file_interactive "appsettings.json" \
'{
  "ConnectionStrings": {
    "Redis": "localhost:6379"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "PerformanceDemo": "Debug"
    }
  },
  "AllowedHosts": "*",
  "Performance": {
    "CacheSettings": {
      "DefaultExpiration": "00:30:00",
      "MemoryCacheSize": 1024,
      "EnableDistributedCache": true
    },
    "CompressionSettings": {
      "EnableCompression": true,
      "CompressionLevel": "Optimal"
    }
  }
}' \
"Configuration with performance and caching settings"

    # Create Docker Compose for Redis
    create_file_interactive "docker-compose.yml" \
'version: "3.8"

services:
  redis:
    image: redis:7-alpine
    container_name: performance-demo-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped

  performance-demo:
    build: .
    container_name: performance-demo-api
    ports:
      - "5000:8080"
    depends_on:
      - redis
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Redis=redis:6379
    restart: unless-stopped

volumes:
  redis_data:' \
"Docker Compose configuration with Redis for distributed caching"

    # Create performance guide
    create_file_interactive "PERFORMANCE_GUIDE.md" \
'# Exercise 1: Caching Implementation

## 🎯 Objective
Implement comprehensive caching strategies to improve API performance by 80%+.

## ⏱️ Time Allocation
**Total Time**: 40 minutes
- Setup and Configuration: 10 minutes
- Caching Implementation: 20 minutes
- Performance Testing: 10 minutes

## 🚀 Getting Started

### Step 1: Start Redis (Optional)
```bash
docker-compose up -d redis
```

### Step 2: Run the Application
```bash
dotnet run
```

### Step 3: Test Performance
```bash
# Test without cache (first request)
curl http://localhost:5000/api/products

# Test with cache (subsequent requests)
curl http://localhost:5000/api/products

# Check cache statistics
curl http://localhost:5000/api/products/cache/stats
```

## 🧪 Performance Exercises

### Exercise A: Cache Performance Testing
1. Make multiple requests to `/api/products`
2. Observe response times and cache hit ratios
3. Test cache invalidation by creating/updating products
4. Monitor cache statistics endpoint

### Exercise B: Cache Configuration
1. Experiment with different cache expiration times
2. Test memory vs distributed cache performance
3. Implement cache warming strategies
4. Add cache metrics and monitoring

### Exercise C: Advanced Caching Patterns
1. Implement cache-aside pattern variations
2. Add cache tags for better invalidation
3. Test cache serialization performance
4. Implement background cache refresh

## 📊 Performance Metrics to Monitor
- Response time improvement (target: 80% reduction)
- Cache hit ratio (target: >90% for repeated requests)
- Memory usage optimization
- Database query reduction

## ✅ Success Criteria
- [ ] Multi-layer caching is working correctly
- [ ] Cache invalidation works on data changes
- [ ] Performance improvements are measurable
- [ ] Cache statistics are accurate
- [ ] Redis integration is functional

## 🔄 Next Steps
After mastering caching, move on to Exercise 2 for database optimization.
' \
"Comprehensive performance guide with practical exercises"

    echo -e "${GREEN}🎉 Exercise 1 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Start Redis: ${CYAN}docker-compose up -d redis${NC}"
    echo "2. Run the API: ${CYAN}dotnet run${NC}"
    echo "3. Visit: ${CYAN}http://localhost:5000/swagger${NC}"
    echo "4. Test performance: ${CYAN}curl http://localhost:5000/api/products/cache/stats${NC}"
    echo "5. Follow the PERFORMANCE_GUIDE.md for optimization exercises"

elif [[ $EXERCISE_NAME == "exercise02" ]]; then
    # Exercise 2: Database Optimization Techniques

    explain_concept "Database Performance Optimization" \
"Database Optimization Strategies:
• Query Optimization: Efficient LINQ queries and SQL generation
• Connection Pooling: Managing database connections effectively
• Indexing Strategies: Database indexes for query performance
• Batch Operations: Reducing database round trips
• Query Splitting: Breaking complex queries for better performance
• Compiled Queries: Pre-compiled queries for repetitive operations"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 2 requires Exercise 1 to be completed first!${NC}"
        echo -e "${YELLOW}Please run: ./launch-exercises.sh exercise01${NC}"
        exit 1
    fi

    # Add Entity Framework optimization packages
    dotnet add package Microsoft.EntityFrameworkCore.Analyzers
    dotnet add package Microsoft.EntityFrameworkCore.Tools

    # Create Optimized DbContext
    create_file_interactive "Data/OptimizedPerformanceContext.cs" \
'using Microsoft.EntityFrameworkCore;
using PerformanceDemo.Models;

namespace PerformanceDemo.Data;

/// <summary>
/// Optimized DbContext for performance demonstrations
/// Includes performance-focused configurations
/// </summary>
public class OptimizedPerformanceContext : DbContext
{
    public OptimizedPerformanceContext(DbContextOptions<OptimizedPerformanceContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Order> Orders { get; set; } = null!;
    public DbSet<OrderItem> OrderItems { get; set; } = null!;
    public DbSet<Customer> Customers { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Product entity with performance optimizations
        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).HasMaxLength(200).IsRequired();
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.Price).HasPrecision(18, 2);
            entity.Property(e => e.SKU).HasMaxLength(50);

            // Performance indexes
            entity.HasIndex(e => e.Name);
            entity.HasIndex(e => e.SKU).IsUnique();
            entity.HasIndex(e => e.CategoryId);
            entity.HasIndex(e => e.Price);
            entity.HasIndex(e => new { e.CategoryId, e.Price });
        });

        // Configure Category entity
        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).HasMaxLength(100).IsRequired();
            entity.HasIndex(e => e.Name).IsUnique();
        });

        // Configure Customer entity
        modelBuilder.Entity<Customer>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Email).HasMaxLength(255).IsRequired();
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);

            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => new { e.LastName, e.FirstName });
        });

        // Configure Order entity
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.OrderNumber).HasMaxLength(50).IsRequired();
            entity.Property(e => e.TotalAmount).HasPrecision(18, 2);

            entity.HasIndex(e => e.OrderNumber).IsUnique();
            entity.HasIndex(e => e.CustomerId);
            entity.HasIndex(e => e.OrderDate);

            // Foreign key relationships
            entity.HasOne(e => e.Customer)
                  .WithMany(c => c.Orders)
                  .HasForeignKey(e => e.CustomerId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure OrderItem entity
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.UnitPrice).HasPrecision(18, 2);
            entity.Property(e => e.TotalPrice).HasPrecision(18, 2);

            entity.HasIndex(e => e.OrderId);
            entity.HasIndex(e => e.ProductId);

            // Foreign key relationships
            entity.HasOne(e => e.Order)
                  .WithMany(o => o.OrderItems)
                  .HasForeignKey(e => e.OrderId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Product)
                  .WithMany()
                  .HasForeignKey(e => e.ProductId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure Product-Category relationship
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            // Performance optimizations
            optionsBuilder.EnableSensitiveDataLogging(false); // Disable in production
            optionsBuilder.EnableServiceProviderCaching();
            optionsBuilder.EnableDetailedErrors(false); // Disable in production
        }
    }
}' \
"Optimized DbContext with performance-focused entity configurations and indexes"

    # Create Enhanced Models for Database Optimization
    create_file_interactive "Models/DatabaseModels.cs" \
'using System.ComponentModel.DataAnnotations;

namespace PerformanceDemo.Models;

/// <summary>
/// Enhanced models for database optimization demonstrations
/// </summary>
public class Category
{
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    // Navigation properties
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}

public class Customer
{
    public int Id { get; set; }

    [Required]
    [StringLength(255)]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;

    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;

    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    // Computed property
    public string FullName => $"{FirstName} {LastName}";
}

public class Order
{
    public int Id { get; set; }

    [Required]
    [StringLength(50)]
    public string OrderNumber { get; set; } = string.Empty;

    public int CustomerId { get; set; }

    public DateTime OrderDate { get; set; } = DateTime.UtcNow;

    [Range(0, double.MaxValue)]
    public decimal TotalAmount { get; set; }

    public OrderStatus Status { get; set; } = OrderStatus.Pending;

    // Navigation properties
    public virtual Customer Customer { get; set; } = null!;
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

public class OrderItem
{
    public int Id { get; set; }

    public int OrderId { get; set; }
    public int ProductId { get; set; }

    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }

    [Range(0, double.MaxValue)]
    public decimal UnitPrice { get; set; }

    [Range(0, double.MaxValue)]
    public decimal TotalPrice { get; set; }

    // Navigation properties
    public virtual Order Order { get; set; } = null!;
    public virtual Product Product { get; set; } = null!;
}

public enum OrderStatus
{
    Pending = 0,
    Processing = 1,
    Shipped = 2,
    Delivered = 3,
    Cancelled = 4
}

// Note: Product model is defined in Product.cs to avoid duplication' \
"Enhanced models for database optimization with proper relationships and indexes"

    # Create Database Query Optimization Service
    create_file_interactive "Services/DatabaseOptimizationService.cs" \
'using Microsoft.EntityFrameworkCore;
using PerformanceDemo.Data;
using PerformanceDemo.Models;
using System.Linq.Expressions;

namespace PerformanceDemo.Services;

/// <summary>
/// Service demonstrating database optimization techniques
/// </summary>
public interface IDatabaseOptimizationService
{
    // Efficient query methods
    Task<List<Product>> GetProductsEfficientAsync(int page, int pageSize);
    Task<List<Product>> GetProductsWithCategoryAsync();
    Task<Product?> GetProductWithDetailsAsync(int id);

    // Batch operations
    Task<int> BulkUpdateProductPricesAsync(decimal multiplier);
    Task BulkInsertProductsAsync(List<Product> products);

    // Compiled queries
    Task<List<Product>> GetProductsByCategoryCompiledAsync(int categoryId);
    Task<decimal> GetAveragePriceCompiledAsync();

    // Query splitting
    Task<List<Order>> GetOrdersWithDetailsAsync(int customerId);

    // No-tracking queries
    Task<List<Product>> GetProductsReadOnlyAsync();

    // Raw SQL for complex operations
    Task<List<ProductSalesReport>> GetProductSalesReportAsync();
}

public class DatabaseOptimizationService : IDatabaseOptimizationService
{
    private readonly OptimizedPerformanceContext _context;
    private readonly ILogger<DatabaseOptimizationService> _logger;

    // Compiled queries for better performance
    private static readonly Func<OptimizedPerformanceContext, int, IAsyncEnumerable<Product>>
        GetProductsByCategoryCompiled = EF.CompileAsyncQuery(
            (OptimizedPerformanceContext context, int categoryId) =>
                context.Products.Where(p => p.CategoryId == categoryId && p.IsActive));

    private static readonly Func<OptimizedPerformanceContext, Task<decimal>>
        GetAveragePriceCompiled = EF.CompileAsyncQuery(
            (OptimizedPerformanceContext context) =>
                context.Products.Where(p => p.IsActive).Average(p => p.Price));

    public DatabaseOptimizationService(OptimizedPerformanceContext context, ILogger<DatabaseOptimizationService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<Product>> GetProductsEfficientAsync(int page, int pageSize)
    {
        _logger.LogInformation("Getting products efficiently - Page: {Page}, Size: {PageSize}", page, pageSize);

        return await _context.Products
            .AsNoTracking() // No change tracking for read-only operations
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(p => new Product // Projection to reduce data transfer
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.Price,
                SKU = p.SKU,
                CategoryId = p.CategoryId
            })
            .ToListAsync();
    }

    public async Task<List<Product>> GetProductsWithCategoryAsync()
    {
        _logger.LogInformation("Getting products with category using Include");

        return await _context.Products
            .AsNoTracking()
            .Include(p => p.Category) // Eager loading
            .Where(p => p.IsActive)
            .OrderBy(p => p.Category!.Name)
            .ThenBy(p => p.Name)
            .ToListAsync();
    }

    public async Task<Product?> GetProductWithDetailsAsync(int id)
    {
        _logger.LogInformation("Getting product with details - ID: {ProductId}", id);

        return await _context.Products
            .Include(p => p.Category)
            .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);
    }

    public async Task<int> BulkUpdateProductPricesAsync(decimal multiplier)
    {
        _logger.LogInformation("Bulk updating product prices with multiplier: {Multiplier}", multiplier);

        // Use ExecuteUpdateAsync for efficient bulk updates (EF Core 7+)
        return await _context.Products
            .Where(p => p.IsActive)
            .ExecuteUpdateAsync(p => p
                .SetProperty(x => x.Price, x => x.Price * multiplier)
                .SetProperty(x => x.UpdatedDate, DateTime.UtcNow));
    }

    public async Task BulkInsertProductsAsync(List<Product> products)
    {
        _logger.LogInformation("Bulk inserting {Count} products", products.Count);

        // Efficient bulk insert
        _context.Products.AddRange(products);
        await _context.SaveChangesAsync();
    }

    public async Task<List<Product>> GetProductsByCategoryCompiledAsync(int categoryId)
    {
        _logger.LogInformation("Getting products by category using compiled query - CategoryId: {CategoryId}", categoryId);

        var products = new List<Product>();
        await foreach (var product in GetProductsByCategoryCompiled(_context, categoryId))
        {
            products.Add(product);
        }
        return products;
    }

    public async Task<decimal> GetAveragePriceCompiledAsync()
    {
        _logger.LogInformation("Getting average price using compiled query");

        return await GetAveragePriceCompiled(_context);
    }

    public async Task<List<Order>> GetOrdersWithDetailsAsync(int customerId)
    {
        _logger.LogInformation("Getting orders with details using query splitting - CustomerId: {CustomerId}", customerId);

        return await _context.Orders
            .Include(o => o.Customer)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                    .ThenInclude(p => p!.Category)
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    public async Task<List<Product>> GetProductsReadOnlyAsync()
    {
        _logger.LogInformation("Getting products with no tracking for read-only operations");

        return await _context.Products
            .AsNoTracking() // Disable change tracking for better performance
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .ToListAsync();
    }

    public async Task<List<ProductSalesReport>> GetProductSalesReportAsync()
    {
        _logger.LogInformation("Getting product sales report using LINQ aggregations");

        // Note: Using LINQ instead of raw SQL for EF Core 8 compatibility
        return await _context.OrderItems
            .Include(oi => oi.Product)
            .GroupBy(oi => new { oi.Product!.Id, oi.Product.Name, oi.Product.Price })
            .Select(g => new ProductSalesReport
            {
                Id = g.Key.Id,
                Name = g.Key.Name,
                Price = g.Key.Price,
                TotalQuantitySold = g.Sum(oi => oi.Quantity),
                TotalRevenue = g.Sum(oi => oi.TotalPrice),
                OrderCount = g.Count()
            })
            .OrderByDescending(p => p.TotalRevenue)
            .ToListAsync();
    }
}

/// <summary>
/// DTO for product sales report
/// </summary>
public class ProductSalesReport
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int TotalQuantitySold { get; set; }
    public decimal TotalRevenue { get; set; }
    public int OrderCount { get; set; }
}' \
"Database optimization service with various performance techniques"

    # Create Exercise Guide for Exercise 2
    create_file_interactive "EXERCISE_02_GUIDE.md" \
'# Exercise 2: Database Optimization Techniques

## 🎯 Objective
Master Entity Framework Core optimization techniques to improve database query performance and reduce resource usage.

## ⏱️ Time Allocation
**Total Time**: 45 minutes
- Entity Configuration and Indexing: 15 minutes
- Query Optimization Techniques: 20 minutes
- Batch Operations and Compiled Queries: 10 minutes

## 🚀 Getting Started

### Step 1: Update Program.cs
Add the optimized database service:

```csharp
builder.Services.AddDbContext<OptimizedPerformanceContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure();
        sqlOptions.CommandTimeout(30);
    }));

builder.Services.AddScoped<IDatabaseOptimizationService, DatabaseOptimizationService>();
```

### Step 2: Key Optimization Techniques
- **AsNoTracking()**: For read-only queries
- **Include() vs Select()**: Eager loading vs projection
- **AsSplitQuery()**: For complex includes
- **ExecuteUpdateAsync()**: Bulk operations
- **Compiled Queries**: Pre-compiled for repetitive queries

### Step 3: Database Indexing Strategy
```sql
-- Automatically created by EF Core configuration
CREATE INDEX IX_Product_Name ON Products (Name);
CREATE INDEX IX_Product_Category_Price ON Products (CategoryId, Price);
CREATE UNIQUE INDEX IX_Product_SKU ON Products (SKU);
```

## ✅ Success Criteria
- [ ] Optimized DbContext is configured with proper indexes
- [ ] Query optimization techniques are implemented
- [ ] Batch operations work efficiently
- [ ] Compiled queries provide performance benefits
- [ ] Raw SQL is used for complex aggregations

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test database optimization endpoints
4. Monitor query execution times
5. Compare optimized vs unoptimized queries

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Entity Framework Core performance best practices
- Database indexing strategies
- Query optimization techniques
- Batch operations for better throughput
- When to use raw SQL vs LINQ
' \
"Complete exercise guide for Database Optimization"

    echo -e "${GREEN}🎉 Exercise 2 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Update Program.cs with optimized database configuration"
    echo "2. Run: ${CYAN}dotnet ef migrations add DatabaseOptimizations${NC}"
    echo "3. Run: ${CYAN}dotnet ef database update${NC}"
    echo "4. Run: ${CYAN}dotnet run${NC}"
    echo "5. Test database optimization endpoints"
    echo "6. Follow the EXERCISE_02_GUIDE.md for implementation steps"

elif [[ $EXERCISE_NAME == "exercise03" ]]; then
    # Exercise 3: Async and Memory Optimization

    explain_concept "Async and Memory Optimization" \
"Advanced Performance Optimization:
• Asynchronous Programming: Proper async/await patterns for I/O operations
• Memory Management: Reducing allocations and GC pressure
• Object Pooling: Reusing expensive objects with ArrayPool and ObjectPool
• Span<T> and Memory<T>: Zero-allocation programming patterns
• ValueTask: Optimized async returns for frequently synchronous operations"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 3 requires Exercises 1 and 2 to be completed first!${NC}"
        echo -e "${YELLOW}Please run exercises in order: exercise01, exercise02, exercise03${NC}"
        exit 1
    fi

    # Add memory optimization packages
    dotnet add package System.Buffers
    dotnet add package Microsoft.Extensions.ObjectPool

    # Create Memory Optimization Service
    create_file_interactive "Services/MemoryOptimizationService.cs" \
'using Microsoft.Extensions.ObjectPool;
using System.Buffers;
using System.Text;
using System.Text.Json;

namespace PerformanceDemo.Services;

/// <summary>
/// Service demonstrating memory optimization techniques
/// </summary>
public interface IMemoryOptimizationService
{
    // ArrayPool demonstrations
    Task<string> ProcessLargeDataWithPoolingAsync(int dataSize);
    Task<byte[]> ProcessBinaryDataEfficientlyAsync(ReadOnlyMemory<byte> input);

    // StringBuilder pooling
    string BuildLargeStringEfficiently(IEnumerable<string> parts);

    // Object pooling
    Task<string> ProcessWithObjectPoolAsync(string input);

    // Span<T> and Memory<T> usage
    ReadOnlySpan<char> ProcessStringSpan(ReadOnlySpan<char> input);
    void ProcessMemorySegment(Memory<byte> memory);

    // ValueTask optimization
    ValueTask<int> GetCachedValueAsync(string key);

    // Zero-allocation JSON processing
    Task<T?> DeserializeJsonEfficientlyAsync<T>(ReadOnlyMemory<byte> jsonBytes);
}

public class MemoryOptimizationService : IMemoryOptimizationService
{
    private readonly ObjectPool<StringBuilder> _stringBuilderPool;
    private readonly ObjectPool<JsonProcessor> _jsonProcessorPool;
    private readonly ILogger<MemoryOptimizationService> _logger;
    private readonly Dictionary<string, int> _cache = new();

    public MemoryOptimizationService(
        ObjectPool<StringBuilder> stringBuilderPool,
        ObjectPool<JsonProcessor> jsonProcessorPool,
        ILogger<MemoryOptimizationService> logger)
    {
        _stringBuilderPool = stringBuilderPool;
        _jsonProcessorPool = jsonProcessorPool;
        _logger = logger;
    }

    public async Task<string> ProcessLargeDataWithPoolingAsync(int dataSize)
    {
        _logger.LogInformation("Processing large data with ArrayPool - Size: {DataSize}", dataSize);

        // Rent buffer from ArrayPool instead of allocating
        var buffer = ArrayPool<char>.Shared.Rent(dataSize);
        try
        {
            // Simulate data processing
            for (int i = 0; i < Math.Min(dataSize, buffer.Length); i++)
            {
                buffer[i] = (char)('A' + (i % 26));
            }

            // Simulate async processing
            await Task.Delay(10);

            // Create string from processed data
            return new string(buffer, 0, Math.Min(dataSize, buffer.Length));
        }
        finally
        {
            // Always return buffer to pool
            ArrayPool<char>.Shared.Return(buffer);
        }
    }

    public async Task<byte[]> ProcessBinaryDataEfficientlyAsync(ReadOnlyMemory<byte> input)
    {
        _logger.LogInformation("Processing binary data efficiently - Size: {Size}", input.Length);

        // Rent buffer for output
        var outputBuffer = ArrayPool<byte>.Shared.Rent(input.Length * 2);
        try
        {
            // Process data efficiently without using Span in async method
            for (int i = 0; i < input.Length; i++)
            {
                outputBuffer[i * 2] = input.Span[i];
                outputBuffer[i * 2 + 1] = (byte)(input.Span[i] ^ 0xFF); // Simple transformation
            }

            await Task.Delay(5); // Simulate async work

            // Return only the used portion
            var result = new byte[input.Length * 2];
            Array.Copy(outputBuffer, 0, result, 0, input.Length * 2);
            return result;
        }
        finally
        {
            ArrayPool<byte>.Shared.Return(outputBuffer);
        }
    }

    public string BuildLargeStringEfficiently(IEnumerable<string> parts)
    {
        _logger.LogInformation("Building large string with StringBuilder pooling");

        // Get StringBuilder from pool
        var sb = _stringBuilderPool.Get();
        try
        {
            foreach (var part in parts)
            {
                sb.Append(part);
                sb.Append(" | ");
            }

            return sb.ToString();
        }
        finally
        {
            // Return StringBuilder to pool (it will be cleared automatically)
            _stringBuilderPool.Return(sb);
        }
    }

    public async Task<string> ProcessWithObjectPoolAsync(string input)
    {
        _logger.LogInformation("Processing with object pool");

        // Get processor from pool
        var processor = _jsonProcessorPool.Get();
        try
        {
            return await processor.ProcessAsync(input);
        }
        finally
        {
            // Return processor to pool
            _jsonProcessorPool.Return(processor);
        }
    }

    public ReadOnlySpan<char> ProcessStringSpan(ReadOnlySpan<char> input)
    {
        // Zero-allocation string processing using Span<T>
        // This method demonstrates span usage but returns a span that references input

        // Find first non-whitespace character
        var trimmed = input.TrimStart();

        // Find last non-whitespace character
        trimmed = trimmed.TrimEnd();

        return trimmed;
    }

    public void ProcessMemorySegment(Memory<byte> memory)
    {
        _logger.LogInformation("Processing memory segment - Length: {Length}", memory.Length);

        // Process memory in chunks using Span<T>
        const int chunkSize = 1024;
        var remaining = memory;

        while (!remaining.IsEmpty)
        {
            var chunk = remaining[..Math.Min(chunkSize, remaining.Length)];
            var span = chunk.Span;

            // Process chunk (example: XOR with pattern)
            for (int i = 0; i < span.Length; i++)
            {
                span[i] ^= (byte)(i % 256);
            }

            remaining = remaining[chunk.Length..];
        }
    }

    public ValueTask<int> GetCachedValueAsync(string key)
    {
        // ValueTask optimization: return synchronously if cached, async if not
        if (_cache.TryGetValue(key, out var cachedValue))
        {
            _logger.LogDebug("Cache hit for key: {Key}", key);
            return ValueTask.FromResult(cachedValue);
        }

        // Cache miss - perform async operation
        return GetValueFromSourceAsync(key);
    }

    private async ValueTask<int> GetValueFromSourceAsync(string key)
    {
        _logger.LogInformation("Cache miss - fetching value for key: {Key}", key);

        // Simulate async data retrieval
        await Task.Delay(100);

        var value = key.GetHashCode() & 0x7FFFFFFF; // Simple hash-based value
        _cache[key] = value;

        return value;
    }

    public async Task<T?> DeserializeJsonEfficientlyAsync<T>(ReadOnlyMemory<byte> jsonBytes)
    {
        _logger.LogInformation("Deserializing JSON efficiently - Size: {Size}", jsonBytes.Length);

        // Simulate async processing
        await Task.Yield();

        // Use ReadOnlyMemory<byte> to avoid string allocation
        return JsonSerializer.Deserialize<T>(jsonBytes.Span);
    }
}

/// <summary>
/// Example class for object pooling
/// </summary>
public class JsonProcessor
{
    private readonly StringBuilder _buffer = new();

    public async Task<string> ProcessAsync(string input)
    {
        _buffer.Clear();
        _buffer.Append("Processed: ");
        _buffer.Append(input);

        // Simulate async work
        await Task.Delay(1);

        return _buffer.ToString();
    }

    public void Reset()
    {
        _buffer.Clear();
    }
}

/// <summary>
/// Object pool policy for JsonProcessor
/// </summary>
public class JsonProcessorPoolPolicy : IPooledObjectPolicy<JsonProcessor>
{
    public JsonProcessor Create()
    {
        return new JsonProcessor();
    }

    public bool Return(JsonProcessor obj)
    {
        obj.Reset();
        return true;
    }
}' \
"Memory optimization service with ArrayPool, ObjectPool, and Span<T> demonstrations"

    # Create Async Optimization Service
    create_file_interactive "Services/AsyncOptimizationService.cs" \
'using System.Collections.Concurrent;
using System.Runtime.CompilerServices;

namespace PerformanceDemo.Services;

/// <summary>
/// Service demonstrating async optimization patterns
/// </summary>
public interface IAsyncOptimizationService
{
    // Proper async patterns
    Task<List<string>> ProcessItemsAsync(IEnumerable<string> items);
    Task<Dictionary<string, int>> ProcessItemsInParallelAsync(IEnumerable<string> items);

    // ConfigureAwait usage
    Task<string> ProcessWithConfigureAwaitAsync(string input);

    // Async enumerable
    IAsyncEnumerable<string> ProcessItemsStreamAsync(IEnumerable<string> items);

    // Cancellation token support
    Task<List<string>> ProcessWithCancellationAsync(IEnumerable<string> items, CancellationToken cancellationToken);

    // ValueTask optimization
    ValueTask<string> GetOrComputeAsync(string key);

    // Task.WhenAll optimization
    Task<string[]> ProcessMultipleSourcesAsync(string[] sources);
}

public class AsyncOptimizationService : IAsyncOptimizationService
{
    private readonly ILogger<AsyncOptimizationService> _logger;
    private readonly ConcurrentDictionary<string, string> _cache = new();
    private readonly SemaphoreSlim _semaphore = new(Environment.ProcessorCount);

    public AsyncOptimizationService(ILogger<AsyncOptimizationService> logger)
    {
        _logger = logger;
    }

    public async Task<List<string>> ProcessItemsAsync(IEnumerable<string> items)
    {
        _logger.LogInformation("Processing items sequentially with proper async pattern");

        var results = new List<string>();

        foreach (var item in items)
        {
            // Proper async processing - each item processed sequentially
            var processed = await ProcessSingleItemAsync(item).ConfigureAwait(false);
            results.Add(processed);
        }

        return results;
    }

    public async Task<Dictionary<string, int>> ProcessItemsInParallelAsync(IEnumerable<string> items)
    {
        _logger.LogInformation("Processing items in parallel with controlled concurrency");

        var tasks = items.Select(async item =>
        {
            await _semaphore.WaitAsync().ConfigureAwait(false);
            try
            {
                var processed = await ProcessSingleItemAsync(item).ConfigureAwait(false);
                return new KeyValuePair<string, int>(processed, processed.Length);
            }
            finally
            {
                _semaphore.Release();
            }
        });

        var results = await Task.WhenAll(tasks).ConfigureAwait(false);
        return results.ToDictionary(kvp => kvp.Key, kvp => kvp.Value);
    }

    public async Task<string> ProcessWithConfigureAwaitAsync(string input)
    {
        _logger.LogInformation("Processing with ConfigureAwait(false) for library code");

        // ConfigureAwait(false) prevents deadlocks in library code
        var step1 = await ProcessStep1Async(input).ConfigureAwait(false);
        var step2 = await ProcessStep2Async(step1).ConfigureAwait(false);
        var step3 = await ProcessStep3Async(step2).ConfigureAwait(false);

        return step3;
    }

    public async IAsyncEnumerable<string> ProcessItemsStreamAsync(
        IEnumerable<string> items,
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Processing items as async stream");

        foreach (var item in items)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var processed = await ProcessSingleItemAsync(item).ConfigureAwait(false);
            yield return processed;

            // Simulate streaming delay
            await Task.Delay(10, cancellationToken).ConfigureAwait(false);
            _logger.LogInformation("Yielded item: {Item}", processed);
            Console.WriteLine($"Yielded item: {processed}");
        }
    }

    public async Task<List<string>> ProcessWithCancellationAsync(
        IEnumerable<string> items,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Processing items with cancellation support");

        var results = new List<string>();

        foreach (var item in items)
        {
            cancellationToken.ThrowIfCancellationRequested();

            try
            {
                var processed = await ProcessSingleItemAsync(item, cancellationToken).ConfigureAwait(false);
                results.Add(processed);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Processing cancelled at item: {Item}", item);
                throw;
            }
        }

        return results;
    }

    public ValueTask<string> GetOrComputeAsync(string key)
    {
        // ValueTask optimization: return cached value synchronously
        if (_cache.TryGetValue(key, out var cachedValue))
        {
            _logger.LogDebug("Cache hit for key: {Key}", key);
            return ValueTask.FromResult(cachedValue);
        }

        // Cache miss: compute asynchronously
        return ComputeAndCacheAsync(key);
    }

    private async ValueTask<string> ComputeAndCacheAsync(string key)
    {
        _logger.LogInformation("Computing value for key: {Key}", key);

        // Simulate expensive computation
        await Task.Delay(50).ConfigureAwait(false);

        var computed = $"Computed_{key}_{DateTime.UtcNow.Ticks}";
        _cache.TryAdd(key, computed);

        return computed;
    }

    public async Task<string[]> ProcessMultipleSourcesAsync(string[] sources)
    {
        _logger.LogInformation("Processing multiple sources concurrently with Task.WhenAll");

        // Process all sources concurrently
        var tasks = sources.Select(source => ProcessSourceAsync(source));

        // Wait for all to complete
        var results = await Task.WhenAll(tasks).ConfigureAwait(false);

        return results;
    }

    private async Task<string> ProcessSingleItemAsync(string item, CancellationToken cancellationToken = default)
    {
        // Simulate async processing
        await Task.Delay(Random.Shared.Next(10, 50), cancellationToken).ConfigureAwait(false);
        return $"Processed_{item}_{DateTime.UtcNow.Ticks}";
    }

    private async Task<string> ProcessStep1Async(string input)
    {
        await Task.Delay(10).ConfigureAwait(false);
        return $"Step1_{input}";
    }

    private async Task<string> ProcessStep2Async(string input)
    {
        await Task.Delay(10).ConfigureAwait(false);
        return $"Step2_{input}";
    }

    private async Task<string> ProcessStep3Async(string input)
    {
        await Task.Delay(10).ConfigureAwait(false);
        return $"Step3_{input}";
    }

    private async Task<string> ProcessSourceAsync(string source)
    {
        // Simulate different processing times for different sources
        var delay = source.GetHashCode() % 100 + 50;
        await Task.Delay(delay).ConfigureAwait(false);
        return $"Source_{source}_Processed";
    }
}' \
"Async optimization service demonstrating proper async patterns and performance techniques"

    # Create Exercise Guide for Exercise 3
    create_file_interactive "EXERCISE_03_GUIDE.md" \
'# Exercise 3: Async and Memory Optimization

## 🎯 Objective
Master advanced async programming patterns and memory optimization techniques to build high-performance, scalable applications.

## ⏱️ Time Allocation
**Total Time**: 45 minutes
- Memory Optimization with ArrayPool: 15 minutes
- Object Pooling and Span<T> Usage: 15 minutes
- Async Optimization Patterns: 15 minutes

## 🚀 Getting Started

### Step 1: Update Program.cs
Add memory optimization services:

```csharp
// Object pooling
builder.Services.AddSingleton<ObjectPool<StringBuilder>>(serviceProvider =>
{
    var provider = new DefaultObjectPoolProvider();
    return provider.CreateStringBuilderPool();
});

builder.Services.AddSingleton<ObjectPool<JsonProcessor>>(serviceProvider =>
{
    var provider = new DefaultObjectPoolProvider();
    return provider.Create(new JsonProcessorPoolPolicy());
});

// Register optimization services
builder.Services.AddScoped<IMemoryOptimizationService, MemoryOptimizationService>();
builder.Services.AddScoped<IAsyncOptimizationService, AsyncOptimizationService>();
```

### Step 2: Key Memory Optimization Techniques
- **ArrayPool<T>**: Rent/return buffers to reduce allocations
- **ObjectPool<T>**: Reuse expensive objects
- **Span<T> and Memory<T>**: Zero-allocation data processing
- **StringBuilder Pooling**: Efficient string building
- **ValueTask**: Optimized async returns

### Step 3: Async Best Practices
- **ConfigureAwait(false)**: In library code
- **Task.WhenAll()**: Concurrent processing
- **CancellationToken**: Proper cancellation support
- **IAsyncEnumerable**: Streaming data processing
- **SemaphoreSlim**: Controlling concurrency

## ✅ Success Criteria
- [ ] Memory optimization techniques reduce allocations
- [ ] Object pooling is properly implemented
- [ ] Async patterns follow best practices
- [ ] Span<T> and Memory<T> are used effectively
- [ ] ValueTask optimization provides performance benefits

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test memory optimization endpoints
4. Monitor memory usage and allocations
5. Test async patterns with concurrent requests

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- Memory allocation patterns and optimization
- Object pooling for expensive resources
- Zero-allocation programming with Span<T>
- Proper async/await patterns
- Concurrency control and cancellation
' \
"Complete exercise guide for Async and Memory Optimization"

    echo -e "${GREEN}🎉 Exercise 3 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Update Program.cs with object pooling configuration"
    echo "2. Register optimization services"
    echo "3. Run: ${CYAN}dotnet run${NC}"
    echo "4. Test memory optimization endpoints"
    echo "5. Monitor memory usage and performance"
    echo "6. Follow the EXERCISE_03_GUIDE.md for implementation steps"

elif [[ $EXERCISE_NAME == "exercise04" ]]; then
    # Exercise 4: Monitoring and Profiling Tools

    explain_concept "Performance Monitoring and Profiling" \
"Performance Monitoring Strategies:
• Application Performance Monitoring (APM): Real-time performance tracking
• Custom Metrics: Business-specific performance indicators
• Memory Profiling: Detecting leaks and allocation patterns
• CPU Profiling: Identifying performance bottlenecks
• Distributed Tracing: End-to-end request tracking"

    if [ "$SKIP_PROJECT_CREATION" = false ]; then
        echo -e "${RED}❌ Exercise 4 requires Exercises 1, 2, and 3 to be completed first!${NC}"
        echo -e "${YELLOW}Please run exercises in order: exercise01, exercise02, exercise03, exercise04${NC}"
        exit 1
    fi

    # Add monitoring and profiling packages
    dotnet add package Microsoft.ApplicationInsights.AspNetCore
    dotnet add package Serilog.AspNetCore
    dotnet add package Serilog.Sinks.Console
    dotnet add package Serilog.Sinks.File
    dotnet add package System.Diagnostics.DiagnosticSource

    # Create Performance Monitoring Service
    create_file_interactive "Services/PerformanceMonitoringService.cs" \
'using System.Diagnostics;
using System.Diagnostics.Metrics;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace PerformanceDemo.Services;

/// <summary>
/// Service for performance monitoring and custom metrics
/// </summary>
public interface IPerformanceMonitoringService
{
    // Custom metrics
    void RecordRequestDuration(string endpoint, double durationMs);
    void RecordCacheHit(string cacheType);
    void RecordCacheMiss(string cacheType);
    void RecordDatabaseQuery(string queryType, double durationMs);

    // Performance counters
    Task<PerformanceMetrics> GetCurrentMetricsAsync();

    // Health monitoring
    Task<HealthStatus> CheckApplicationHealthAsync();

    // Memory monitoring
    Task<MemoryMetrics> GetMemoryMetricsAsync();
}

public class PerformanceMonitoringService : IPerformanceMonitoringService
{
    private readonly ILogger<PerformanceMonitoringService> _logger;
    private readonly Meter _meter;

    // Custom metrics
    private readonly Counter<long> _requestCounter;
    private readonly Histogram<double> _requestDuration;
    private readonly Counter<long> _cacheHitCounter;
    private readonly Counter<long> _cacheMissCounter;
    private readonly Histogram<double> _databaseQueryDuration;

    // Performance tracking
    private readonly ActivitySource _activitySource;

    public PerformanceMonitoringService(ILogger<PerformanceMonitoringService> logger)
    {
        _logger = logger;
        _meter = new Meter("PerformanceDemo.Metrics", "1.0.0");
        _activitySource = new ActivitySource("PerformanceDemo.Activities");

        // Initialize custom metrics
        _requestCounter = _meter.CreateCounter<long>("requests_total", "count", "Total number of requests");
        _requestDuration = _meter.CreateHistogram<double>("request_duration_ms", "ms", "Request duration in milliseconds");
        _cacheHitCounter = _meter.CreateCounter<long>("cache_hits_total", "count", "Total cache hits");
        _cacheMissCounter = _meter.CreateCounter<long>("cache_misses_total", "count", "Total cache misses");
        _databaseQueryDuration = _meter.CreateHistogram<double>("database_query_duration_ms", "ms", "Database query duration");
    }

    public void RecordRequestDuration(string endpoint, double durationMs)
    {
        _requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", endpoint));
        _requestDuration.Record(durationMs, new KeyValuePair<string, object?>("endpoint", endpoint));

        _logger.LogDebug("Request to {Endpoint} took {Duration}ms", endpoint, durationMs);
    }

    public void RecordCacheHit(string cacheType)
    {
        _cacheHitCounter.Add(1, new KeyValuePair<string, object?>("cache_type", cacheType));
        _logger.LogDebug("Cache hit for {CacheType}", cacheType);
    }

    public void RecordCacheMiss(string cacheType)
    {
        _cacheMissCounter.Add(1, new KeyValuePair<string, object?>("cache_type", cacheType));
        _logger.LogDebug("Cache miss for {CacheType}", cacheType);
    }

    public void RecordDatabaseQuery(string queryType, double durationMs)
    {
        _databaseQueryDuration.Record(durationMs, new KeyValuePair<string, object?>("query_type", queryType));
        _logger.LogDebug("Database query {QueryType} took {Duration}ms", queryType, durationMs);
    }

    public async Task<PerformanceMetrics> GetCurrentMetricsAsync()
    {
        _logger.LogInformation("Collecting current performance metrics");

        var process = Process.GetCurrentProcess();

        // Collect various performance metrics
        var metrics = new PerformanceMetrics
        {
            Timestamp = DateTime.UtcNow,

            // CPU metrics
            CpuUsagePercent = await GetCpuUsageAsync(),

            // Memory metrics
            WorkingSetMB = process.WorkingSet64 / 1024 / 1024,
            PrivateMemoryMB = process.PrivateMemorySize64 / 1024 / 1024,
            GcTotalMemoryMB = GC.GetTotalMemory(false) / 1024 / 1024,

            // GC metrics
            Gen0Collections = GC.CollectionCount(0),
            Gen1Collections = GC.CollectionCount(1),
            Gen2Collections = GC.CollectionCount(2),

            // Thread metrics
            ThreadCount = process.Threads.Count,

            // Handle metrics
            HandleCount = process.HandleCount
        };

        return metrics;
    }

    public async Task<HealthStatus> CheckApplicationHealthAsync()
    {
        _logger.LogInformation("Checking application health");

        try
        {
            var metrics = await GetCurrentMetricsAsync();

            // Define health thresholds
            var isHealthy = metrics.CpuUsagePercent < 80 &&
                           metrics.WorkingSetMB < 1000 &&
                           metrics.ThreadCount < 100;

            return isHealthy ? HealthStatus.Healthy : HealthStatus.Degraded;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking application health");
            return HealthStatus.Unhealthy;
        }
    }

    public async Task<MemoryMetrics> GetMemoryMetricsAsync()
    {
        _logger.LogInformation("Collecting memory metrics");

        await Task.Yield(); // Make it async

        var gcInfo = GC.GetGCMemoryInfo();

        return new MemoryMetrics
        {
            Timestamp = DateTime.UtcNow,
            TotalAllocatedBytes = GC.GetTotalAllocatedBytes(),
            TotalMemoryBytes = GC.GetTotalMemory(false),
            Gen0HeapSizeBytes = gcInfo.GenerationInfo[0].SizeAfterBytes,
            Gen1HeapSizeBytes = gcInfo.GenerationInfo[1].SizeAfterBytes,
            Gen2HeapSizeBytes = gcInfo.GenerationInfo[2].SizeAfterBytes,
            LohSizeBytes = gcInfo.GenerationInfo[3].SizeAfterBytes,
            PohSizeBytes = gcInfo.GenerationInfo.Length > 4 ? gcInfo.GenerationInfo[4].SizeAfterBytes : 0,
            FragmentedBytes = gcInfo.FragmentedBytes,
            IsCompacting = gcInfo.Compacted
        };
    }

    private async Task<double> GetCpuUsageAsync()
    {
        var startTime = DateTime.UtcNow;
        var startCpuUsage = Process.GetCurrentProcess().TotalProcessorTime;

        await Task.Delay(500); // Sample for 500ms

        var endTime = DateTime.UtcNow;
        var endCpuUsage = Process.GetCurrentProcess().TotalProcessorTime;

        var cpuUsedMs = (endCpuUsage - startCpuUsage).TotalMilliseconds;
        var totalMsPassed = (endTime - startTime).TotalMilliseconds;
        var cpuUsageTotal = cpuUsedMs / (Environment.ProcessorCount * totalMsPassed);

        return cpuUsageTotal * 100;
    }

    public void Dispose()
    {
        _meter?.Dispose();
        _activitySource?.Dispose();
    }
}

/// <summary>
/// Performance metrics data structure
/// </summary>
public class PerformanceMetrics
{
    public DateTime Timestamp { get; set; }
    public double CpuUsagePercent { get; set; }
    public long WorkingSetMB { get; set; }
    public long PrivateMemoryMB { get; set; }
    public long GcTotalMemoryMB { get; set; }
    public int Gen0Collections { get; set; }
    public int Gen1Collections { get; set; }
    public int Gen2Collections { get; set; }
    public int ThreadCount { get; set; }
    public int HandleCount { get; set; }
}

/// <summary>
/// Memory-specific metrics
/// </summary>
public class MemoryMetrics
{
    public DateTime Timestamp { get; set; }
    public long TotalAllocatedBytes { get; set; }
    public long TotalMemoryBytes { get; set; }
    public long Gen0HeapSizeBytes { get; set; }
    public long Gen1HeapSizeBytes { get; set; }
    public long Gen2HeapSizeBytes { get; set; }
    public long LohSizeBytes { get; set; }
    public long PohSizeBytes { get; set; }
    public long FragmentedBytes { get; set; }
    public bool IsCompacting { get; set; }
}' \
"Performance monitoring service with custom metrics and health checks"

    # Create Performance Middleware
    create_file_interactive "Middleware/PerformanceMiddleware.cs" \
'using System.Diagnostics;

namespace PerformanceDemo.Middleware;

/// <summary>
/// Middleware for automatic performance monitoring
/// </summary>
public class PerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<PerformanceMiddleware> _logger;
    private readonly IPerformanceMonitoringService _performanceService;

    public PerformanceMiddleware(
        RequestDelegate next,
        ILogger<PerformanceMiddleware> logger,
        IPerformanceMonitoringService performanceService)
    {
        _next = next;
        _logger = logger;
        _performanceService = performanceService;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var endpoint = $"{context.Request.Method} {context.Request.Path}";

        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            var duration = stopwatch.Elapsed.TotalMilliseconds;

            _performanceService.RecordRequestDuration(endpoint, duration);

            if (duration > 1000) // Log slow requests
            {
                _logger.LogWarning("Slow request detected: {Endpoint} took {Duration}ms",
                    endpoint, duration);
            }
        }
    }
}' \
"Performance monitoring middleware for automatic request tracking"

    # Create Monitoring Controller
    create_file_interactive "Controllers/MonitoringController.cs" \
'using Microsoft.AspNetCore.Mvc;
using PerformanceDemo.Services;

namespace PerformanceDemo.Controllers;

/// <summary>
/// Controller for performance monitoring and metrics
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class MonitoringController : ControllerBase
{
    private readonly IPerformanceMonitoringService _performanceService;
    private readonly ILogger<MonitoringController> _logger;

    public MonitoringController(
        IPerformanceMonitoringService performanceService,
        ILogger<MonitoringController> logger)
    {
        _performanceService = performanceService;
        _logger = logger;
    }

    /// <summary>
    /// Get current performance metrics
    /// </summary>
    [HttpGet("metrics")]
    public async Task<ActionResult<PerformanceMetrics>> GetMetrics()
    {
        try
        {
            var metrics = await _performanceService.GetCurrentMetricsAsync();
            return Ok(metrics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving performance metrics");
            return StatusCode(500, "Error retrieving metrics");
        }
    }

    /// <summary>
    /// Get memory-specific metrics
    /// </summary>
    [HttpGet("memory")]
    public async Task<ActionResult<MemoryMetrics>> GetMemoryMetrics()
    {
        try
        {
            var metrics = await _performanceService.GetMemoryMetricsAsync();
            return Ok(metrics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving memory metrics");
            return StatusCode(500, "Error retrieving memory metrics");
        }
    }

    /// <summary>
    /// Check application health
    /// </summary>
    [HttpGet("health")]
    public async Task<ActionResult<object>> GetHealth()
    {
        try
        {
            var health = await _performanceService.CheckApplicationHealthAsync();
            var metrics = await _performanceService.GetCurrentMetricsAsync();

            return Ok(new
            {
                Status = health.ToString(),
                Timestamp = DateTime.UtcNow,
                Metrics = metrics
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking application health");
            return StatusCode(500, "Error checking health");
        }
    }

    /// <summary>
    /// Force garbage collection (for testing purposes)
    /// </summary>
    [HttpPost("gc")]
    public ActionResult ForceGarbageCollection()
    {
        _logger.LogInformation("Forcing garbage collection");

        var beforeMemory = GC.GetTotalMemory(false);

        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();

        var afterMemory = GC.GetTotalMemory(false);
        var freedMemory = beforeMemory - afterMemory;

        return Ok(new
        {
            BeforeMemoryBytes = beforeMemory,
            AfterMemoryBytes = afterMemory,
            FreedMemoryBytes = freedMemory,
            FreedMemoryMB = freedMemory / 1024 / 1024
        });
    }

    /// <summary>
    /// Simulate memory pressure for testing
    /// </summary>
    [HttpPost("memory-pressure/{sizeMB}")]
    public ActionResult SimulateMemoryPressure(int sizeMB)
    {
        _logger.LogInformation("Simulating memory pressure: {SizeMB}MB", sizeMB);

        try
        {
            var bytes = new byte[sizeMB * 1024 * 1024];

            // Fill with random data to prevent optimization
            Random.Shared.NextBytes(bytes);

            // Keep reference for a short time
            Task.Delay(5000).ContinueWith(_ =>
            {
                // Release reference
                GC.KeepAlive(bytes);
            });

            return Ok(new { Message = $"Allocated {sizeMB}MB of memory" });
        }
        catch (OutOfMemoryException)
        {
            return BadRequest("Not enough memory available");
        }
    }
}' \
"Monitoring controller for performance metrics and health checks"

    # Create Exercise Guide for Exercise 4
    create_file_interactive "EXERCISE_04_GUIDE.md" \
'# Exercise 4: Monitoring and Profiling Tools

## 🎯 Objective
Implement comprehensive performance monitoring, custom metrics, and profiling tools for production-ready applications.

## ⏱️ Time Allocation
**Total Time**: 30 minutes
- Performance Monitoring Setup: 10 minutes
- Custom Metrics Implementation: 10 minutes
- Health Checks and Profiling: 10 minutes

## 🚀 Getting Started

### Step 1: Update Program.cs
Add monitoring services:

```csharp
// Performance monitoring
builder.Services.AddScoped<IPerformanceMonitoringService, PerformanceMonitoringService>();

// Health checks
builder.Services.AddHealthChecks()
    .AddCheck<ApplicationHealthCheck>("application");

// Application Insights (optional)
builder.Services.AddApplicationInsightsTelemetry();

// Add performance middleware
app.UseMiddleware<PerformanceMiddleware>();

// Health check endpoint
app.MapHealthChecks("/health");
```

### Step 2: Key Monitoring Features
- **Custom Metrics**: Request duration, cache hits/misses, database queries
- **Performance Counters**: CPU, memory, GC statistics
- **Health Checks**: Application health monitoring
- **Memory Profiling**: Heap analysis and leak detection
- **Request Tracking**: Automatic performance monitoring

### Step 3: Monitoring Endpoints
```bash
# Get performance metrics
GET /api/monitoring/metrics

# Get memory metrics
GET /api/monitoring/memory

# Check application health
GET /api/monitoring/health

# Force garbage collection
POST /api/monitoring/gc
```

## ✅ Success Criteria
- [ ] Performance monitoring is automatically tracking requests
- [ ] Custom metrics are being collected
- [ ] Health checks are working properly
- [ ] Memory metrics provide detailed insights
- [ ] Monitoring endpoints return accurate data

## 🧪 Testing Your Implementation
1. Run: `dotnet run`
2. Navigate to: http://localhost:5000/swagger
3. Test monitoring endpoints
4. Generate load and observe metrics
5. Check health status under different conditions

## 🎯 Learning Outcomes
After completing this exercise, you should understand:
- How to implement custom performance metrics
- Application health monitoring strategies
- Memory profiling and leak detection
- Performance monitoring middleware
- Production monitoring best practices
' \
"Complete exercise guide for Monitoring and Profiling"

    echo -e "${GREEN}🎉 Exercise 4 template created successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Update Program.cs with monitoring services"
    echo "2. Add performance middleware to pipeline"
    echo "3. Run: ${CYAN}dotnet run${NC}"
    echo "4. Test monitoring endpoints: ${CYAN}http://localhost:5000/api/monitoring/metrics${NC}"
    echo "5. Monitor application performance and health"
    echo "6. Follow the EXERCISE_04_GUIDE.md for implementation steps"

fi

echo ""
echo -e "${GREEN}✅ Module 8 Exercise Setup Complete!${NC}"
echo -e "${CYAN}Happy optimizing! 🚀⚡${NC}"
