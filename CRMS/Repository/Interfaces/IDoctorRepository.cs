using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IDoctorRepository
{
    Task<Doctor?> GetByIdAsync(int id);
    Task<List<Doctor>> GetAllAsync();
    Task<List<Doctor>> GetActiveAsync();
    Task<bool> ExistsByNameAsync(string name, int? excludingId = null);
    Task AddAsync(Doctor doctor);
    Task SaveChangesAsync();
}
