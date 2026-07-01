using CRMS.Data.DTOs.Doctors;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/doctors")]
[Authorize]
public class DoctorsController : ControllerBase
{
    private readonly IDoctorService _doctorService;

    public DoctorsController(IDoctorService doctorService)
    {
        _doctorService = doctorService;
    }

    [HttpGet]
    public async Task<ActionResult<List<DoctorDto>>> GetActive()
    {
        return Ok(await _doctorService.GetActiveAsync());
    }

    [HttpGet("manage")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<List<DoctorDto>>> GetAll()
    {
        return Ok(await _doctorService.GetAllAsync());
    }

    [HttpPost]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<DoctorDto>> Create(SaveDoctorDto request)
    {
        try
        {
            var doctor = await _doctorService.CreateAsync(request);
            return CreatedAtAction(nameof(GetAll), doctor);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<DoctorDto>> Update(int id, SaveDoctorDto request)
    {
        try
        {
            var doctor = await _doctorService.UpdateAsync(id, request);
            return doctor is null ? NotFound() : Ok(doctor);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPatch("{id}/status")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<IActionResult> SetStatus(int id, UpdateDoctorStatusDto request)
    {
        var success = await _doctorService.SetActiveAsync(id, request.IsActive);
        return success ? NoContent() : NotFound();
    }
}
