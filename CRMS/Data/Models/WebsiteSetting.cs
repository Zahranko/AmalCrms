namespace CRMS.Data.Models;

// Per-website "system parameter" — a generic key/value the admin can edit for a
// website. ITenantScoped so it's isolated per website like everything else;
// (WebsiteId, Key) is unique (see AppDbContext).
public class WebsiteSetting : ITenantScoped
{
    public int Id { get; set; }
    // WebsiteId FK + query filter are configured generically via ConfigureTenant
    // in AppDbContext (no Website navigation here — it would double-map the FK).
    public int WebsiteId { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
}
