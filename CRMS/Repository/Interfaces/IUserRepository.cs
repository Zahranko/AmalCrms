using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByIdAsync(int id);
    Task<User?> GetByUsernameAsync(string username);
    Task<List<User>> GetAllAsync();
    Task<bool> ExistsByUsernameAsync(string username, int? excludingId = null);
    Task AddAsync(User user);
    Task SaveChangesAsync();

    // Website memberships (which websites a user may enter).
    Task<List<int>> GetWebsiteIdsAsync(int userId);
    Task<Dictionary<int, List<int>>> GetWebsiteIdMapAsync();
    Task SetWebsitesAsync(int userId, IEnumerable<int> websiteIds);

    // Active users who can work cases on a website: its members plus all Admins
    // (implicit all-access). Excludes HospitalManager (stats-only).
    Task<List<User>> GetActiveForWebsiteAsync(int websiteId);
}
