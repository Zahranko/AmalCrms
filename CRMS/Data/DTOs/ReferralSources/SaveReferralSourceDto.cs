using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.ReferralSources;

public class SaveReferralSourceDto
{
    [Required, MinLength(2)]
    public string Name { get; set; } = string.Empty;
}
