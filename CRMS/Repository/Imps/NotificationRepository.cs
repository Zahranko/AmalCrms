using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class NotificationRepository : INotificationRepository
{
    private readonly AppDbContext _context;

    public NotificationRepository(AppDbContext context)
    {
        _context = context;
    }

    public void Add(Notification notification) => _context.Notifications.Add(notification);

    public Task<List<Notification>> GetForUserAsync(int userId) =>
        _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();

    public Task<int> GetUnreadCountAsync(int userId) =>
        _context.Notifications.CountAsync(n => n.UserId == userId && !n.IsRead);

    public Task<Notification?> GetByIdAsync(int id) =>
        _context.Notifications.FirstOrDefaultAsync(n => n.Id == id);

    public void Remove(Notification notification) => _context.Notifications.Remove(notification);

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
