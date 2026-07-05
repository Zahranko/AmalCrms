using CRMS.Data.DTOs.Websites;

namespace CRMS.Data.DTOs.Auth;

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    // Websites this user may enter — the frontend routes into the one (or shows a
    // picker for several). Admins get every active website.
    public List<WebsiteDto> Websites { get; set; } = new();
}
