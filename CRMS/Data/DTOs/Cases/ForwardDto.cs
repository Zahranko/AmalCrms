using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Cases;

public class ForwardDto
{
    [Required] public int ToUserId { get; set; }
    public string? Note { get; set; }
}
