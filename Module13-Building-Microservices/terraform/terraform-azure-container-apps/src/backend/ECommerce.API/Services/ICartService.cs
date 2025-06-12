using ECommerce.API.Models;

namespace ECommerce.API.Services;

public interface ICartService
{
    Task<Cart?> GetCartByUserIdAsync(int userId);
    Task<Cart> AddToCartAsync(int userId, int productId, int quantity);
    Task<bool> UpdateCartItemAsync(int cartItemId, int quantity);
    Task<bool> RemoveFromCartAsync(int cartItemId);
    Task<bool> ClearCartAsync(int userId);
}