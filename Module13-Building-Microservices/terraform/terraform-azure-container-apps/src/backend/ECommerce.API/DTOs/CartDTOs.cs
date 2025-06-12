namespace ECommerce.API.DTOs;

public class CartDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public List<CartItemDto> Items { get; set; } = new();
    public decimal TotalAmount => Items.Sum(i => i.Price * i.Quantity);
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CartItemDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public string? ImageUrl { get; set; }
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