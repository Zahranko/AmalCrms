using CRMS.Data.DTOs.Procedures;

namespace CRMS.Services.Interfaces;

public interface IProcedureService
{
    Task<List<ProcedureDto>> GetAllAsync();
    Task<List<ProcedureDto>> GetActiveAsync();
    Task<ProcedureDto> CreateAsync(SaveProcedureDto request);
    Task<ProcedureDto?> UpdateAsync(int id, SaveProcedureDto request);
    Task<bool> SetActiveAsync(int id, bool isActive);
}
