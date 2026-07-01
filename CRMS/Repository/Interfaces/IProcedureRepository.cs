using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface IProcedureRepository
{
    Task<Procedure?> GetByIdAsync(int id);
    Task<List<Procedure>> GetAllAsync();
    Task<List<Procedure>> GetActiveAsync();
    Task<bool> ExistsByNameAsync(string name, int? excludingId = null);
    Task AddAsync(Procedure procedure);
    Task SaveChangesAsync();
}
