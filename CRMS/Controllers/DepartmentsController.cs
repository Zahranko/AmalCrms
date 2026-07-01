using CRMS.Data.DTOs.Departments;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/departments")]
public class DepartmentsController : ControllerBase
{
    private readonly IDepartmentService _departmentService;

    public DepartmentsController(IDepartmentService departmentService)
    {
        _departmentService = departmentService;
    }

    [HttpGet]
    public async Task<ActionResult<List<DepartmentDto>>> GetActive()
    {
        return Ok(await _departmentService.GetActiveAsync());
    }

    [HttpGet("manage")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<List<DepartmentDto>>> GetAll()
    {
        return Ok(await _departmentService.GetAllAsync());
    }

    [HttpPost]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<DepartmentDto>> Create(SaveDepartmentDto request)
    {
        try
        {
            var department = await _departmentService.CreateAsync(request);
            return CreatedAtAction(nameof(GetAll), department);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<ActionResult<DepartmentDto>> Update(int id, SaveDepartmentDto request)
    {
        try
        {
            var department = await _departmentService.UpdateAsync(id, request);
            return department is null ? NotFound() : Ok(department);
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPatch("{id}/status")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<IActionResult> SetStatus(int id, UpdateDepartmentStatusDto request)
    {
        var success = await _departmentService.SetActiveAsync(id, request.IsActive);
        return success ? NoContent() : NotFound();
    }
}
