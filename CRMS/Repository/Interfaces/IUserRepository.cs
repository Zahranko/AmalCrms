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
}
