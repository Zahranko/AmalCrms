namespace CRMS.Data.DTOs.Cases;

public class CaseDetailDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PhoneCountryCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string ReferralSource { get; set; } = string.Empty;
    public string? Procedure { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? Department { get; set; }
    public bool HasDoctor { get; set; }
    public string? Doctor { get; set; }
    public DateTime? AppointmentDate { get; set; }
    public string? CreatedByUsername { get; set; }
    public string? AssignedToUsername { get; set; }
    public string? ForwardedToUsername { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? ClinicSignature { get; set; }
    public List<CaseActionDto> History { get; set; } = new();
}
