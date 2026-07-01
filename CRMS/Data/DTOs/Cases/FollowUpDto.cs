using System.ComponentModel.DataAnnotations;
using CRMS.Data.Models;

namespace CRMS.Data.DTOs.Cases;

// A follow-up sets the patient status to one of the 4 outcomes.
// Waiting optionally carries an appointment date + department + doctor.
// Success optionally carries a clinics (عيادات) doctor assignment.
// Pending/Failed require notes only — no date.
public class FollowUpDto
{
    [Required]
    public CustomerStatus Status { get; set; }

    public DateTime? Date { get; set; }

    [MaxLength(2000)]
    public string? Notes { get; set; }

    public int? DepartmentId { get; set; }
    public bool? HasDoctor { get; set; }
    public int? DoctorId { get; set; }

    // Base64 data-URL of the clinic (عيادات) signature image.
    // Required when Status == Success && HasDoctor == true.
    public string? SignatureData { get; set; }
}
