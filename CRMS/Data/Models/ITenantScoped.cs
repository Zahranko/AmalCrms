namespace CRMS.Data.Models;

// Marker for entities that belong to a single website (tenant). AppDbContext
// applies a global query filter on WebsiteId to every ITenantScoped entity and
// stamps WebsiteId on inserts, so per-website isolation is automatic — services
// and repositories never have to filter/set it by hand.
public interface ITenantScoped
{
    int WebsiteId { get; set; }
}
