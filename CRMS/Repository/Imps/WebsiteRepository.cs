using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class WebsiteRepository : IWebsiteRepository
{
    private readonly AppDbContext _context;

    public WebsiteRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<Website>> GetAllActiveAsync() =>
        _context.Websites.Where(w => w.IsActive).OrderBy(w => w.Id).ToListAsync();

    public Task<List<Website>> GetAccessibleAsync(int userId) =>
        _context.UserWebsites
            .Where(uw => uw.UserId == userId && uw.Website!.IsActive)
            .Select(uw => uw.Website!)
            .OrderBy(w => w.Id)
            .ToListAsync();

    public Task<Website?> GetByKeyAsync(string key) =>
        _context.Websites.FirstOrDefaultAsync(w => w.Key == key);

    // WebsiteSetting is ITenantScoped, so this query is already filtered to the
    // active website by AppDbContext's global query filter.
    public Task<List<WebsiteSetting>> GetSettingsAsync() =>
        _context.WebsiteSettings.OrderBy(s => s.Key).ToListAsync();

    public async Task ReplaceSettingsAsync(IEnumerable<WebsiteSetting> settings)
    {
        var incoming = settings.ToList();
        // The filter scopes existing rows to the active website only.
        var existing = await _context.WebsiteSettings.ToListAsync();

        // Upsert by key (never delete+insert the same key in one SaveChanges —
        // that can trip the unique (WebsiteId, Key) index).
        var incomingKeys = incoming.Select(s => s.Key).ToHashSet();
        _context.WebsiteSettings.RemoveRange(existing.Where(e => !incomingKeys.Contains(e.Key)));

        foreach (var s in incoming)
        {
            var match = existing.FirstOrDefault(e => e.Key == s.Key);
            if (match is null)
                _context.WebsiteSettings.Add(new WebsiteSetting { Key = s.Key, Value = s.Value }); // WebsiteId stamped on save
            else
                match.Value = s.Value;
        }

        await _context.SaveChangesAsync();
    }
}
