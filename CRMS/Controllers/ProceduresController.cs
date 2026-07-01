using CRMS.Data.DTOs.Procedures;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/procedures")]
public class ProceduresController : ControllerBase
{
    private readonly IProcedureService _procedureService;

    public ProceduresController(IProcedureService procedureService)
    {
        _procedureService = procedureService;
    }

    [HttpGet]
    [Authorize]
    public async Task<ActionResult<List<ProcedureDto>>> GetActive() =>
        Ok(await _procedureService.GetActiveAsync());

    [HttpGet("manage")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<List<ProcedureDto>>> GetAll() =>
        Ok(await _procedureService.GetAllAsync());

    [HttpPost]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<ProcedureDto>> Create(SaveProcedureDto request)
    {
        try
        {
            var procedure = await _procedureService.CreateAsync(request);
            return CreatedAtAction(nameof(GetAll), procedure);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<ProcedureDto>> Update(int id, SaveProcedureDto request)
    {
        try
        {
            var procedure = await _procedureService.UpdateAsync(id, request);
            return procedure is null ? NotFound() : Ok(procedure);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPatch("{id}/status")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<IActionResult> SetStatus(int id, UpdateProcedureStatusDto request)
    {
        var success = await _procedureService.SetActiveAsync(id, request.IsActive);
        return success ? NoContent() : NotFound();
    }
}
