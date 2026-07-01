using CRMS.Data.DTOs.Departments;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class DepartmentService : IDepartmentService
{
    private readonly IDepartmentRepository _departmentRepository;

    public DepartmentService(IDepartmentRepository departmentRepository)
    {
        _departmentRepository = departmentRepository;
    }

    public async Task<List<DepartmentDto>> GetAllAsync() =>
        (await _departmentRepository.GetAllAsync()).Select(ToDto).ToList();

    public async Task<List<DepartmentDto>> GetActiveAsync() =>
        (await _departmentRepository.GetActiveAsync()).Select(ToDto).ToList();

    public async Task<DepartmentDto> CreateAsync(SaveDepartmentDto request)
    {
        if (await _departmentRepository.ExistsByNameAsync(request.Name))
            throw new InvalidOperationException("A department with this name already exists.");

        var department = new Department { Name = request.Name };
        await _departmentRepository.AddAsync(department);

        return ToDto(department);
    }

    public async Task<DepartmentDto?> UpdateAsync(int id, SaveDepartmentDto request)
    {
        var department = await _departmentRepository.GetByIdAsync(id);
        if (department is null)
            return null;

        if (await _departmentRepository.ExistsByNameAsync(request.Name, excludingId: id))
            throw new InvalidOperationException("A department with this name already exists.");

        department.Name = request.Name;
        await _departmentRepository.SaveChangesAsync();

        return ToDto(department);
    }

    public async Task<bool> SetActiveAsync(int id, bool isActive)
    {
        var department = await _departmentRepository.GetByIdAsync(id);
        if (department is null)
            return false;

        department.IsActive = isActive;
        await _departmentRepository.SaveChangesAsync();

        return true;
    }

    private static DepartmentDto ToDto(Department department) => new()
    {
        Id = department.Id,
        Name = department.Name,
        IsActive = department.IsActive
    };
}
