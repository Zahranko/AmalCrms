namespace CRMS.Data.DTOs.Admin;

public class AdminStatsDto
{
    public int TotalCases { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public double SuccessPercent { get; set; }
    public double FailedPercent { get; set; }
    public List<ReferralSourceStatDto> ReferralSources { get; set; } = [];
    public List<EmployeeStatDto> Employees { get; set; } = [];
}

public class ReferralSourceStatDto
{
    public string Name { get; set; } = string.Empty;
    public int Count { get; set; }
    public double Percent { get; set; }
}

public class EmployeeStatDto
{
    public int UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public int TotalCreated { get; set; }
    public int SuccessCount { get; set; }
    public int FailedCount { get; set; }
    public double Percent { get; set; }
}
