using System.ComponentModel.DataAnnotations;

namespace ECommerce.API.Models;

public class CartItem
{
    public int Id { get; set; }
    
    public int CartId { get; set; }
    
    public int ProductId { get; set; }
    
    [Required]
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
    
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual Cart? Cart { get; set; }
    public virtual Product? Product { get; set; }
}