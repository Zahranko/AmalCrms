using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Users;

public class ResetPasswordDto
{
    [Required, MinLength(6)]
    public string NewPassword { get; set; } = string.Empty;
}
