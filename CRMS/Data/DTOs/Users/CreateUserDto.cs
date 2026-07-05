using System.ComponentModel.DataAnnotations;
using CRMS.Data.Models;

namespace CRMS.Data.DTOs.Users;

public class CreateUserDto
{
    [Required, MinLength(3)]
    public string Username { get; set; } = string.Empty;

    [Required, MinLength(6)]
    public string Password { get; set; } = string.Empty;

    [Required]
    public Role Role { get; set; }

    // Websites this user may enter. Ignored for Admins (implicit all-access).
    public List<int> WebsiteIds { get; set; } = new();
}
