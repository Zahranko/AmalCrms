using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class ReferralSourceRepository : IReferralSourceRepository
{
    private readonly AppDbContext _context;

    public ReferralSourceRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<ReferralSource?> GetByIdAsync(int id) =>
        _context.ReferralSources.FirstOrDefaultAsync(r => r.Id == id);

    public Task<List<ReferralSource>> GetAllAsync() =>
        _context.ReferralSources.OrderBy(r => r.Name).ToListAsync();

    public Task<List<ReferralSource>> GetActiveAsync() =>
        _context.ReferralSources.Where(r => r.IsActive).OrderBy(r => r.Name).ToListAsync();

    public Task<bool> ExistsByNameAsync(string name, int? excludingId = null) =>
        _context.ReferralSources.AnyAsync(r => r.Name == name && (excludingId == null || r.Id != excludingId));

    public async Task AddAsync(ReferralSource referralSource)
    {
        _context.ReferralSources.Add(referralSource);
        await _context.SaveChangesAsync();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
