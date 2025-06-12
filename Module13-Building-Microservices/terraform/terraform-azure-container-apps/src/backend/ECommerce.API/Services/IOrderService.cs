using ECommerce.API.Models;
using ECommerce.API.DTOs;

namespace ECommerce.API.Services;

public interface IOrderService
{
    Task<IEnumerable<Order>> GetAllOrdersAsync();
    Task<IEnumerable<Order>> GetOrdersByUserIdAsync(int userId);
    Task<Order?> GetOrderByIdAsync(int id);
    Task<Order> CreateOrderAsync(int userId, CreateOrderRequest request);
    Task<bool> UpdateOrderStatusAsync(int orderId, string status);
    Task<bool> CancelOrderAsync(int orderId);
}