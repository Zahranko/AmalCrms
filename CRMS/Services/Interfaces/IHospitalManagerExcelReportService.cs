using CRMS.Data.DTOs.HospitalManager;

namespace CRMS.Services.Interfaces;

public interface IHospitalManagerExcelReportService
{
    byte[] Build(HospitalManagerStatsDto stats);
}
