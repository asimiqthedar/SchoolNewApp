using Microsoft.AspNetCore.Http;
using System.Data;
using System.Text;

namespace School.Common.Utility
{
	public class ExcelHelper
    {
        //Row limits older excel verion per sheet, the row limit for excel 2003 is 65536
        const int rowLimit = 65000;

        private static string getWorkbookTemplate()
        {
            var sb = new StringBuilder(818);
            sb.AppendFormat(@"<?xml version=""1.0""?>{0}", Environment.NewLine);
            sb.AppendFormat(@"<?mso-application progid=""Excel.Sheet""?>{0}", Environment.NewLine);
            sb.AppendFormat(@"<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""{0}", Environment.NewLine);
            sb.AppendFormat(@" xmlns:o=""urn:schemas-microsoft-com:office:office""{0}", Environment.NewLine);
            sb.AppendFormat(@" xmlns:x=""urn:schemas-microsoft-com:office:excel""{0}", Environment.NewLine);
            sb.AppendFormat(@" xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""{0}", Environment.NewLine);
            sb.AppendFormat(@" xmlns:html=""http://www.w3.org/TR/REC-html40"">{0}", Environment.NewLine);
            sb.AppendFormat(@" <Styles>{0}", Environment.NewLine);
            sb.AppendFormat(@"  <Style ss:ID=""Default"" ss:Name=""Normal"">{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Alignment ss:Vertical=""Bottom""/>{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Borders/>{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""#000000""/>{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Interior/>{0}", Environment.NewLine);
            sb.AppendFormat(@"   <NumberFormat/>{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Protection/>{0}", Environment.NewLine);
            sb.AppendFormat(@"  </Style>{0}", Environment.NewLine);
            sb.AppendFormat(@"  <Style ss:ID=""s62"">{0}", Environment.NewLine);
            sb.AppendFormat(@"   <Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""#000000""{0}", Environment.NewLine);
            sb.AppendFormat(@"    ss:Bold=""1""/>{0}", Environment.NewLine);
            sb.AppendFormat(@"  </Style>{0}", Environment.NewLine);
            sb.AppendFormat(@"  <Style ss:ID=""s63"">{0}", Environment.NewLine);
            sb.AppendFormat(@"   <NumberFormat ss:Format=""Short Date""/>{0}", Environment.NewLine);
            sb.AppendFormat(@"  </Style>{0}", Environment.NewLine);
            sb.AppendFormat(@"  <Style ss:ID=""s64"">{0}", Environment.NewLine);
            sb.AppendFormat(@"   <NumberFormat ss:Format=""General Date""/>{0}", Environment.NewLine);
            sb.AppendFormat(@"  </Style>{0}", Environment.NewLine);
            sb.AppendFormat(@" </Styles>{0}", Environment.NewLine);
            sb.Append(@"{0}\r\n</Workbook>");
            return sb.ToString();
        }

        private static string replaceXmlChar(string input)
        {
            try
            {
                string normalized = input.Normalize(NormalizationForm.FormKD);
                Encoding removal = Encoding.GetEncoding(Encoding.ASCII.CodePage,
                                                        new EncoderReplacementFallback(""),
                                                        new DecoderReplacementFallback(""));
                byte[] bytes = removal.GetBytes(normalized);
                input = Encoding.ASCII.GetString(bytes);
            }
            catch (Exception)
            {
            }
            input = input.Replace("\"\"", "\"");
            input = input.Replace("&", "&amp");
            input = input.Replace("<", "&lt;");
            input = input.Replace(">", "&gt;");
            input = input.Replace("\"", "&quot;");
            input = input.Replace("'", "&apos;");
            return input;
        }

