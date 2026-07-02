using CRMS.Data.DTOs.HospitalManager;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/hospital-manager")]
[Authorize(Roles = $"{nameof(Role.HospitalManager)},{nameof(Role.Admin)}")]
public class HospitalManagerController : ControllerBase
{
    private readonly ICaseService _caseService;
    private readonly IHospitalManagerExcelReportService _excelReportService;

    public HospitalManagerController(ICaseService caseService, IHospitalManagerExcelReportService excelReportService)
    {
        _caseService = caseService;
        _excelReportService = excelReportService;
    }

    [HttpGet("stats")]
    public async Task<ActionResult<HospitalManagerStatsDto>> GetStats([FromQuery] DateTime? from, [FromQuery] DateTime? to) =>
        Ok(await _caseService.GetHospitalManagerStatsAsync(from, to));

    [HttpGet("stats/export")]
    public async Task<IActionResult> ExportStats([FromQuery] DateTime? from, [FromQuery] DateTime? to)
    {
        var stats = await _caseService.GetHospitalManagerStatsAsync(from, to);
        var bytes = _excelReportService.Build(stats);
        var fileName = $"hospital-report-{DateTime.UtcNow:yyyyMMdd-HHmm}.xlsx";
        return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
    }
}
