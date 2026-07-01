namespace CRMS.Data.DTOs.ReferralSources;

public class ReferralSourceDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
