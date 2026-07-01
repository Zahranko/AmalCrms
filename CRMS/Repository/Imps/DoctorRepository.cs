using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class DoctorRepository : IDoctorRepository
{
    private readonly AppDbContext _context;

    public DoctorRepository(AppDbContext context) { _context = context; }

    public Task<Doctor?> GetByIdAsync(int id) =>
        _context.Doctors.FirstOrDefaultAsync(d => d.Id == id);

    public Task<List<Doctor>> GetAllAsync() =>
        _context.Doctors.OrderBy(d => d.Name).ToListAsync();

    public Task<List<Doctor>> GetActiveAsync() =>
        _context.Doctors.Where(d => d.IsActive).OrderBy(d => d.Name).ToListAsync();

    public Task<bool> ExistsByNameAsync(string name, int? excludingId = null) =>
        _context.Doctors.AnyAsync(d => d.Name == name && (excludingId == null || d.Id != excludingId));

    public async Task AddAsync(Doctor doctor)
    {
        _context.Doctors.Add(doctor);
        await _context.SaveChangesAsync();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
