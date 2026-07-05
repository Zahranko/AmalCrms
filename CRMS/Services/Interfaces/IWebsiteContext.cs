namespace CRMS.Services.Interfaces;

// Request-scoped holder for the active website. Set once per request by
// WebsiteContextMiddleware from the X-Website-Id header, then read by
// AppDbContext's global query filter (reads) and SaveChanges stamping (writes).
// Null until set — an unset context makes every tenant query return nothing,
// which is the safe failure mode (never leak another website's rows).
public interface IWebsiteContext
{
    int? WebsiteId { get; }
    void SetWebsite(int websiteId);
}
