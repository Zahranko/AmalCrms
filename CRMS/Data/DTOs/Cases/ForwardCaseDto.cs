using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Cases;

public class ForwardCaseDto
{
    [Required]
    public int ToUserId { get; set; }
}
