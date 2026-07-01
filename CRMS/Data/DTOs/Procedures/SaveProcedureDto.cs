using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Procedures;

public class SaveProcedureDto
{
    [Required, MinLength(2)]
    public string Name { get; set; } = string.Empty;
}
