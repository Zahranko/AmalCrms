using CRMS.Data.DTOs.Notifications;
using CRMS.Data.Models;
using CRMS.Hubs;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;

namespace CRMS.Services.Imps;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _notificationRepository;
    private readonly IHubContext<NotificationHub> _hubContext;

    public NotificationService(
        INotificationRepository notificationRepository,
        IHubContext<NotificationHub> hubContext)
    {
        _notificationRepository = notificationRepository;
        _hubContext = hubContext;
    }

    public async Task<List<NotificationDto>> GetForUserAsync(int userId) =>
        (await _notificationRepository.GetForUserAsync(userId)).Select(ToDto).ToList();

    public Task<int> GetUnreadCountAsync(int userId) =>
        _notificationRepository.GetUnreadCountAsync(userId);

    public async Task<bool> MarkReadAsync(int userId, int notificationId)
    {
        var notification = await _notificationRepository.GetByIdAsync(notificationId);
        if (notification is null || notification.UserId != userId)
        {
            return false;
        }

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            await _notificationRepository.SaveChangesAsync();
        }

        return true;
    }

    public async Task<bool> DeleteAsync(int userId, int notificationId)
    {
        var notification = await _notificationRepository.GetByIdAsync(notificationId);
        if (notification is null || notification.UserId != userId)
        {
            return false;
        }

        _notificationRepository.Remove(notification);
        await _notificationRepository.SaveChangesAsync();
        return true;
    }

    public async Task MarkAllReadAsync(int userId)
    {
        var notifications = await _notificationRepository.GetForUserAsync(userId);
        var changed = false;

        foreach (var notification in notifications.Where(n => !n.IsRead))
        {
            notification.IsRead = true;
            changed = true;
        }

        if (changed)
        {
            await _notificationRepository.SaveChangesAsync();
        }
    }

    public async Task AddAndPushAsync(Notification notification)
    {
        _notificationRepository.Add(notification);
        await _notificationRepository.SaveChangesAsync();
        await PushAsync(notification);
    }

    public async Task AddAndPushManyAsync(IReadOnlyCollection<Notification> notifications)
    {
        if (notifications.Count == 0) return;

        foreach (var notification in notifications)
        {
            _notificationRepository.Add(notification);
        }
        await _notificationRepository.SaveChangesAsync();

        foreach (var notification in notifications)
        {
            await PushAsync(notification);
        }
    }

    // The business action (create/forward/…) is already committed by the time we
    // push, so a hub failure must not surface as an error on that action — the
    // recipient still finds the notification in their list.
    private async Task PushAsync(Notification notification)
    {
        try
        {
            await _hubContext.Clients
                .Group($"user-{notification.UserId}")
                .SendAsync("NewNotification", ToDto(notification));
        }
        catch
        {
            // Real-time delivery is best-effort only.
        }
    }

    private static NotificationDto ToDto(Notification notification) => new()
    {
        Id = notification.Id,
        Message = notification.Message,
        CustomerId = notification.CustomerId,
        Type = notification.Type.ToString(),
        IsRead = notification.IsRead,
        CreatedAt = notification.CreatedAt
    };
}
