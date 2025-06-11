using System.ComponentModel.DataAnnotations;

namespace ECommerce.API.Models;

public class Order
{
    public int Id { get; set; }
    
    public int UserId { get; set; }
    
    [Required]
    public string OrderNumber { get; set; } = Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper();
    
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    
    [Required]
    public decimal TotalAmount { get; set; }
    
    [Required]
    public string Status { get; set; } = "Pending";
    
    public string? ShippingAddress { get; set; }
    
    public string? PaymentMethod { get; set; }
    
    public DateTime? ShippedDate { get; set; }
    
    public DateTime? DeliveredDate { get; set; }
    
    // Navigation properties
    public virtual User? User { get; set; }
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}