using CRMS.Data.DTOs.Websites;

namespace CRMS.Services.Interfaces;

public interface IWebsiteService
{
    // Websites the user may enter: every active website for an Admin, otherwise
    // the user's explicit memberships.
    Task<List<WebsiteDto>> GetAccessibleAsync(int userId, bool isAdmin);

    // System parameters for the currently-active website (X-Website-Id).
    Task<List<WebsiteSettingDto>> GetSettingsAsync();
    Task SaveSettingsAsync(IEnumerable<WebsiteSettingDto> settings);
}
