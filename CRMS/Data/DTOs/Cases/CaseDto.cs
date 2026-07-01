namespace CRMS.Data.DTOs.Cases;

// Row shape for the case list pages.
public class CaseDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PhoneCountryCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string? Department { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? CreatedByUsername { get; set; }
    public string? AssignedToUsername { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? ReferralSource { get; set; }
    public string? Procedure { get; set; }
    public string? ForwardedToUsername { get; set; }
    public string? ForwardedByUsername { get; set; }
    public bool HasPendingForward { get; set; }
}
