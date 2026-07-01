using CRMS.Data.DTOs.Doctors;

namespace CRMS.Services.Interfaces;

public interface IDoctorService
{
    Task<List<DoctorDto>> GetAllAsync();
    Task<List<DoctorDto>> GetActiveAsync();
    Task<DoctorDto> CreateAsync(SaveDoctorDto request);
    Task<DoctorDto?> UpdateAsync(int id, SaveDoctorDto request);
    Task<bool> SetActiveAsync(int id, bool isActive);
}
