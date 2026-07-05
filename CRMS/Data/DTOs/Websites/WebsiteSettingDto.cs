using System.ComponentModel.DataAnnotations;

namespace CRMS.Data.DTOs.Websites;

public class WebsiteSettingDto
{
    [Required, MaxLength(100)]
    public string Key { get; set; } = string.Empty;

    [Required, MaxLength(2000)]
    public string Value { get; set; } = string.Empty;
}
