using CourseWork_PSwDBS_Pankov.DB;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Markup;

namespace CourseWork_PSwDBS_Pankov
{
    class ExcelManager
    {
        DbContext_Npgsql dbContext;
        ExcelPackage package;

        public ExcelManager()
        {
            dbContext = DbContext_Npgsql.GetInstance();
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            package = new ExcelPackage();
        }

        private ExcelWorksheet CreateNewPage(string NamePage)
        {
            return package.Workbook.Worksheets.Add(NamePage);
        }

        public void AddDataByTableName(string TableName)
        {
            var dt = dbContext.GetDataTableByTable(TableName);
            AddData(dt, TableName);
        }

        private void AddData(DataTable dataTable, string NamePage)
        {
            var worksheet = CreateNewPage(NamePage);

            // Заполнение данных из DataTable в Excel-файл
            worksheet.Cells["A1"].LoadFromDataTable(dataTable, true);
        }

        public void AddDataAndChartByTableName(string TableName)
        {
            var dt = dbContext.GetDataTableByTable(TableName);

            var worksheet = CreateNewPage(TableName);

            // Заполнение данных из DataTable в Excel-файл
            worksheet.Cells["A1"].LoadFromDataTable(dt, true);

            DriveChart(worksheet, dt, $"Chart:{TableName}");
        }

        private void DriveChart(ExcelWorksheet worksheet, DataTable dataTable, string NameChart)
        {
            // Добавление диаграммы на лист
            var chart = worksheet.Drawings.AddChart(NameChart, OfficeOpenXml.Drawing.Chart.eChartType.ColumnClustered);
            chart.SetPosition(1, 0, 4, 0);
            chart.SetSize(600, 400);
            chart.Series.Add(worksheet.Cells[$"B2:B{dataTable.Rows.Count + 1}"], worksheet.Cells[$"A2:A{dataTable.Rows.Count + 1}"]);
        }

        public void DocumentSaveAs(string Path)
        {
            // Сохранение Excel-файла
            FileInfo excelFile = new FileInfo(Path);
            package.SaveAs(excelFile);
        }
    }
}
