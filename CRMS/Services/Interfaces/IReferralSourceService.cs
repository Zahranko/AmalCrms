using CRMS.Data.DTOs.ReferralSources;

namespace CRMS.Services.Interfaces;

public interface IReferralSourceService
{
    Task<List<ReferralSourceDto>> GetAllAsync();
    Task<List<ReferralSourceDto>> GetActiveAsync();
    Task<ReferralSourceDto> CreateAsync(SaveReferralSourceDto request);
    Task<ReferralSourceDto?> UpdateAsync(int id, SaveReferralSourceDto request);
    Task<bool> SetActiveAsync(int id, bool isActive);
}
