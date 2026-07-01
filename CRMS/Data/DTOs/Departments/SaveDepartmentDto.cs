using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Departments;

public class SaveDepartmentDto
{
    [Required, MinLength(2)]
    public string Name { get; set; } = string.Empty;
}
