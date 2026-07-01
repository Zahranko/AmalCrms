using CRMS.Data.DTOs.Departments;

namespace CRMS.Services.Interfaces;

public interface IDepartmentService
{
    Task<List<DepartmentDto>> GetAllAsync();
    Task<List<DepartmentDto>> GetActiveAsync();
    Task<DepartmentDto> CreateAsync(SaveDepartmentDto request);
    Task<DepartmentDto?> UpdateAsync(int id, SaveDepartmentDto request);
    Task<bool> SetActiveAsync(int id, bool isActive);
}
