using CRMS.Data.Models;

namespace CRMS.Repository.Interfaces;

public interface INotificationRepository
{
    void Add(Notification notification);
    Task<List<Notification>> GetForUserAsync(int userId);
    Task<int> GetUnreadCountAsync(int userId);
    Task<Notification?> GetByIdAsync(int id);
    void Remove(Notification notification);
    Task SaveChangesAsync();
}
