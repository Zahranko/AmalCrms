using CRMS.Data.DTOs.Doctors;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class DoctorService : IDoctorService
{
    private readonly IDoctorRepository _doctorRepository;

    public DoctorService(IDoctorRepository doctorRepository)
    {
        _doctorRepository = doctorRepository;
    }

    public async Task<List<DoctorDto>> GetAllAsync() =>
        (await _doctorRepository.GetAllAsync()).Select(ToDto).ToList();

    public async Task<List<DoctorDto>> GetActiveAsync() =>
        (await _doctorRepository.GetActiveAsync()).Select(ToDto).ToList();

    public async Task<DoctorDto> CreateAsync(SaveDoctorDto request)
    {
        if (await _doctorRepository.ExistsByNameAsync(request.Name))
            throw new InvalidOperationException("A doctor with this name already exists.");

        var doctor = new Doctor { Name = request.Name };
        await _doctorRepository.AddAsync(doctor);
        return ToDto(doctor);
    }

    public async Task<DoctorDto?> UpdateAsync(int id, SaveDoctorDto request)
    {
        var doctor = await _doctorRepository.GetByIdAsync(id);
        if (doctor is null) return null;

        if (await _doctorRepository.ExistsByNameAsync(request.Name, excludingId: id))
            throw new InvalidOperationException("A doctor with this name already exists.");

        doctor.Name = request.Name;
        await _doctorRepository.SaveChangesAsync();
        return ToDto(doctor);
    }

    public async Task<bool> SetActiveAsync(int id, bool isActive)
    {
        var doctor = await _doctorRepository.GetByIdAsync(id);
        if (doctor is null) return false;

        doctor.IsActive = isActive;
        await _doctorRepository.SaveChangesAsync();
        return true;
    }

    private static DoctorDto ToDto(Doctor doctor) => new()
    {
        Id = doctor.Id,
        Name = doctor.Name,
        IsActive = doctor.IsActive
    };
}
