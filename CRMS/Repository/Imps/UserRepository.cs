using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<User?> GetByIdAsync(int id) =>
        _context.Users.FirstOrDefaultAsync(u => u.Id == id);

    public Task<User?> GetByUsernameAsync(string username) =>
        _context.Users.FirstOrDefaultAsync(u => u.Username == username);

    public Task<List<User>> GetAllAsync() =>
        _context.Users.OrderBy(u => u.Username).ToListAsync();

    public Task<bool> ExistsByUsernameAsync(string username, int? excludingId = null) =>
        _context.Users.AnyAsync(u => u.Username == username && (excludingId == null || u.Id != excludingId));

    public async Task AddAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();

    public Task<List<int>> GetWebsiteIdsAsync(int userId) =>
        _context.UserWebsites.Where(uw => uw.UserId == userId).Select(uw => uw.WebsiteId).ToListAsync();

    public async Task<Dictionary<int, List<int>>> GetWebsiteIdMapAsync()
    {
        var rows = await _context.UserWebsites.ToListAsync();
        return rows.GroupBy(uw => uw.UserId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.WebsiteId).ToList());
    }

    public async Task<List<User>> GetActiveForWebsiteAsync(int websiteId)
    {
        var memberIds = await _context.UserWebsites
            .Where(uw => uw.WebsiteId == websiteId)
            .Select(uw => uw.UserId)
            .ToListAsync();

        return await _context.Users
            .Where(u => u.IsActive && u.Role != Role.HospitalManager &&
                        (u.Role == Role.Admin || memberIds.Contains(u.Id)))
            .OrderBy(u => u.Username)
            .ToListAsync();
    }

    public async Task SetWebsitesAsync(int userId, IEnumerable<int> websiteIds)
    {
        var target = websiteIds.Distinct().ToHashSet();
        var existing = await _context.UserWebsites.Where(uw => uw.UserId == userId).ToListAsync();
        var existingIds = existing.Select(e => e.WebsiteId).ToHashSet();

        // Upsert (don't delete+insert the same composite key in one SaveChanges).
        _context.UserWebsites.RemoveRange(existing.Where(e => !target.Contains(e.WebsiteId)));
        foreach (var wid in target.Where(id => !existingIds.Contains(id)))
            _context.UserWebsites.Add(new UserWebsite { UserId = userId, WebsiteId = wid });

        await _context.SaveChangesAsync();
    }
}
