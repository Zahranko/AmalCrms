using System.Security.Claims;
using CRMS.Data.DBContext;
using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Middleware;

// Resolves the active website for a request from the X-Website-Id header and
// stores it in the request-scoped IWebsiteContext (which AppDbContext's query
// filter + write stamping read). Runs after authentication so User is populated.
//
// - No/blank/unparseable header  -> context stays unset (tenant reads return
//   nothing, tenant writes throw). Anonymous + non-tenant endpoints are unaffected.
// - Header naming a website the caller can't use (missing/inactive, or no
//   membership and not Admin) -> 403. Never silently honour an unauthorized id.
public class WebsiteContextMiddleware
{
    public const string HeaderName = "X-Website-Id";

    private readonly RequestDelegate _next;

    public WebsiteContextMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext httpContext, AppDbContext db, IWebsiteContext websiteContext)
    {
        var user = httpContext.User;

        if (user?.Identity?.IsAuthenticated == true &&
            httpContext.Request.Headers.TryGetValue(HeaderName, out var raw) &&
            int.TryParse(raw, out var websiteId))
        {
            var website = await db.Websites.AsNoTracking()
                .FirstOrDefaultAsync(w => w.Id == websiteId);

            if (website is null || !website.IsActive)
            {
                await Deny(httpContext, "The selected website is unavailable.");
                return;
            }

            var isAdmin = user.IsInRole(nameof(Role.Admin));
            if (!isAdmin)
            {
                var userId = int.Parse(user.FindFirstValue(ClaimTypes.NameIdentifier)!);
                var hasAccess = await db.UserWebsites.AsNoTracking()
                    .AnyAsync(uw => uw.UserId == userId && uw.WebsiteId == websiteId);
                if (!hasAccess)
                {
                    await Deny(httpContext, "You do not have access to the selected website.");
                    return;
                }
            }

            websiteContext.SetWebsite(websiteId);
        }

        await _next(httpContext);
    }

    private static async Task Deny(HttpContext httpContext, string message)
    {
        httpContext.Response.StatusCode = StatusCodes.Status403Forbidden;
        httpContext.Response.ContentType = "application/json";
        await httpContext.Response.WriteAsJsonAsync(new { message });
    }
}
