# Exercise 2: Async Web API Development

## Objective
Build a complete async Web API that demonstrates real-world asynchronous patterns including database operations, external API calls, and background processing.

## Prerequisites
- Completed Exercise 1 (Basic Async)
- Understanding of ASP.NET Core Web APIs
- Familiarity with Entity Framework Core

## Instructions

### Part 1: Setup the Project

1. Create a new ASP.NET Core Web API project called `AsyncApiExercise`
2. Add the following NuGet packages:
   - `Microsoft.EntityFrameworkCore.InMemory`
   - `Swashbuckle.AspNetCore`
   - `System.Text.Json`

### Part 2: Create the Data Models

Create the following models:

```csharp
public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new();
    public decimal TotalAmount { get; set; }
    public OrderStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}

public enum OrderStatus
{
    Pending,
    Processing,
    Completed,
    Cancelled
}

public class ExternalApiResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public object? Data { get; set; }
}
```

### Part 3: Create DbContext

```csharp
public class OrderContext : DbContext
{
    public OrderContext(DbContextOptions<OrderContext> options) : base(options) { }
    
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // TODO: Configure relationships and constraints
    }
}
```

### Part 4: Implement Services

1. **IOrderService** with these async methods:
   ```csharp
   Task<Order> CreateOrderAsync(CreateOrderRequest request);
   Task<Order?> GetOrderByIdAsync(int id);
   Task<IEnumerable<Order>> GetOrdersByCustomerAsync(string customerName);
   Task<Order?> UpdateOrderStatusAsync(int id, OrderStatus status);
   Task<bool> DeleteOrderAsync(int id);
   Task<OrderSummary> GetOrderSummaryAsync(DateTime fromDate, DateTime toDate);
   ```

2. **IExternalApiService** with these methods:
   ```csharp
   Task<bool> ValidatePaymentAsync(decimal amount, string paymentMethod);
   Task<bool> CheckInventoryAsync(List<OrderItem> items);
   Task<bool> SendNotificationAsync(string customerEmail, string message);
   ```

3. **IBackgroundTaskService** for queuing background operations:
   ```csharp
   Task QueueOrderProcessingAsync(int orderId);
   Task QueueInventoryUpdateAsync(List<OrderItem> items);
   ```

### Part 5: Create the Orders Controller

Implement these endpoints:

1. **POST /api/orders** - Create new order
   - Validate input
   - Save to database
   - Queue background processing
   - Return created order

2. **GET /api/orders/{id}** - Get order by ID
   - Support cancellation token
   - Include order items

3. **GET /api/orders/customer/{customerName}** - Get orders by customer
   - Support pagination
   - Sort by creation date

4. **PUT /api/orders/{id}/status** - Update order status
   - Validate status transition
   - Send notification on completion

5. **GET /api/orders/summary** - Get order summary with date range
   - Concurrent database queries
   - Calculate totals and statistics

6. **POST /api/orders/{id}/process** - Process order
   - Call multiple external APIs concurrently
   - Update order status based on results
   - Handle failures gracefully

### Part 6: Implement Concurrent Operations

In the **ProcessOrderAsync** method:

1. **Concurrent External API Calls**:
   ```csharp
   var paymentTask = _externalApiService.ValidatePaymentAsync(order.TotalAmount, "CreditCard");
   var inventoryTask = _externalApiService.CheckInventoryAsync(order.Items);
   var notificationTask = _externalApiService.SendNotificationAsync(customer.Email, "Order processing");
   
   // Wait for all or handle individual failures
   ```

2. **Timeout and Cancellation**:
   - Add timeout for external API calls (5 seconds)
   - Support request cancellation tokens
   - Handle timeout scenarios gracefully

### Part 7: Advanced Requirements

1. **Bulk Operations**:
   ```csharp
   [HttpPost("bulk")]
   public async Task<IActionResult> CreateBulkOrders([FromBody] List<CreateOrderRequest> requests)
   {
       // Process multiple orders concurrently
       // Return results with success/failure status for each
   }
   ```

2. **Streaming Responses**:
   ```csharp
   [HttpGet("stream")]
   public async IAsyncEnumerable<OrderDto> StreamOrders([EnumeratorCancellation] CancellationToken cancellationToken)
   {
       // Stream orders as they're processed
   }
   ```

