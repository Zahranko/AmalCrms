namespace CRMS.Data.Models;

// A "website" is the top-level tenant. Everything ITenantScoped (cases, the
// lookup lists, notifications) belongs to exactly one Website. Seeded on
// startup (crms + contact); not user-created in this version.
public class Website
{
    public int Id { get; set; }
    // Stable slug used by the frontend to decide which nav/pages to show
    // (e.g. "crms" = the full CRM, "contact" = the placeholder site).
    public string Key { get; set; } = string.Empty;
    public string NameEn { get; set; } = string.Empty;
    public string NameAr { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
