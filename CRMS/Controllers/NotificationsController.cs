using System.Security.Claims;
using CRMS.Data.DTOs.Notifications;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CRMS.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<ActionResult<List<NotificationDto>>> GetMine() =>
        Ok(await _notificationService.GetForUserAsync(CurrentUserId));

    [HttpGet("unread-count")]
    public async Task<ActionResult<object>> GetUnreadCount() =>
        Ok(new { count = await _notificationService.GetUnreadCountAsync(CurrentUserId) });

    [HttpPost("{id}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        var success = await _notificationService.MarkReadAsync(CurrentUserId, id);
        return success ? NoContent() : NotFound();
    }

    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        await _notificationService.MarkAllReadAsync(CurrentUserId);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var success = await _notificationService.DeleteAsync(CurrentUserId, id);
        return success ? NoContent() : NotFound();
    }
}
