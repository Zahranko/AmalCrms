namespace CRMS.Data.Models;

public class Notification : ITenantScoped
{
    public int Id { get; set; }
    public int WebsiteId { get; set; }
    public int UserId { get; set; }
    public User? User { get; set; }
    public string Message { get; set; } = string.Empty;
    public int? CustomerId { get; set; }
    public Customer? Customer { get; set; }
    public NotificationType Type { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
