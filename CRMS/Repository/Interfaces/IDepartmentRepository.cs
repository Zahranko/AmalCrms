using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IDepartmentRepository
{
    Task<Department?> GetByIdAsync(int id);
    Task<List<Department>> GetAllAsync();
    Task<List<Department>> GetActiveAsync();
    Task<bool> ExistsByNameAsync(string name, int? excludingId = null);
    Task AddAsync(Department department);
    Task SaveChangesAsync();
}
