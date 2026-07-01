using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Doctors;

public class SaveDoctorDto
{
    [Required, MinLength(2)]
    public string Name { get; set; } = string.Empty;
}
