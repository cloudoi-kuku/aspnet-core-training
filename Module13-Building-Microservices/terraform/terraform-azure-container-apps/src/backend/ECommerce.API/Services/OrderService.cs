using ECommerce.API.Models;
using ECommerce.API.DTOs;

namespace ECommerce.API.Services;

public class OrderService : IOrderService
{
    private readonly List<Order> _orders = new();
    private readonly ILogger<OrderService> _logger;
    private readonly IProductService _productService;
    private int _nextId = 1;

    public OrderService(ILogger<OrderService> logger, IProductService productService)
    {
        _logger = logger;
        _productService = productService;
    }

    public async Task<IEnumerable<Order>> GetAllOrdersAsync()
    {
        return await Task.FromResult(_orders.AsEnumerable());
    }

    public async Task<IEnumerable<Order>> GetOrdersByUserIdAsync(int userId)
    {
        return await Task.FromResult(_orders.Where(o => o.UserId == userId));
    }

    public async Task<Order?> GetOrderByIdAsync(int id)
    {
        return await Task.FromResult(_orders.FirstOrDefault(o => o.Id == id));
    }

    public async Task<Order> CreateOrderAsync(int userId, CreateOrderRequest request)
    {
        var order = new Order
        {
            Id = _nextId++,
            UserId = userId,
            OrderNumber = GenerateOrderNumber(),
            OrderDate = DateTime.UtcNow,
            Status = "Pending",
            ShippingAddress = request.ShippingAddress,
            PaymentMethod = request.PaymentMethod,
            OrderItems = new List<OrderItem>()
        };

        decimal totalAmount = 0;

        // Create order items and calculate total
        foreach (var item in request.Items)
        {
            var product = await _productService.GetProductByIdAsync(item.ProductId);
            if (product == null)
            {
                throw new ArgumentException($"Product with ID {item.ProductId} not found");
            }

            if (product.Stock < item.Quantity)
            {
                throw new ArgumentException($"Insufficient stock for product {product.Name}");
            }

            var orderItem = new OrderItem
            {
                OrderId = order.Id,
                ProductId = item.ProductId,
                Quantity = item.Quantity,
                Price = product.Price
            };

            order.OrderItems.Add(orderItem);
            totalAmount += orderItem.Price * orderItem.Quantity;

            // Update product stock
            await _productService.UpdateStockAsync(product.Id, product.Stock - item.Quantity);
        }

        order.TotalAmount = totalAmount;
        _orders.Add(order);

        _logger.LogInformation($"Created order {order.OrderNumber} for user {userId}");
        return order;
    }

    public async Task<bool> UpdateOrderStatusAsync(int orderId, string status)
    {
        var validStatuses = new[] { "Pending", "Processing", "Shipped", "Delivered", "Cancelled" };
        if (!validStatuses.Contains(status))
        {
            throw new ArgumentException("Invalid order status");
        }

        var order = _orders.FirstOrDefault(o => o.Id == orderId);
        if (order == null)
        {
            return false;
        }

        order.Status = status;
        
        if (status == "Shipped")
        {
            order.ShippedDate = DateTime.UtcNow;
        }
        else if (status == "Delivered")
        {
            order.DeliveredDate = DateTime.UtcNow;
        }

        _logger.LogInformation($"Updated order {order.OrderNumber} status to {status}");
        return await Task.FromResult(true);
    }

    public async Task<bool> CancelOrderAsync(int orderId)
    {
        var order = _orders.FirstOrDefault(o => o.Id == orderId);
        if (order == null)
        {
            return false;
        }

        if (order.Status != "Pending" && order.Status != "Processing")
        {
            return false; // Can only cancel pending or processing orders
        }

        order.Status = "Cancelled";

        // Restore product stock
        foreach (var item in order.OrderItems)
        {
            var product = await _productService.GetProductByIdAsync(item.ProductId);
            if (product != null)
            {
                await _productService.UpdateStockAsync(product.Id, product.Stock + item.Quantity);
            }
        }

        _logger.LogInformation($"Cancelled order {order.OrderNumber}");
        return true;
    }

    private string GenerateOrderNumber()
    {
        return $"ORD-{DateTime.UtcNow:yyyyMMdd}-{_nextId:D4}";
    }
}