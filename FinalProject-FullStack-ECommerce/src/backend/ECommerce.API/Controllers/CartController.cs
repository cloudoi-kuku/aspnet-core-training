using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ECommerce.API.Services;
using ECommerce.API.Models;
using System.Security.Claims;

namespace ECommerce.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CartController : ControllerBase
{
    private readonly ICartService _cartService;
    private readonly IProductService _productService;
    private readonly ILogger<CartController> _logger;

    public CartController(
        ICartService cartService, 
        IProductService productService,
        ILogger<CartController> logger)
    {
        _cartService = cartService;
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetCart()
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var cart = await _cartService.GetCartByUserIdAsync(userId.Value);
        return Ok(cart);
    }

    [HttpPost("items")]
    public async Task<IActionResult> AddToCart([FromBody] AddToCartRequest request)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            // Verify product exists and has stock
            var product = await _productService.GetProductByIdAsync(request.ProductId);
            if (product == null)
            {
                return NotFound(new { message = "Product not found" });
            }

            if (product.Stock < request.Quantity)
            {
                return BadRequest(new { message = "Insufficient stock" });
            }

            var result = await _cartService.AddToCartAsync(userId.Value, request.ProductId, request.Quantity);
            _logger.LogInformation("User {UserId} added {Quantity} of product {ProductId} to cart", 
                userId, request.Quantity, request.ProductId);
            
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding to cart for user {UserId}", userId);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("items/{itemId}")]
    public async Task<IActionResult> UpdateCartItem(int itemId, [FromBody] UpdateCartItemRequest request)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            // Verify the cart item belongs to the user
            var cart = await _cartService.GetCartByUserIdAsync(userId.Value);
            var item = cart?.Items.FirstOrDefault(i => i.Id == itemId);
            if (item == null)
            {
                return NotFound(new { message = "Cart item not found" });
            }

            // Verify stock if increasing quantity
            if (request.Quantity > item.Quantity)
            {
                var product = await _productService.GetProductByIdAsync(item.ProductId);
                if (product != null && product.Stock < request.Quantity)
                {
                    return BadRequest(new { message = "Insufficient stock" });
                }
            }

            var result = await _cartService.UpdateCartItemAsync(itemId, request.Quantity);
            if (!result)
            {
                return BadRequest(new { message = "Failed to update cart item" });
            }

            _logger.LogInformation("User {UserId} updated cart item {ItemId} quantity to {Quantity}", 
                userId, itemId, request.Quantity);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating cart item {ItemId} for user {UserId}", itemId, userId);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("items/{itemId}")]
    public async Task<IActionResult> RemoveFromCart(int itemId)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            // Verify the cart item belongs to the user
            var cart = await _cartService.GetCartByUserIdAsync(userId.Value);
            var item = cart?.Items.FirstOrDefault(i => i.Id == itemId);
            if (item == null)
            {
                return NotFound(new { message = "Cart item not found" });
            }

            var result = await _cartService.RemoveFromCartAsync(itemId);
            if (!result)
            {
                return BadRequest(new { message = "Failed to remove item from cart" });
            }

            _logger.LogInformation("User {UserId} removed item {ItemId} from cart", userId, itemId);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error removing cart item {ItemId} for user {UserId}", itemId, userId);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete]
    public async Task<IActionResult> ClearCart()
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            var result = await _cartService.ClearCartAsync(userId.Value);
            if (!result)
            {
                return BadRequest(new { message = "Failed to clear cart" });
            }

            _logger.LogInformation("User {UserId} cleared their cart", userId);
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error clearing cart for user {UserId}", userId);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("checkout")]
    public async Task<IActionResult> Checkout([FromBody] CheckoutRequest request)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        try
        {
            var cart = await _cartService.GetCartByUserIdAsync(userId.Value);
            if (cart == null || !cart.Items.Any())
            {
                return BadRequest(new { message = "Cart is empty" });
            }

            // In a real implementation, this would create an order and process payment
            // For now, we'll just clear the cart
            await _cartService.ClearCartAsync(userId.Value);

            _logger.LogInformation("User {UserId} completed checkout", userId);
            
            return Ok(new { message = "Checkout completed successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during checkout for user {UserId}", userId);
            return BadRequest(new { message = ex.Message });
        }
    }

    private int? GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("UserId");
        if (userIdClaim != null && int.TryParse(userIdClaim.Value, out var userId))
        {
            return userId;
        }
        return null;
    }
}

public class AddToCartRequest
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}

public class UpdateCartItemRequest
{
    public int Quantity { get; set; }
}

public class CheckoutRequest
{
    public string ShippingAddress { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
}