using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IReferralSourceRepository
{
    Task<ReferralSource?> GetByIdAsync(int id);
    Task<List<ReferralSource>> GetAllAsync();
    Task<List<ReferralSource>> GetActiveAsync();
    Task<bool> ExistsByNameAsync(string name, int? excludingId = null);
    Task AddAsync(ReferralSource referralSource);
    Task SaveChangesAsync();
}
