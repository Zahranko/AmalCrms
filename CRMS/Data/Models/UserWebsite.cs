namespace CRMS.Data.Models;

// Many-to-many: which websites a user may enter. Admins are implicit all-access
// and don't need rows here. Composite PK (UserId, WebsiteId) — see AppDbContext.
public class UserWebsite
{
    public int UserId { get; set; }
    public User? User { get; set; }
    public int WebsiteId { get; set; }
    public Website? Website { get; set; }
}
