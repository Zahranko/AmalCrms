namespace CRMS.Data.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public Role Role { get; set; }
    public bool IsActive { get; set; } = true;
    public bool NotifyOnNewCase { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
