using ExcelSupport;
using ExcelSupport.Style;
using ExcelSupport.Table;
using System.Data;

namespace School.Common.Utility
{
	public class ExcelXlsxHelper
    {
        public static MemoryStream ToExcel(DataSet dsInput, string filename, int tableStyle = 0, bool removeAcentChars = false, bool showFilters = false)
        {
            return ProcessExcel(dsInput, filename, tableStyle, removeAcentChars, showFilters);
        }
        public static MemoryStream ToExcel(DataTable dtInput, string filename, int tableStyle = 0, bool removeAcentChars = false, bool showFilters = false)
        {
            var ds = new DataSet();
            ds.Tables.Add(dtInput.Copy());
            return ToExcel(ds, filename, tableStyle, removeAcentChars, showFilters);
        }

        private static MemoryStream ProcessExcel(DataSet ds, string fileName, int tableStyle, bool removeAcentChars, bool showFilters)
        {
            MemoryStream stream = new MemoryStream();
            ExcelPackage package = new ExcelPackage(stream);
            ExcelWorksheet ws = package.Workbook.Worksheets.Add(fileName);

            var iCount = 1;
            var tableCount = 0;
            foreach (DataTable dataTable in ds.Tables)
            {
                var totalRows = dataTable.Rows.Count;
                var totalCols = dataTable.Columns.Count;
                if (tableStyle > 0 || showFilters)
                    ws.Cells[iCount, 1].LoadFromDataTable(dataTable, true, (ExcelSupport.Table.TableStyles)tableStyle, removeAcentChars);
                else
                    ws.Cells[iCount, 1].LoadFromDataTable(dataTable, true, removeAcentChars);
                //Set header style
                if (tableStyle == 0)
                    using (var headerCells = ws.Cells[iCount, 1, iCount, totalCols])
                    {
                        var headerFont = headerCells.Style.Font;
                        headerFont.Bold = true;
                    }

                //Set all cells border
                using (var allCells = ws.Cells[iCount, 1, iCount + totalRows, totalCols])
                {
                    if (tableStyle == 0)
                    {
                        var border = allCells.Style.Border;
                        border.Top.Style = border.Left.Style = border.Bottom.Style = border.Right.Style = ExcelBorderStyle.Thin;
                    }
                    var dateColumns = GetDateColumns(dataTable);
                    //format date field 
                    dateColumns.ForEach(item => allCells[iCount, item, iCount + totalRows, item].Style.Numberformat.Format = "yyyy/MM/dd HH:mm");
                    //Format hyperlinks
                    FormatHyperLink(dataTable, allCells, iCount + 1, iCount + totalRows);
                }
                if (tableStyle > 0 || showFilters)
                {
                    ExcelTable table = ws.Tables[tableCount];
                    table.ShowFilter = showFilters;
                }
                ws.Cells.AutoFitColumns();
                iCount += dataTable.Rows.Count + 2;
                tableCount += 1;
            }

            return new MemoryStream(package.GetAsByteArray());
        }
        private static List<int> GetDateColumns(DataTable dataTable)
        {
            List<int> dateColumns = new List<int>();
            //get the first indexer
            int datecolumn = 1;
            //loop through the object and get the list of datecolumns
            foreach (DataColumn column in dataTable.Columns)
            {
                //check if property is of DateTime type or nullable DateTime type
                if (column.DataType.Name.Contains("Date"))
                {
                    dateColumns.Add(datecolumn);
                }
                datecolumn++;
            }
            return dateColumns;
        }
        private static void FormatHyperLink(DataTable dataTable, ExcelRange allCells, int rowFrom, int totalRows)
        {
            List<int> hyperLinkColumns = new List<int>();
            if (dataTable != null && dataTable.Rows.Count > 0)
            {
                DataRow dr = dataTable.Rows[0];
                for (int i = 0; i < dataTable.Columns.Count; i++)
                {
                    var value = Convert.ToString(dr[i]);
                    if (!string.IsNullOrEmpty(value) && value.ToLower().Contains("hyperlink"))
                    {
                        hyperLinkColumns.Add(i + 1);
                    }
                }
            }

            if (hyperLinkColumns.Count > 0)
            {
                foreach (var item in hyperLinkColumns)
                {
                    for (int i = rowFrom; i <= totalRows; i++)
                    {
                        var value = Convert.ToString(allCells[i, item, i, item].Value);
                        if (!string.IsNullOrEmpty(value))
                        {
                            value = value.Replace("\"\"", "\"");
                            allCells[i, item, i, item].Formula = value;
                        }
                    }
                }
            }
        }
    }
}
