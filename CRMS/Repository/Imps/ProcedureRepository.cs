using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class ProcedureRepository : IProcedureRepository
{
    private readonly AppDbContext _context;

    public ProcedureRepository(AppDbContext context) { _context = context; }

    public Task<Procedure?> GetByIdAsync(int id) =>
        _context.Procedures.FirstOrDefaultAsync(p => p.Id == id);

    public Task<List<Procedure>> GetAllAsync() =>
        _context.Procedures.OrderBy(p => p.Name).ToListAsync();

    public Task<List<Procedure>> GetActiveAsync() =>
        _context.Procedures.Where(p => p.IsActive).OrderBy(p => p.Name).ToListAsync();

    public Task<bool> ExistsByNameAsync(string name, int? excludingId = null) =>
        _context.Procedures.AnyAsync(p => p.Name == name && (excludingId == null || p.Id != excludingId));

    public async Task AddAsync(Procedure procedure)
    {
        _context.Procedures.Add(procedure);
        await _context.SaveChangesAsync();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
