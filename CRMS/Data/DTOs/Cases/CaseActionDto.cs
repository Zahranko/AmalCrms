namespace CRMS.Data.DTOs.Cases;

// One entry on the case timeline.
public class CaseActionDto
{
    public int Id { get; set; }
    public string Type { get; set; } = string.Empty;
    public string? ResultingStatus { get; set; }
    public string? ActorUsername { get; set; }
    public string? TargetUsername { get; set; }
    public DateTime? ActionDate { get; set; }
    public string? DepartmentName { get; set; }
    public string? DoctorName { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
}
