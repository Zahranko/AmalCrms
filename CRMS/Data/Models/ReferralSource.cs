namespace CRMS.Data.Models;

public class ReferralSource : ITenantScoped
{
    public int Id { get; set; }
    public int WebsiteId { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}
