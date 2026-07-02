using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface ICustomerRepository
{
    Task AddAsync(Customer customer);
    Task<Customer?> GetByIdAsync(int id);
    Task<List<Customer>> GetAllAsync(bool excludeCompleted = false);
    Task<List<Customer>> GetMineAsync(int userId, bool excludeCompleted = false);
    Task<List<Customer>> GetForwardedToMeAsync(int userId, bool excludeCompleted = false);
    Task<List<Customer>> GetForwardedByMeAsync(int userId, bool excludeCompleted = false);
    Task<List<Customer>> GetAllFilteredAsync(string? search, int? assignedToUserId, bool todayOnly);
    Task<int> CountAllAsync();
    Task<Dictionary<CustomerStatus, int>> GetStatusCountsAsync(DateTime? from = null, DateTime? to = null);
    Task<Dictionary<int, int>> GetReferralSourceCountsAsync();
    Task<List<(int UserId, int Total, int Success, int Failed)>> GetCaseCountsByCreatorAsync();
    Task<List<(int DepartmentId, int Total, int Success, int Failed)>> GetCaseCountsByDepartmentAsync(DateTime? from = null, DateTime? to = null);
    Task<List<(int DoctorId, int Total, int Success, int Failed)>> GetCaseCountsByDoctorAsync(DateTime? from = null, DateTime? to = null);
    Task SaveChangesAsync();
}
