using CRMS.Data.DTOs.Admin;
using CRMS.Data.DTOs.Cases;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class CaseService : ICaseService
{
    private readonly ICustomerRepository _customerRepository;
    private readonly ICaseActionRepository _caseActionRepository;
    private readonly IUserRepository _userRepository;
    private readonly IReferralSourceRepository _referralSourceRepository;
    private readonly IProcedureRepository _procedureRepository;
    private readonly IDepartmentRepository _departmentRepository;
    private readonly IDoctorRepository _doctorRepository;
    private readonly INotificationRepository _notificationRepository;

    public CaseService(
        ICustomerRepository customerRepository,
        ICaseActionRepository caseActionRepository,
        IUserRepository userRepository,
        IReferralSourceRepository referralSourceRepository,
        IProcedureRepository procedureRepository,
        IDepartmentRepository departmentRepository,
        IDoctorRepository doctorRepository,
        INotificationRepository notificationRepository)
    {
        _customerRepository = customerRepository;
        _caseActionRepository = caseActionRepository;
        _userRepository = userRepository;
        _referralSourceRepository = referralSourceRepository;
        _procedureRepository = procedureRepository;
        _departmentRepository = departmentRepository;
        _doctorRepository = doctorRepository;
        _notificationRepository = notificationRepository;
    }

    public async Task<CaseDto> CreateAsync(CreateCaseDto request, int userId)
    {
        var referralSource = await _referralSourceRepository.GetByIdAsync(request.ReferralSourceId);
        if (referralSource is null || !referralSource.IsActive)
            throw new InvalidOperationException("Please select a valid referral source.");

        var department = await _departmentRepository.GetByIdAsync(request.DepartmentId);
        if (department is null || !department.IsActive)
            throw new InvalidOperationException("Please select a valid department.");

        var procedure = await _procedureRepository.GetByIdAsync(request.ProcedureId);
        if (procedure is null || !procedure.IsActive)
            throw new InvalidOperationException("Please select a valid procedure.");

        int? doctorId = null;
        if (request.DoctorId.HasValue)
        {
            var doctor = await _doctorRepository.GetByIdAsync(request.DoctorId.Value);
            if (doctor is null || !doctor.IsActive)
                throw new InvalidOperationException("Please select a valid doctor.");
            doctorId = doctor.Id;
        }

        var customer = new Customer
        {
            Name = request.Name,
            PhoneCountryCode = request.PhoneCountryCode,
            PhoneNumber = request.PhoneNumber,
            ReferralSourceId = referralSource.Id,
            ProcedureId = procedure.Id,
            Description = request.Description,
            DepartmentId = department.Id,
            HasDoctor = request.HasDoctor,
            DoctorId = doctorId,
            Status = CustomerStatus.Pending,
            CreatedByUserId = userId,
            AssignedToUserId = null   // starts unassigned; employees claim via dashboard
        };

        await _customerRepository.AddAsync(customer);

        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            Type = CaseActionType.Created,
            ResultingStatus = CustomerStatus.Pending,
            ActionDate = customer.CreatedAt
        });
        await _customerRepository.SaveChangesAsync();

        await NotifyNewCaseAsync(customer, userId);

        return ToDto((await _customerRepository.GetByIdAsync(customer.Id))!);
    }

    // A new case starts unassigned and anyone may claim it, so every other
    // active user is alerted that a new case is waiting to be picked up.
    private async Task NotifyNewCaseAsync(Customer customer, int creatorUserId)
    {
        var creator = await _userRepository.GetByIdAsync(creatorUserId);
        var creatorName = creator?.Username ?? "Someone";

        var recipients = (await _userRepository.GetAllAsync())
            .Where(u => u.IsActive && u.Id != creatorUserId && u.NotifyOnNewCase)
            .ToList();

        if (recipients.Count == 0) return;

        foreach (var recipient in recipients)
        {
            _notificationRepository.Add(new Notification
            {
                UserId = recipient.Id,
                CustomerId = customer.Id,
                Type = NotificationType.CaseCreated,
                Message = $"New case \"{customer.Name}\" created by {creatorName} is waiting to be assigned."
            });
        }

        await _notificationRepository.SaveChangesAsync();
    }

    public async Task<List<CaseDto>> GetAllAsync(bool excludeCompleted = false) =>
        (await _customerRepository.GetAllAsync(excludeCompleted)).Select(ToDto).ToList();

    public async Task<List<CaseDto>> GetMineAsync(int userId, bool excludeCompleted = false) =>
        (await _customerRepository.GetMineAsync(userId, excludeCompleted)).Select(ToDto).ToList();

    public async Task<List<CaseDto>> GetForwardedToMeAsync(int userId, bool excludeCompleted = false) =>
        (await _customerRepository.GetForwardedToMeAsync(userId, excludeCompleted)).Select(ToDto).ToList();

    public async Task<List<CaseDto>> GetForwardedByMeAsync(int userId, bool excludeCompleted = false) =>
        (await _customerRepository.GetForwardedByMeAsync(userId, excludeCompleted)).Select(ToDto).ToList();

    public async Task<CaseDetailDto?> GetDetailAsync(int caseId)
    {
        var customer = await _customerRepository.GetByIdAsync(caseId);
        return customer is null ? null : await ToDetailDto(customer);
    }

    public async Task<CaseDetailDto> ClaimAsync(int caseId, int userId)
    {
        var customer = await GetCaseOrThrow(caseId);

        if (customer.AssignedToUserId == userId)
            throw new InvalidOperationException("This case is already assigned to you.");

        customer.AssignedToUserId = userId;

        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            Type = CaseActionType.Claimed,
            ActionDate = DateTime.UtcNow
        });
        await _customerRepository.SaveChangesAsync();

        return await ReloadDetail(customer.Id);
    }

    public async Task<CaseDetailDto> ForwardAsync(int caseId, int userId, ForwardDto request)
    {
        var customer = await GetCaseOrThrow(caseId);

        if (customer.AssignedToUserId != userId)
            throw new InvalidOperationException("You can only forward cases assigned to you.");

        if (customer.PendingForwardToUserId.HasValue)
            throw new InvalidOperationException("This case already has a pending forward. Wait for the recipient to accept or decline.");

        if (request.ToUserId == userId)
            throw new InvalidOperationException("You cannot forward a case to yourself.");

        var target = await _userRepository.GetByIdAsync(request.ToUserId);
        if (target is null || !target.IsActive)
            throw new InvalidOperationException("Please select a valid active user to forward to.");

        customer.PendingForwardToUserId = request.ToUserId;

        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            TargetUserId = request.ToUserId,
            Type = CaseActionType.Forwarded,
            ActionDate = DateTime.UtcNow,
            Note = string.IsNullOrWhiteSpace(request.Note) ? null : request.Note.Trim()
        });
        await _customerRepository.SaveChangesAsync();

        var actor = await _userRepository.GetByIdAsync(userId);
        _notificationRepository.Add(new Notification
        {
            UserId = request.ToUserId,
            CustomerId = customer.Id,
            Type = NotificationType.CaseForwarded,
            Message = $"{actor?.Username ?? "Someone"} forwarded case \"{customer.Name}\" to you."
        });
        await _notificationRepository.SaveChangesAsync();

        return await ReloadDetail(customer.Id);
    }

    public async Task<CaseDetailDto> AcceptForwardAsync(int caseId, int userId)
    {
        var customer = await GetCaseOrThrow(caseId);

        if (customer.PendingForwardToUserId != userId)
            throw new InvalidOperationException("This case was not forwarded to you.");

        var previousOwnerId = customer.AssignedToUserId;
        customer.AssignedToUserId = userId;
        customer.ForwardedByUserId = previousOwnerId;
        customer.PendingForwardToUserId = null;

        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            TargetUserId = previousOwnerId,
            Type = CaseActionType.ForwardAccepted,
            ActionDate = DateTime.UtcNow
        });
        await _customerRepository.SaveChangesAsync();

        if (previousOwnerId.HasValue)
        {
            var actor = await _userRepository.GetByIdAsync(userId);
            _notificationRepository.Add(new Notification
            {
                UserId = previousOwnerId.Value,
                CustomerId = customer.Id,
                Type = NotificationType.ForwardAccepted,
                Message = $"{actor?.Username ?? "Someone"} accepted case \"{customer.Name}\" that you forwarded."
            });
            await _notificationRepository.SaveChangesAsync();
        }

        return await ReloadDetail(customer.Id);
    }

    public async Task<CaseDetailDto> DeclineForwardAsync(int caseId, int userId)
    {
        var customer = await GetCaseOrThrow(caseId);

        if (customer.PendingForwardToUserId != userId)
            throw new InvalidOperationException("This case was not forwarded to you.");

        var previousOwnerId = customer.AssignedToUserId;
        customer.PendingForwardToUserId = null;

        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            TargetUserId = previousOwnerId,
            Type = CaseActionType.ForwardDeclined,
            ActionDate = DateTime.UtcNow
        });
        await _customerRepository.SaveChangesAsync();

        if (previousOwnerId.HasValue)
        {
            var actor = await _userRepository.GetByIdAsync(userId);
            _notificationRepository.Add(new Notification
            {
                UserId = previousOwnerId.Value,
                CustomerId = customer.Id,
                Type = NotificationType.ForwardDeclined,
                Message = $"{actor?.Username ?? "Someone"} declined case \"{customer.Name}\" that you forwarded."
            });
            await _notificationRepository.SaveChangesAsync();
        }

        return await ReloadDetail(customer.Id);
    }

    public Task<CaseDetailDto> FollowUpAsync(int caseId, int userId, FollowUpDto request) =>
        FollowUpCoreAsync(caseId, userId, request, checkOwner: false);

    public Task<CaseDetailDto> AdminFollowUpAsync(int caseId, int userId, FollowUpDto request) =>
        FollowUpCoreAsync(caseId, userId, request, checkOwner: false);

    private async Task<CaseDetailDto> FollowUpCoreAsync(int caseId, int userId, FollowUpDto request, bool checkOwner)
    {
        var customer = await GetCaseOrThrow(caseId);
        if (checkOwner) EnsureOwner(customer, userId);

        var action = new CaseAction
        {
            CustomerId = customer.Id,
            ActorUserId = userId,
            Type = CaseActionType.FollowUp,
            ResultingStatus = request.Status,
            ActionDate = request.Date ?? DateTime.UtcNow,
            Note = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim()
        };

        if (request.Status == CustomerStatus.Waiting)
        {
            var department = await _departmentRepository.GetByIdAsync(request.DepartmentId ?? 0);
            if (department is null || !department.IsActive)
                throw new InvalidOperationException("Please select a valid department for the appointment.");

            if (string.IsNullOrWhiteSpace(request.Notes))
                throw new InvalidOperationException("Please add follow-up notes.");

            customer.DepartmentId = department.Id;
            customer.AppointmentDate = request.Date;
            customer.HasDoctor = request.HasDoctor ?? false;
            action.DepartmentId = department.Id;

            if (request.DoctorId.HasValue)
            {
                var doctor = await _doctorRepository.GetByIdAsync(request.DoctorId.Value);
                if (doctor is null || !doctor.IsActive)
                    throw new InvalidOperationException("Please select a valid doctor.");
                customer.DoctorId = doctor.Id;
                action.DoctorId = doctor.Id;
            }
            else
            {
                customer.DoctorId = null;
            }
        }
        else if (request.Status == CustomerStatus.Success)
        {
            // Clinics (عيادات) follow-up: signature required, doctor optional
            customer.HasDoctor = request.HasDoctor ?? false;
            if (request.HasDoctor == true)
            {
                if (string.IsNullOrWhiteSpace(request.SignatureData))
                    throw new InvalidOperationException("A signature is required for a clinic (عيادات) follow-up.");
                customer.ClinicSignature = request.SignatureData;
                if (request.DoctorId.HasValue)
                {
                    var doctor = await _doctorRepository.GetByIdAsync(request.DoctorId.Value);
                    if (doctor is null || !doctor.IsActive)
                        throw new InvalidOperationException("Please select a valid doctor.");
                    customer.DoctorId = doctor.Id;
                    action.DoctorId = doctor.Id;
                }
            }
            else
            {
                customer.DoctorId = null;
            }
        }
        else if (request.Status == CustomerStatus.Failed || request.Status == CustomerStatus.Pending)
        {
            if (string.IsNullOrWhiteSpace(request.Notes))
                throw new InvalidOperationException("Please add notes for this update.");
        }

        customer.Status = request.Status;
        _caseActionRepository.Add(action);
        await _customerRepository.SaveChangesAsync();

        return await ReloadDetail(customer.Id);
    }

    public async Task<CaseDetailDto> ReopenAsync(int caseId, int adminUserId)
    {
        var customer = await GetCaseOrThrow(caseId);

        if (customer.Status != CustomerStatus.Success && customer.Status != CustomerStatus.Failed)
            throw new InvalidOperationException("Only completed cases (Success or Failed) can be reopened.");

        customer.Status = CustomerStatus.Pending;
        _caseActionRepository.Add(new CaseAction
        {
            CustomerId = caseId,
            ActorUserId = adminUserId,
            Type = CaseActionType.Reopened,
            ActionDate = DateTime.UtcNow
        });
        await _customerRepository.SaveChangesAsync();

        return await ReloadDetail(customer.Id);
    }

    public async Task<AdminStatsDto> GetStatsAsync()
    {
        var total = await _customerRepository.CountAllAsync();
        var statusCounts = await _customerRepository.GetStatusCountsAsync();
        var refCounts = await _customerRepository.GetReferralSourceCountsAsync();
        var allSources = await _referralSourceRepository.GetAllAsync();
        var creatorCounts = await _customerRepository.GetCaseCountsByCreatorAsync();
        var allUsers = await _userRepository.GetAllAsync();

        var successCount = statusCounts.GetValueOrDefault(CustomerStatus.Success);
        var failedCount = statusCounts.GetValueOrDefault(CustomerStatus.Failed);

        var refStats = allSources
            .Where(r => refCounts.ContainsKey(r.Id))
            .Select(r => new ReferralSourceStatDto
            {
                Name = r.Name,
                Count = refCounts[r.Id],
                Percent = total > 0 ? Math.Round((double)refCounts[r.Id] / total * 100, 1) : 0
            })
            .OrderByDescending(r => r.Count)
            .ToList();

        var userMap = allUsers.ToDictionary(u => u.Id, u => u.Username);
        var empStats = creatorCounts
            .Select(c => new EmployeeStatDto
            {
                UserId = c.UserId,
                Username = userMap.GetValueOrDefault(c.UserId, "Unknown"),
                TotalCreated = c.Total,
                SuccessCount = c.Success,
                FailedCount = c.Failed,
                Percent = total > 0 ? Math.Round((double)c.Total / total * 100, 1) : 0
            })
            .OrderByDescending(e => e.TotalCreated)
            .ToList();

        return new AdminStatsDto
        {
            TotalCases = total,
            SuccessCount = successCount,
            FailedCount = failedCount,
            SuccessPercent = total > 0 ? Math.Round((double)successCount / total * 100, 1) : 0,
            FailedPercent = total > 0 ? Math.Round((double)failedCount / total * 100, 1) : 0,
            ReferralSources = refStats,
            Employees = empStats
        };
    }

    public async Task<List<CaseDto>> GetAllCasesAsync(string? search, int? assignedToUserId, bool todayOnly) =>
        (await _customerRepository.GetAllFilteredAsync(search, assignedToUserId, todayOnly)).Select(ToDto).ToList();

    private async Task<Customer> GetCaseOrThrow(int caseId)
    {
        var customer = await _customerRepository.GetByIdAsync(caseId);
        if (customer is null)
            throw new InvalidOperationException("This case no longer exists.");
        return customer;
    }

    private static void EnsureOwner(Customer customer, int userId)
    {
        if (customer.AssignedToUserId != userId)
            throw new InvalidOperationException("This case is not currently assigned to you.");
    }

    private async Task<CaseDetailDto> ReloadDetail(int caseId)
    {
        var customer = await _customerRepository.GetByIdAsync(caseId);
        return await ToDetailDto(customer!);
    }

    private static CaseDto ToDto(Customer customer) => new()
    {
        Id = customer.Id,
        Name = customer.Name,
        PhoneCountryCode = customer.PhoneCountryCode,
        PhoneNumber = customer.PhoneNumber,
        Department = customer.Department?.Name,
        Status = customer.Status.ToString(),
        CreatedByUsername = customer.CreatedBy?.Username,
        AssignedToUsername = customer.AssignedTo?.Username,
        ForwardedToUsername = customer.PendingForwardTo?.Username,
        ForwardedByUsername = customer.ForwardedBy?.Username,
        HasPendingForward = customer.PendingForwardToUserId.HasValue,
        CreatedAt = customer.CreatedAt,
        ReferralSource = customer.ReferralSource?.Name,
        Procedure = customer.Procedure?.Name,
    };

    private async Task<CaseDetailDto> ToDetailDto(Customer customer)
    {
        var history = await _caseActionRepository.GetByCustomerAsync(customer.Id);

        return new CaseDetailDto
        {
            Id = customer.Id,
            Name = customer.Name,
            PhoneCountryCode = customer.PhoneCountryCode,
            PhoneNumber = customer.PhoneNumber,
            ReferralSource = customer.ReferralSource?.Name ?? string.Empty,
            Procedure = customer.Procedure?.Name,
            Description = customer.Description,
            Status = customer.Status.ToString(),
            Department = customer.Department?.Name,
            HasDoctor = customer.HasDoctor,
            Doctor = customer.Doctor?.Name,
            AppointmentDate = customer.AppointmentDate,
            CreatedByUsername = customer.CreatedBy?.Username,
            AssignedToUsername = customer.AssignedTo?.Username,
            ForwardedToUsername = customer.PendingForwardTo?.Username,
            CreatedAt = customer.CreatedAt,
            ClinicSignature = customer.ClinicSignature,
            History = history.Select(a => new CaseActionDto
            {
                Id = a.Id,
                Type = a.Type.ToString(),
                ResultingStatus = a.ResultingStatus?.ToString(),
                ActorUsername = a.Actor?.Username,
                TargetUsername = a.Target?.Username,
                ActionDate = a.ActionDate,
                DepartmentName = a.Department?.Name,
                DoctorName = a.Doctor?.Name,
                Note = a.Note,
                CreatedAt = a.CreatedAt
            }).ToList()
        };
    }
}
