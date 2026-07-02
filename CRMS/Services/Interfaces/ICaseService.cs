using CRMS.Data.DTOs.Admin;
using CRMS.Data.DTOs.Cases;
using CRMS.Data.DTOs.HospitalManager;

namespace CRMS.Services.Interfaces;

public interface ICaseService
{
    Task<CaseDto> CreateAsync(CreateCaseDto request, int userId);
    Task<List<CaseDto>> GetAllAsync(bool excludeCompleted = false);
    Task<List<CaseDto>> GetMineAsync(int userId, bool excludeCompleted = false);
    Task<List<CaseDto>> GetForwardedToMeAsync(int userId, bool excludeCompleted = false);
    Task<List<CaseDto>> GetForwardedByMeAsync(int userId, bool excludeCompleted = false);
    Task<CaseDetailDto?> GetDetailAsync(int caseId);
    Task<CaseDetailDto> ClaimAsync(int caseId, int userId);
    Task<CaseDetailDto> ForwardAsync(int caseId, int userId, ForwardDto request);
    Task<CaseDetailDto> AcceptForwardAsync(int caseId, int userId);
    Task<CaseDetailDto> DeclineForwardAsync(int caseId, int userId);
    Task<CaseDetailDto> FollowUpAsync(int caseId, int userId, FollowUpDto request);
    Task<CaseDetailDto> ReopenAsync(int caseId, int adminUserId);

    // Admin
    Task<AdminStatsDto> GetStatsAsync();
    Task<List<CaseDto>> GetAllCasesAsync(string? search, int? assignedToUserId, bool todayOnly);
    Task<CaseDetailDto> AdminFollowUpAsync(int caseId, int userId, FollowUpDto request);

    // Hospital Manager
    Task<HospitalManagerStatsDto> GetHospitalManagerStatsAsync(DateTime? from, DateTime? to);
}
