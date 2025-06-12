namespace ECommerce.API.DTOs;

public class CreateOrderRequest
{
    public List<OrderItemRequest> Items { get; set; } = new();
    public string ShippingAddress { get; set; } = string.Empty;
    public string PaymentMethod { get; set; } = string.Empty;
}

public class OrderItemRequest
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}