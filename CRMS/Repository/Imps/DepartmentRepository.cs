using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class DepartmentRepository : IDepartmentRepository
{
    private readonly AppDbContext _context;

    public DepartmentRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<Department?> GetByIdAsync(int id) =>
        _context.Departments.FirstOrDefaultAsync(d => d.Id == id);

    public Task<List<Department>> GetAllAsync() =>
        _context.Departments.OrderBy(d => d.Name).ToListAsync();

    public Task<List<Department>> GetActiveAsync() =>
        _context.Departments.Where(d => d.IsActive).OrderBy(d => d.Name).ToListAsync();

    public Task<bool> ExistsByNameAsync(string name, int? excludingId = null) =>
        _context.Departments.AnyAsync(d => d.Name == name && (excludingId == null || d.Id != excludingId));

    public async Task AddAsync(Department department)
    {
        _context.Departments.Add(department);
        await _context.SaveChangesAsync();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
