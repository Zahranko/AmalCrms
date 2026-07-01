using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Cases;

public class CreateCaseDto
{
    [Required, MinLength(2)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public string PhoneCountryCode { get; set; } = string.Empty;

    [Required]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required]
    public int ReferralSourceId { get; set; }

    [Required]
    public int ProcedureId { get; set; }

    [Required]
    public int DepartmentId { get; set; }

    public bool HasDoctor { get; set; } = false;
    public int? DoctorId { get; set; }

    [Required, MinLength(2)]
    public string Description { get; set; } = string.Empty;
}
