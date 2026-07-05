using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class WebsiteContext : IWebsiteContext
{
    public int? WebsiteId { get; private set; }

    public void SetWebsite(int websiteId) => WebsiteId = websiteId;
}
