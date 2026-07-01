using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class CaseActionRepository : ICaseActionRepository
{
    private readonly AppDbContext _context;

    public CaseActionRepository(AppDbContext context)
    {
        _context = context;
    }

    public void Add(CaseAction action) => _context.CaseActions.Add(action);

    public Task<List<CaseAction>> GetByCustomerAsync(int customerId) =>
        _context.CaseActions
            .Include(a => a.Actor)
            .Include(a => a.Target)
            .Include(a => a.Department)
            .Include(a => a.Doctor)
            .Where(a => a.CustomerId == customerId)
            .OrderBy(a => a.CreatedAt)
            .ToListAsync();
}
