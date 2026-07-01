namespace CRMS.Data.Models;

// Append-only timeline of everything that happened to a case: created, forwarded,
// and each follow-up status update. Rendered one-by-one on the case view page.
public class CaseAction
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public Customer? Customer { get; set; }
    public int ActorUserId { get; set; }
    public User? Actor { get; set; }
    public int? TargetUserId { get; set; }
    public User? Target { get; set; }
    public CaseActionType Type { get; set; }

    // Follow-up payload.
    public CustomerStatus? ResultingStatus { get; set; }
    public DateTime? ActionDate { get; set; }
    public int? DepartmentId { get; set; }
    public Department? Department { get; set; }
    public int? DoctorId { get; set; }
    public Doctor? Doctor { get; set; }
    public string? Note { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
