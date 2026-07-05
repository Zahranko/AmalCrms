namespace CRMS.Data.DTOs.Websites;

// The full set of system parameters for the active website — the save replaces
// the website's parameters with exactly this list.
public class SaveWebsiteSettingsDto
{
    public List<WebsiteSettingDto> Settings { get; set; } = new();
}
