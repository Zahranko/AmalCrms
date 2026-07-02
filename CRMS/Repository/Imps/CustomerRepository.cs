using System.Linq.Expressions;
using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Repository.Imps;

public class CustomerRepository : ICustomerRepository
{
    private readonly AppDbContext _context;

    public CustomerRepository(AppDbContext context)
    {
        _context = context;
    }

    private IQueryable<Customer> WithCaseIncludes() =>
        _context.Customers
            .Include(c => c.ReferralSource)
            .Include(c => c.Procedure)
            .Include(c => c.Department)
            .Include(c => c.Doctor)
            .Include(c => c.CreatedBy)
            .Include(c => c.AssignedTo)
            .Include(c => c.ForwardedBy)
            .Include(c => c.PendingForwardTo);

    private static IQueryable<Customer> ExcludeCompleted(IQueryable<Customer> q) =>
        q.Where(c => c.Status != CustomerStatus.Success && c.Status != CustomerStatus.Failed);

    // 'from'/'to' are calendar dates (e.g. from a date picker) in the users'
    // local time zone (same as the server's — single-site deployment), and 'to'
    // is inclusive of its whole day. CreatedAt is stored in UTC, so convert each
    // day boundary to UTC before comparing — otherwise cases created within a
    // few hours of midnight land in the wrong day/month bucket.
    private static IQueryable<Customer> ApplyDateRange(IQueryable<Customer> q, DateTime? from, DateTime? to)
    {
        if (from.HasValue)
        {
            var fromUtc = ToUtcDayStart(from.Value);
            q = q.Where(c => c.CreatedAt >= fromUtc);
        }
        if (to.HasValue)
        {
            var toExclusiveUtc = ToUtcDayStart(to.Value.AddDays(1));
            q = q.Where(c => c.CreatedAt < toExclusiveUtc);
        }
        return q;
    }

    private static DateTime ToUtcDayStart(DateTime date) =>
        DateTime.SpecifyKind(date.Date, DateTimeKind.Local).ToUniversalTime();

    public async Task AddAsync(Customer customer)
    {
        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();
    }

    public Task<Customer?> GetByIdAsync(int id) =>
        WithCaseIncludes().FirstOrDefaultAsync(c => c.Id == id);

    public Task<List<Customer>> GetAllAsync(bool excludeCompleted = false)
    {
        var q = WithCaseIncludes().OrderByDescending(c => c.CreatedAt);
        return (excludeCompleted ? ExcludeCompleted(q) : q).ToListAsync();
    }

    public Task<List<Customer>> GetMineAsync(int userId, bool excludeCompleted = false)
    {
        var q = WithCaseIncludes()
            .Where(c => c.AssignedToUserId == userId)
            .OrderByDescending(c => c.CreatedAt);
        return (excludeCompleted ? ExcludeCompleted(q) : q).ToListAsync();
    }

    // Pending (not yet accepted) OR accepted (I own it, ForwardedBy is set, no pending re-forward).
    public Task<List<Customer>> GetForwardedToMeAsync(int userId, bool excludeCompleted = false)
    {
        var q = WithCaseIncludes()
            .Where(c =>
                c.PendingForwardToUserId == userId ||
                (c.AssignedToUserId == userId && c.ForwardedByUserId != null && c.PendingForwardToUserId == null))
            .OrderByDescending(c => c.CreatedAt);
        return (excludeCompleted ? ExcludeCompleted(q) : q).ToListAsync();
    }

    // Cases I forwarded (pending outgoing) OR cases I forwarded and were accepted.
    public Task<List<Customer>> GetForwardedByMeAsync(int userId, bool excludeCompleted = false)
    {
        var q = WithCaseIncludes()
            .Where(c =>
                c.ForwardedByUserId == userId ||
                (c.AssignedToUserId == userId && c.PendingForwardToUserId != null))
            .OrderByDescending(c => c.CreatedAt);
        return (excludeCompleted ? ExcludeCompleted(q) : q).ToListAsync();
    }

    public Task<List<Customer>> GetAllFilteredAsync(string? search, int? assignedToUserId, bool todayOnly)
    {
        var q = WithCaseIncludes();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            q = q.Where(c => c.Name.Contains(term) || c.PhoneNumber.Contains(term) || c.PhoneCountryCode.Contains(term));
        }

        if (assignedToUserId.HasValue)
            q = q.Where(c => c.AssignedToUserId == assignedToUserId.Value);

        if (todayOnly)
        {
            var today = DateTime.UtcNow.Date;
            q = q.Where(c => c.CreatedAt >= today && c.CreatedAt < today.AddDays(1));
        }

        return q.OrderByDescending(c => c.CreatedAt).ToListAsync();
    }

    public Task<int> CountAllAsync() => _context.Customers.CountAsync();

    public async Task<Dictionary<CustomerStatus, int>> GetStatusCountsAsync(DateTime? from = null, DateTime? to = null)
    {
        var groups = await ApplyDateRange(_context.Customers, from, to)
            .GroupBy(c => c.Status)
            .Select(g => new { Status = g.Key, Count = g.Count() })
            .ToListAsync();
        return groups.ToDictionary(g => g.Status, g => g.Count);
    }

    public async Task<Dictionary<int, int>> GetReferralSourceCountsAsync()
    {
        var groups = await _context.Customers
            .GroupBy(c => c.ReferralSourceId)
            .Select(g => new { Id = g.Key, Count = g.Count() })
            .ToListAsync();
        return groups.ToDictionary(g => g.Id, g => g.Count);
    }

    public async Task<List<(int UserId, int Total, int Success, int Failed)>> GetCaseCountsByCreatorAsync()
    {
        var groups = await _context.Customers
            .Where(c => c.CreatedByUserId.HasValue)
            .GroupBy(c => c.CreatedByUserId!.Value)
            .Select(g => new
            {
                UserId = g.Key,
                Total = g.Count(),
                Success = g.Count(c => c.Status == CustomerStatus.Success),
                Failed = g.Count(c => c.Status == CustomerStatus.Failed)
            })
            .ToListAsync();
        return groups.Select(g => (g.UserId, g.Total, g.Success, g.Failed)).ToList();
    }

    public Task<List<(int DepartmentId, int Total, int Success, int Failed)>> GetCaseCountsByDepartmentAsync(DateTime? from = null, DateTime? to = null) =>
        GetCaseCountsGroupedAsync(c => c.DepartmentId, from, to);

    public Task<List<(int DoctorId, int Total, int Success, int Failed)>> GetCaseCountsByDoctorAsync(DateTime? from = null, DateTime? to = null) =>
        GetCaseCountsGroupedAsync(c => c.DoctorId, from, to);

    // Groups cases by a nullable FK (department/doctor); rows without that FK
    // fall into the null group, which is dropped after the query.
    private async Task<List<(int Key, int Total, int Success, int Failed)>> GetCaseCountsGroupedAsync(
        Expression<Func<Customer, int?>> keySelector, DateTime? from, DateTime? to)
    {
        var groups = await ApplyDateRange(_context.Customers, from, to)
            .GroupBy(keySelector)
            .Select(g => new
            {
                g.Key,
                Total = g.Count(),
                Success = g.Count(c => c.Status == CustomerStatus.Success),
                Failed = g.Count(c => c.Status == CustomerStatus.Failed)
            })
            .ToListAsync();
        return groups
            .Where(g => g.Key.HasValue)
            .Select(g => (g.Key!.Value, g.Total, g.Success, g.Failed))
            .ToList();
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
