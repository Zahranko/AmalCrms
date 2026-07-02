namespace CRMS.Data.DTOs.HospitalManager;

public class HospitalManagerStatsDto
{
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
    public int TotalCases { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public double SuccessPercent { get; set; }
    public double FailedPercent { get; set; }
    public List<GroupStatDto> Departments { get; set; } = [];
    public List<GroupStatDto> Doctors { get; set; } = [];
}

/// One department's or one doctor's ticket counts + success rate.
public class GroupStatDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int TotalCases { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public double SuccessRate { get; set; }
}
