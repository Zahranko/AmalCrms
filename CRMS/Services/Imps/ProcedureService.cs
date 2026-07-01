using CRMS.Data.DTOs.Procedures;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class ProcedureService : IProcedureService
{
    private readonly IProcedureRepository _procedureRepository;

    public ProcedureService(IProcedureRepository procedureRepository)
    {
        _procedureRepository = procedureRepository;
    }

    public async Task<List<ProcedureDto>> GetAllAsync() =>
        (await _procedureRepository.GetAllAsync()).Select(ToDto).ToList();

    public async Task<List<ProcedureDto>> GetActiveAsync() =>
        (await _procedureRepository.GetActiveAsync()).Select(ToDto).ToList();

    public async Task<ProcedureDto> CreateAsync(SaveProcedureDto request)
    {
        if (await _procedureRepository.ExistsByNameAsync(request.Name))
            throw new InvalidOperationException("A procedure with this name already exists.");

        var procedure = new Procedure { Name = request.Name };
        await _procedureRepository.AddAsync(procedure);
        return ToDto(await _procedureRepository.GetByIdAsync(procedure.Id) ?? procedure);
    }

    public async Task<ProcedureDto?> UpdateAsync(int id, SaveProcedureDto request)
    {
        var procedure = await _procedureRepository.GetByIdAsync(id);
        if (procedure is null) return null;

        if (await _procedureRepository.ExistsByNameAsync(request.Name, excludingId: id))
            throw new InvalidOperationException("A procedure with this name already exists.");

        procedure.Name = request.Name;
        await _procedureRepository.SaveChangesAsync();
        return ToDto(await _procedureRepository.GetByIdAsync(id) ?? procedure);
    }

    public async Task<bool> SetActiveAsync(int id, bool isActive)
    {
        var procedure = await _procedureRepository.GetByIdAsync(id);
        if (procedure is null) return false;

        procedure.IsActive = isActive;
        await _procedureRepository.SaveChangesAsync();
        return true;
    }

    private static ProcedureDto ToDto(Procedure p) => new()
    {
        Id = p.Id,
        Name = p.Name,
        IsActive = p.IsActive
    };
}
