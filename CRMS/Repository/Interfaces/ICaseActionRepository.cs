using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface ICaseActionRepository
{
    void Add(CaseAction action);
    Task<List<CaseAction>> GetByCustomerAsync(int customerId);
}
