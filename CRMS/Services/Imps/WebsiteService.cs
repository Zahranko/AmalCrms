using CRMS.Data.DTOs.Websites;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class WebsiteService : IWebsiteService
{
    private readonly IWebsiteRepository _websiteRepository;

    public WebsiteService(IWebsiteRepository websiteRepository)
    {
        _websiteRepository = websiteRepository;
    }

    public async Task<List<WebsiteDto>> GetAccessibleAsync(int userId, bool isAdmin)
    {
        var websites = isAdmin
            ? await _websiteRepository.GetAllActiveAsync()
            : await _websiteRepository.GetAccessibleAsync(userId);
        return websites.Select(ToDto).ToList();
    }

    public async Task<List<WebsiteSettingDto>> GetSettingsAsync() =>
        (await _websiteRepository.GetSettingsAsync())
            .Select(s => new WebsiteSettingDto { Key = s.Key, Value = s.Value })
            .ToList();

    public Task SaveSettingsAsync(IEnumerable<WebsiteSettingDto> settings)
    {
        var rows = settings
            .Where(s => !string.IsNullOrWhiteSpace(s.Key))
            .Select(s => new WebsiteSetting { Key = s.Key.Trim(), Value = s.Value ?? string.Empty });
        return _websiteRepository.ReplaceSettingsAsync(rows);
    }

    private static WebsiteDto ToDto(Website website) => new()
    {
        Id = website.Id,
        Key = website.Key,
        NameEn = website.NameEn,
        NameAr = website.NameAr
    };
}
