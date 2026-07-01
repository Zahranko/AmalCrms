using System.Security.Claims;
using CRMS.Data.DTOs.Cases;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/cases")]
[Authorize]
public class CasesController : ControllerBase
{
    private readonly ICaseService _caseService;

    public CasesController(ICaseService caseService)
    {
        _caseService = caseService;
    }

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool IsAdmin => User.IsInRole("Admin");

    [HttpPost]
    public Task<ActionResult<CaseDto>> Create(CreateCaseDto request) =>
        Run(() => _caseService.CreateAsync(request, CurrentUserId));

    [HttpGet("all")]
    public async Task<ActionResult<List<CaseDto>>> GetAll() =>
        Ok(await _caseService.GetAllAsync(excludeCompleted: !IsAdmin));

    [HttpGet("mine")]
    public async Task<ActionResult<List<CaseDto>>> GetMine() =>
        Ok(await _caseService.GetMineAsync(CurrentUserId, excludeCompleted: !IsAdmin));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<CaseDetailDto>> GetById(int id)
    {
        var detail = await _caseService.GetDetailAsync(id);
        return detail is null ? NotFound() : Ok(detail);
    }

    [HttpGet("forwarded-to-me")]
    public async Task<ActionResult<List<CaseDto>>> GetForwardedToMe() =>
        Ok(await _caseService.GetForwardedToMeAsync(CurrentUserId, excludeCompleted: !IsAdmin));

    [HttpGet("forwarded-by-me")]
    public async Task<ActionResult<List<CaseDto>>> GetForwardedByMe() =>
        Ok(await _caseService.GetForwardedByMeAsync(CurrentUserId, excludeCompleted: !IsAdmin));

    [HttpPost("{id:int}/claim")]
    public Task<ActionResult<CaseDetailDto>> Claim(int id) =>
        Run(() => _caseService.ClaimAsync(id, CurrentUserId));

    [HttpPost("{id:int}/forward")]
    public Task<ActionResult<CaseDetailDto>> Forward(int id, ForwardDto request) =>
        Run(() => _caseService.ForwardAsync(id, CurrentUserId, request));

    [HttpPost("{id:int}/accept-forward")]
    public Task<ActionResult<CaseDetailDto>> AcceptForward(int id) =>
        Run(() => _caseService.AcceptForwardAsync(id, CurrentUserId));

    [HttpPost("{id:int}/decline-forward")]
    public Task<ActionResult<CaseDetailDto>> DeclineForward(int id) =>
        Run(() => _caseService.DeclineForwardAsync(id, CurrentUserId));

    [HttpPost("{id:int}/follow-up")]
    public Task<ActionResult<CaseDetailDto>> FollowUp(int id, FollowUpDto request) =>
        Run(() => _caseService.FollowUpAsync(id, CurrentUserId, request));

    [HttpPost("{id:int}/reopen")]
    [Authorize(Roles = "Admin")]
    public Task<ActionResult<CaseDetailDto>> Reopen(int id) =>
        Run(() => _caseService.ReopenAsync(id, CurrentUserId));

    private async Task<ActionResult<T>> Run<T>(Func<Task<T>> action)
    {
        try
        {
            return Ok(await action());
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }
}
