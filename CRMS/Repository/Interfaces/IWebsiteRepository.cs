using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IWebsiteRepository
{
    // All active websites (used for Admin, who has implicit access to every website).
    Task<List<Website>> GetAllActiveAsync();

    // Active websites the given user has an explicit membership for.
    Task<List<Website>> GetAccessibleAsync(int userId);

    Task<Website?> GetByKeyAsync(string key);

    // Settings for the currently-active website (AppDbContext's query filter
    // scopes this to the X-Website-Id the request carries).
    Task<List<WebsiteSetting>> GetSettingsAsync();

    // Replaces the active website's settings with exactly the supplied rows.
    Task ReplaceSettingsAsync(IEnumerable<WebsiteSetting> settings);
}
