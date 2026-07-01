using CRMS.Data.DTOs.ReferralSources;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/referral-sources")]
public class ReferralSourcesController : ControllerBase
{
    private readonly IReferralSourceService _referralSourceService;

    public ReferralSourcesController(IReferralSourceService referralSourceService)
    {
        _referralSourceService = referralSourceService;
    }

    [HttpGet]
    public async Task<ActionResult<List<ReferralSourceDto>>> GetActive()
    {
        return Ok(await _referralSourceService.GetActiveAsync());
    }

    [HttpGet("manage")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<List<ReferralSourceDto>>> GetAll()
    {
        return Ok(await _referralSourceService.GetAllAsync());
    }

    [HttpPost]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<ReferralSourceDto>> Create(SaveReferralSourceDto request)
    {
        try
        {
            var referralSource = await _referralSourceService.CreateAsync(request);
            return CreatedAtAction(nameof(GetAll), referralSource);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<ReferralSourceDto>> Update(int id, SaveReferralSourceDto request)
    {
        try
        {
            var referralSource = await _referralSourceService.UpdateAsync(id, request);
            return referralSource is null ? NotFound() : Ok(referralSource);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPatch("{id}/status")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<IActionResult> SetStatus(int id, UpdateReferralSourceStatusDto request)
    {
        var success = await _referralSourceService.SetActiveAsync(id, request.IsActive);
        return success ? NoContent() : NotFound();
    }
}
