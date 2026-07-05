using System.Security.Claims;
using CRMS.Data.DTOs.Websites;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/websites")]
[Authorize]
public class WebsitesController : ControllerBase
{
    private readonly IWebsiteService _websiteService;

    public WebsitesController(IWebsiteService websiteService)
    {
        _websiteService = websiteService;
    }

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool IsAdmin => User.IsInRole(nameof(Role.Admin));

    // Websites the caller may enter (same list the login response carries) — used
    // by the frontend's picker/switcher.
    [HttpGet("mine")]
    public async Task<ActionResult<List<WebsiteDto>>> GetMine() =>
        Ok(await _websiteService.GetAccessibleAsync(CurrentUserId, IsAdmin));

    // System parameters for the active website (X-Website-Id). Reading is allowed
    // for anyone who can access the website; only Admin can change them.
    [HttpGet("settings")]
    public async Task<ActionResult<List<WebsiteSettingDto>>> GetSettings() =>
        Ok(await _websiteService.GetSettingsAsync());

    [HttpPut("settings")]
    [Authorize(Roles = nameof(Role.Admin))]
    public async Task<IActionResult> SaveSettings(SaveWebsiteSettingsDto request)
    {
        await _websiteService.SaveSettingsAsync(request.Settings);
        return NoContent();
    }
}
