using CRMS.Data.DTOs.Notifications;

namespace CRMS.Services.Interfaces;

public interface INotificationService
{
    Task<List<NotificationDto>> GetForUserAsync(int userId);
    Task<int> GetUnreadCountAsync(int userId);
    Task<bool> MarkReadAsync(int userId, int notificationId);
    Task MarkAllReadAsync(int userId);
    Task<bool> DeleteAsync(int userId, int notificationId);
}