3. **Health Checks**:
   - Database connectivity
   - External API availability
   - Background service status

### Part 8: Testing Requirements

Create integration tests for:

1. **Concurrent Order Processing**:
   - Submit multiple orders simultaneously
   - Verify all are processed correctly
   - Check for race conditions

2. **Timeout Scenarios**:
   - Simulate slow external APIs
   - Verify timeout handling

3. **Cancellation**:
   - Test request cancellation
   - Verify proper cleanup

## Expected API Behavior

### Sample Request Flow:
```
POST /api/orders
{
  "customerName": "John Doe",
  "items": [
    { "productName": "Laptop", "quantity": 1, "unitPrice": 999.99 },
    { "productName": "Mouse", "quantity": 2, "unitPrice": 29.99 }
  ]
}

Response: 201 Created
{
  "id": 1,
  "customerName": "John Doe",
  "totalAmount": 1059.97,
  "status": "Pending",
  "createdAt": "2024-01-15T10:30:00Z"
}

POST /api/orders/1/process
Response: 200 OK
{
  "success": true,
  "message": "Order processed successfully",
  "processingTime": "00:00:02.345"
}
```

## Performance Requirements

- **Concurrent order creation**: Handle 100+ simultaneous requests
- **Database operations**: All queries should complete within 1 second
- **External API calls**: Implement 5-second timeouts
- **Background processing**: Queue should handle 1000+ items

## Success Criteria

- ✅ All endpoints are properly async
- ✅ Concurrent operations improve performance
- ✅ Proper exception handling and logging
- ✅ Cancellation tokens supported throughout
- ✅ External API failures don't crash the system
- ✅ Database operations are optimized
- ✅ Background tasks process independently

## Bonus Features

1. **Rate Limiting**: Implement async rate limiting for API calls
2. **Caching**: Add async caching for frequently accessed data
3. **Circuit Breaker**: Implement circuit breaker pattern for external APIs
4. **Monitoring**: Add async performance monitoring

## Common Patterns to Implement

1. **Fan-out/Fan-in**: Multiple concurrent operations with aggregated results
2. **Async Enumerable**: Streaming large datasets
3. **Background Processing**: Fire-and-forget tasks
4. **Retry with Exponential Backoff**: For external API failures
5. **Bulkhead Isolation**: Separate thread pools for different operations

## Testing Your Implementation

Use these test scenarios:

```bash
# Test concurrent order creation
for i in {1..10}; do
  curl -X POST http://localhost:5000/api/orders \
    -H "Content-Type: application/json" \
    -d '{"customerName":"Customer'$i'","items":[{"productName":"Product","quantity":1,"unitPrice":100}]}' &
done

# Test cancellation (cancel request after 1 second)
timeout 1s curl http://localhost:5000/api/orders/summary?fromDate=2024-01-01&toDate=2024-12-31

# Test bulk operations
curl -X POST http://localhost:5000/api/orders/bulk \
  -H "Content-Type: application/json" \
  -d '[{"customerName":"Bulk1","items":[...]}, {"customerName":"Bulk2","items":[...]}]'
```

## Solution Structure

```
AsyncApiExercise/
├── Controllers/
│   └── OrdersController.cs
├── Models/
│   ├── Order.cs
│   ├── OrderItem.cs
│   └── DTOs/
├── Services/
│   ├── IOrderService.cs
│   ├── OrderService.cs
│   ├── IExternalApiService.cs
│   └── ExternalApiService.cs
├── Data/
│   └── OrderContext.cs
├── Program.cs
└── Tests/
    └── OrdersControllerTests.cs
```

## Evaluation Rubric

| Criteria | Excellent (4) | Good (3) | Fair (2) | Poor (1) |
|----------|---------------|----------|----------|----------|
| Async Implementation | All methods properly async, no blocking | Most methods async, minimal blocking | Some async methods, some blocking | Poor async usage |
| Concurrent Operations | Efficient use of Task.WhenAll/WhenAny | Some concurrent operations | Limited concurrency | No concurrency |
| Error Handling | Comprehensive exception handling | Good error handling | Basic error handling | Poor error handling |
| Performance | Excellent response times | Good performance




