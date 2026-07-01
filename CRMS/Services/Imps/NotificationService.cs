using CRMS.Data.DTOs.Notifications;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _notificationRepository;

    public NotificationService(INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
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
