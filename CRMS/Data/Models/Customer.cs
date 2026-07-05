namespace CRMS.Data.Models;

// A "case" in the CRM. Created by an employee; moved around via Forward and
// updated via Follow-up.
public class Customer : ITenantScoped
{
    public int Id { get; set; }
    public int WebsiteId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PhoneCountryCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public int ReferralSourceId { get; set; }
    public ReferralSource? ReferralSource { get; set; }
    public int? ProcedureId { get; set; }
    public Procedure? Procedure { get; set; }
    public string Description { get; set; } = string.Empty;
    public CustomerStatus Status { get; set; } = CustomerStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Who created the case, and who currently owns it (creator until forwarded).
    public int? CreatedByUserId { get; set; }
    public User? CreatedBy { get; set; }
    public int? AssignedToUserId { get; set; }
    public User? AssignedTo { get; set; }
    public int? ForwardedByUserId { get; set; }
    public User? ForwardedBy { get; set; }
    // Set when a forward is pending acceptance — cleared on accept or decline.
    public int? PendingForwardToUserId { get; set; }
    public User? PendingForwardTo { get; set; }

    // Appointment snapshot — assigned at a "Waiting" follow-up.
    public int? DepartmentId { get; set; }
    public Department? Department { get; set; }
    public bool HasDoctor { get; set; } = false;
    public int? DoctorId { get; set; }
    public Doctor? Doctor { get; set; }
    public DateTime? AppointmentDate { get; set; }

    // Clinic (عيادات) signature — base64 data-URL stored when a Success follow-up
    // includes the clinics checkbox. Overwritten on each new clinics follow-up.
    public string? ClinicSignature { get; set; }
}
