using CRMS.Data.DTOs.Notifications;
using CRMS.Data.Models;

namespace CRMS.Services.Interfaces;

public interface INotificationService
{
    Task<List<NotificationDto>> GetForUserAsync(int userId);
    Task<int> GetUnreadCountAsync(int userId);
    Task<bool> MarkReadAsync(int userId, int notificationId);
    Task MarkAllReadAsync(int userId);
    Task<bool> DeleteAsync(int userId, int notificationId);

    /// Persists the notification then immediately pushes it to the recipient via SignalR.
    Task AddAndPushAsync(Notification notification);

    /// Persists all notifications in one save, then pushes each via SignalR.
    Task AddAndPushManyAsync(IReadOnlyCollection<Notification> notifications);
}