        private static string getCell(Type type, object cellData)
        {
            var data = (cellData is DBNull) ? "" : cellData;
            if (type.Name.Contains("Int") || type.Name.Contains("Double") || type.Name.Contains("Decimal")) return string.Format("<Cell><Data ss:Type=\"Number\">{0}</Data></Cell>", data);
            if (type.Name.Contains("DateTime") && data.ToString() != string.Empty)
            {
                //return string.Format("<Cell ss:StyleID=\"s64\"><Data ss:Type=\"Number\">{0}</Data></Cell>", Convert.ToDateTime(data).ToOADate());
                return string.Format("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>", Convert.ToDateTime(data).ToString("yyyy'/'MM'/'dd HH:mm"));
            }
            else if (type.Name.Contains("Date") && data.ToString() != string.Empty)
            {
                //return string.Format("<Cell ss:StyleID=\"s63\"><Data ss:Type=\"DateTime\">{0}</Data></Cell>", Convert.ToDateTime(data).ToString("yyyy-MM-dd"));
                return string.Format("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>", Convert.ToDateTime(data).ToString("yyyy'/'MM'/'dd"));
            }
            if (Convert.ToString(data).ToLower().Contains("hyperlink"))
                return string.Format("<Cell ss:Formula=\"{0}\"><Data ss:Type=\"String\">{0}</Data></Cell>", replaceXmlChar(Convert.ToString(data)));
            return string.Format("<Cell><Data ss:Type=\"String\">{0}</Data></Cell>", replaceXmlChar(Convert.ToString(data)));
        }
        private static string getWorksheets(DataSet source, string reportName)
        {
            var sw = new StringWriter();
            if (source == null || source.Tables.Count == 0)
            {
                sw.Write("<Worksheet ss:Name=\"Sheet1\">\r\n<Table>\r\n<Row><Cell><Data ss:Type=\"String\"></Data></Cell></Row>\r\n</Table>\r\n</Worksheet>");
                return sw.ToString();
            }
            int iCount = 0;
            foreach (DataTable dt in source.Tables)
            {
                if (dt.Rows.Count == 0)
                    sw.Write("<Worksheet ss:Name=\"" + replaceXmlChar(reportName) + "\">\r\n<Table>\r\n<Row><Cell  ss:StyleID=\"s62\"><Data ss:Type=\"String\"></Data></Cell></Row>\r\n</Table>\r\n</Worksheet>");
                else
                {
                    //write each row data                
                    var sheetCount = 0;
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        iCount += 1;
                        if ((i % rowLimit) == 0)
                        {
                            //add close tags for previous sheet of the same data table
                            if ((i / rowLimit) > sheetCount)
                            {
                                sw.Write("\r\n</Table>\r\n</Worksheet>");
                                sheetCount = (i / rowLimit);
                            }
                            sw.Write("\r\n<Worksheet ss:Name=\"" + replaceXmlChar(reportName) + (source.Tables.Count == 1 ? $"-{iCount} " : "") +
                                     (((i / rowLimit) == 0) ? "" : Convert.ToString(i / rowLimit)) + "\">\r\n<Table>");
                            //write column name row
                            sw.Write("\r\n<Row>");
                            foreach (DataColumn dc in dt.Columns)
                                sw.Write(string.Format("<Cell ss:StyleID=\"s62\"><Data ss:Type=\"String\">{0}</Data></Cell>", replaceXmlChar(dc.ColumnName)));
                            sw.Write("</Row>");
                        }
                        sw.Write("\r\n<Row>");
                        foreach (DataColumn dc in dt.Columns)
                            sw.Write(getCell(dc.DataType, dt.Rows[i][dc.ColumnName]));
                        sw.Write("</Row>");
                    }
                    sw.Write("\r\n</Table>\r\n</Worksheet>");
                }
            }

            return sw.ToString();
        }
        private static string getSingleWorksheets(DataSet source, string reportName)
        {
            var sw = new StringWriter();
            if (source == null || source.Tables.Count == 0)
            {
                sw.Write("<Worksheet ss:Name=\"Sheet1\">\r\n<Table>\r\n<Row><Cell><Data ss:Type=\"String\"></Data></Cell></Row>\r\n</Table>\r\n</Worksheet>");
                return sw.ToString();
            }
            sw.Write("\r\n<Worksheet ss:Name=\"" + replaceXmlChar(reportName) + "\">\r\n<Table>");
            foreach (DataTable dt in source.Tables)
            {
                //write each row data     
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if ((i % rowLimit) == 0)
                    {
                        //write column name row
                        sw.Write("\r\n<Row>");
                        foreach (DataColumn dc in dt.Columns)
                        {
                            sw.Write(string.Format("<Cell ss:StyleID=\"s62\"><Data ss:Type=\"String\">{0}</Data></Cell>", replaceXmlChar(dc.ColumnName)));
                        }
                        sw.Write("</Row>");
                    }
                    sw.Write("\r\n<Row>");
                    foreach (DataColumn dc in dt.Columns)
                    {
                        sw.Write(getCell(dc.DataType, dt.Rows[i][dc.ColumnName]));
                    }
                    sw.Write("</Row>");
                }
            }
            sw.Write("\r\n</Table>\r\n</Worksheet>");
            return sw.ToString();
        }
        public static string GetExcelXml(DataTable dtInput, string filename)
        {
            var excelTemplate = getWorkbookTemplate();
            var ds = new DataSet();
            ds.Tables.Add(dtInput.Copy());
            var worksheets = getWorksheets(ds, filename);
            var excelXml = string.Format(excelTemplate, worksheets);
            return excelXml;
        }

        public static string GetExcelXml(DataSet dsInput, string filename, bool isInSingleSheet = true)
        {
            var excelTemplate = getWorkbookTemplate();
            var worksheets = isInSingleSheet ? getSingleWorksheets(dsInput, filename) : getWorksheets(dsInput, filename);
            var excelXml = string.Format(excelTemplate, worksheets);
            return excelXml;
        }

        public static string ToExcel(DataSet dsInput, string filename, HttpResponse response, bool isInSingleSheet = true)
        {
            return GetExcelXml(dsInput, filename);
        }

        public static string ToExcel(DataTable dtInput, string filename, HttpResponse response)
        {
            var ds = new DataSet();
            ds.Tables.Add(dtInput.Copy());
            return ToExcel(ds, filename, response);
        }
    }

}