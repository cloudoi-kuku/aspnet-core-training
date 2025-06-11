using Microsoft.EntityFrameworkCore;
using ECommerce.API.Data;
using ECommerce.API.Models;

namespace ECommerce.API.Services;

public class CartService : ICartService
{
    private readonly ECommerceDbContext _context;
    private readonly ILogger<CartService> _logger;

    public CartService(ECommerceDbContext context, ILogger<CartService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Cart?> GetCartByUserIdAsync(int userId)
    {
        return await _context.Carts
            .Include(c => c.Items)
                .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(c => c.UserId == userId);
    }

    public async Task<Cart> AddToCartAsync(int userId, int productId, int quantity)
    {
        // Get or create cart for user
        var cart = await GetCartByUserIdAsync(userId);
        if (cart == null)
        {
            cart = new Cart { UserId = userId };
            _context.Carts.Add(cart);
            await _context.SaveChangesAsync();
        }

        // Check if product already in cart
        var existingItem = cart.Items.FirstOrDefault(i => i.ProductId == productId);
        if (existingItem != null)
        {
            existingItem.Quantity += quantity;
        }
        else
        {
            var cartItem = new CartItem
            {
                CartId = cart.Id,
                ProductId = productId,
                Quantity = quantity
            };
            cart.Items.Add(cartItem);
        }

        cart.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("Added {Quantity} of product {ProductId} to cart {CartId}", 
            quantity, productId, cart.Id);

        return cart;
    }

    public async Task<bool> UpdateCartItemAsync(int cartItemId, int quantity)
    {
        var cartItem = await _context.CartItems.FindAsync(cartItemId);
        if (cartItem == null)
        {
            return false;
        }

        if (quantity <= 0)
        {
            _context.CartItems.Remove(cartItem);
        }
        else
        {
            cartItem.Quantity = quantity;
        }

        // Update cart timestamp
        var cart = await _context.Carts.FindAsync(cartItem.CartId);
        if (cart != null)
        {
            cart.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        _logger.LogInformation("Updated cart item {CartItemId} quantity to {Quantity}", 
            cartItemId, quantity);

        return true;
    }

    public async Task<bool> RemoveFromCartAsync(int cartItemId)
    {
        var cartItem = await _context.CartItems.FindAsync(cartItemId);
        if (cartItem == null)
        {
            return false;
        }

        _context.CartItems.Remove(cartItem);

        // Update cart timestamp
        var cart = await _context.Carts.FindAsync(cartItem.CartId);
        if (cart != null)
        {
            cart.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        _logger.LogInformation("Removed cart item {CartItemId}", cartItemId);

        return true;
    }

    public async Task<bool> ClearCartAsync(int userId)
    {
        var cart = await GetCartByUserIdAsync(userId);
        if (cart == null)
        {
            return true; // Already empty
        }

        _context.CartItems.RemoveRange(cart.Items);
        cart.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Cleared cart {CartId} for user {UserId}", cart.Id, userId);

        return true;
    }
}