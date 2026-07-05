namespace CRMS.Data.DTOs.Users;

public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public bool NotifyOnNewCase { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<int> WebsiteIds { get; set; } = new();
}
