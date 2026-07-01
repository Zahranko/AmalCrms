using CRMS.Data.DTOs.ReferralSources;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class ReferralSourceService : IReferralSourceService
{
    private readonly IReferralSourceRepository _referralSourceRepository;

    public ReferralSourceService(IReferralSourceRepository referralSourceRepository)
    {
        _referralSourceRepository = referralSourceRepository;
    }

    public async Task<List<ReferralSourceDto>> GetAllAsync() =>
        (await _referralSourceRepository.GetAllAsync()).Select(ToDto).ToList();

    public async Task<List<ReferralSourceDto>> GetActiveAsync() =>
        (await _referralSourceRepository.GetActiveAsync()).Select(ToDto).ToList();

    public async Task<ReferralSourceDto> CreateAsync(SaveReferralSourceDto request)
    {
        if (await _referralSourceRepository.ExistsByNameAsync(request.Name))
        {
            throw new InvalidOperationException("A referral source with this name already exists.");
        }

        var referralSource = new ReferralSource { Name = request.Name };
        await _referralSourceRepository.AddAsync(referralSource);

        return ToDto(referralSource);
    }

    public async Task<ReferralSourceDto?> UpdateAsync(int id, SaveReferralSourceDto request)
    {
        var referralSource = await _referralSourceRepository.GetByIdAsync(id);
        if (referralSource is null)
        {
            return null;
        }

        if (await _referralSourceRepository.ExistsByNameAsync(request.Name, excludingId: id))
        {
            throw new InvalidOperationException("A referral source with this name already exists.");
        }

        referralSource.Name = request.Name;
        await _referralSourceRepository.SaveChangesAsync();

        return ToDto(referralSource);
    }

    public async Task<bool> SetActiveAsync(int id, bool isActive)
    {
        var referralSource = await _referralSourceRepository.GetByIdAsync(id);
        if (referralSource is null)
        {
            return false;
        }

        referralSource.IsActive = isActive;
        await _referralSourceRepository.SaveChangesAsync();

        return true;
    }

    private static ReferralSourceDto ToDto(ReferralSource referralSource) => new()
    {
        Id = referralSource.Id,
        Name = referralSource.Name,
        IsActive = referralSource.IsActive
    };
}
