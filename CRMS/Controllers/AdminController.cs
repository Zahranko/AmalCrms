using System.Security.Claims;
using CRMS.Data.DTOs.Admin;
using CRMS.Data.DTOs.Cases;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = nameof(Role.Admin))]
public class AdminController : ControllerBase
{
    private readonly ICaseService _caseService;

    public AdminController(ICaseService caseService)
    {
        _caseService = caseService;
    }

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet("stats")]
    public async Task<ActionResult<AdminStatsDto>> GetStats() =>
        Ok(await _caseService.GetStatsAsync());

    [HttpGet("cases")]
    public async Task<ActionResult<List<CaseDto>>> GetAllCases(
        [FromQuery] string? search,
        [FromQuery] int? assignedToUserId,
        [FromQuery] bool todayOnly = false) =>
        Ok(await _caseService.GetAllCasesAsync(search, assignedToUserId, todayOnly));

    [HttpPost("cases/{id:int}/follow-up")]
    public Task<ActionResult<CaseDetailDto>> FollowUp(int id, FollowUpDto request) =>
        Run(() => _caseService.AdminFollowUpAsync(id, CurrentUserId, request));

    private async Task<ActionResult<T>> Run<T>(Func<Task<T>> action)
    {
        try { return Ok(await action()); }
        catch (InvalidOperationException ex) { return Conflict(new { message = ex.Message }); }
    }
}
