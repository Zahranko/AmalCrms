using ClosedXML.Excel;
using CRMS.Data.DTOs.HospitalManager;
using CRMS.Services.Interfaces;

namespace CRMS.Services.Imps;

public class HospitalManagerExcelReportService : IHospitalManagerExcelReportService
{
    public byte[] Build(HospitalManagerStatsDto stats)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Hospital Report");

        sheet.Cell(1, 1).Value = "Al Amal Hospital — Report";
        sheet.Cell(1, 1).Style.Font.Bold = true;
        sheet.Cell(1, 1).Style.Font.FontSize = 14;

        var period = stats.From is null && stats.To is null
            ? "All time"
            : $"{FormatDate(stats.From)} – {FormatDate(stats.To)}";
        sheet.Cell(2, 1).Value = $"Report period: {period}";
        sheet.Cell(2, 1).Style.Font.Italic = true;

        sheet.Cell(4, 1).Value = "Total Cases";
        sheet.Cell(4, 2).Value = stats.TotalCases;
        sheet.Cell(5, 1).Value = "Success";
        sheet.Cell(5, 2).Value = stats.SuccessCount;
        sheet.Cell(5, 3).Value = $"{stats.SuccessPercent}%";
        sheet.Cell(6, 1).Value = "Failed";
        sheet.Cell(6, 2).Value = stats.FailedCount;
        sheet.Cell(6, 3).Value = $"{stats.FailedPercent}%";
        sheet.Range(4, 1, 6, 1).Style.Font.Bold = true;

        var deptRow = WriteTable(sheet, startRow: 8, title: "By Department", rows: stats.Departments
            .Select(d => (d.Name, d.TotalCases, d.SuccessCount, d.FailedCount, d.SuccessRate)));

        WriteTable(sheet, startRow: deptRow + 2, title: "By Doctor", rows: stats.Doctors
            .Select(d => (d.Name, d.TotalCases, d.SuccessCount, d.FailedCount, d.SuccessRate)));

        sheet.Columns(1, 5).AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }

    // Writes a titled table starting at startRow and returns the row after its last data row.
    private static int WriteTable(IXLWorksheet sheet, int startRow, string title, IEnumerable<(string Name, int Total, int Success, int Failed, double SuccessRate)> rows)
    {
        sheet.Cell(startRow, 1).Value = title;
        sheet.Cell(startRow, 1).Style.Font.Bold = true;
        sheet.Cell(startRow, 1).Style.Font.FontSize = 12;

        var headerRow = startRow + 1;
        string[] headers = ["Name", "Total Cases", "Success", "Failed", "Success Rate"];
        for (var i = 0; i < headers.Length; i++)
        {
            var cell = sheet.Cell(headerRow, i + 1);
            cell.Value = headers[i];
            cell.Style.Font.Bold = true;
            cell.Style.Fill.BackgroundColor = XLColor.FromHtml("#EEF2FF");
        }

        var row = headerRow;
        foreach (var r in rows)
        {
            row++;
            sheet.Cell(row, 1).Value = r.Name;
            sheet.Cell(row, 2).Value = r.Total;
            sheet.Cell(row, 3).Value = r.Success;
            sheet.Cell(row, 4).Value = r.Failed;
            sheet.Cell(row, 5).Value = $"{r.SuccessRate}%";
        }

        if (row == headerRow)
        {
            row++;
            sheet.Cell(row, 1).Value = "No data for this period.";
            sheet.Cell(row, 1).Style.Font.Italic = true;
        }

        return row;
    }

    private static string FormatDate(DateTime? date) => date?.ToString("yyyy-MM-dd") ?? "All time";
}
