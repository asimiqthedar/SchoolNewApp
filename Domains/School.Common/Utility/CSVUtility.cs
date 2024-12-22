using School.Common.Helpers;
using System.Data;
using System.Text;

namespace School.Common.Utility
{
	public class CSVUtility
    {
        public static Stream GetCSV(DataSet data)
        {
            Stream fileStream = null;
            string tempFile = $"{Path.GetTempPath()}\\{Path.GetRandomFileName()}.csv";
            using (var outputFile = File.CreateText(tempFile))
            {
                foreach (DataTable DDT in data.Tables)
                {

                    string CsvText = string.Empty;

                    foreach (DataColumn DC in DDT.Columns)
                    {
                        if (CsvText != "")
                            CsvText = CsvText + "," + RemoveEscape(DC.ColumnName, typeof(string), null);
                        else
                            CsvText = RemoveEscape(DC.ColumnName, typeof(string), null);
                    }
                    outputFile.WriteLine(CsvText.TrimEnd(','));
                    CsvText = string.Empty;

                    foreach (DataRow DDR in DDT.Rows)
                    {
                        foreach (DataColumn DCC in DDT.Columns)
                        {
                            if (CsvText != "")
                                CsvText = CsvText + "," + RemoveEscape(DDR[DCC.ColumnName].ToString(), DCC.DataType, DDR[DCC.ColumnName]);
                            else
                                CsvText = RemoveEscape(DDR[DCC.ColumnName].ToString(), DCC.DataType, DDR[DCC.ColumnName]);
                        }
                        outputFile.WriteLine(CsvText.TrimEnd(','));
                        CsvText = string.Empty;
                    }
                    outputFile.WriteLine(CsvText.ToString().TrimEnd(','));
                    //System.Threading.Thread.Sleep(500);
                }
            }
            //System.Threading.Thread.Sleep(500);
            System.IO.FileInfo fileInfo = new System.IO.FileInfo(tempFile);
            fileStream = new System.IO.FileStream(fileInfo.FullName, System.IO.FileMode.Open, FileAccess.Read, FileShare.Read, 1048575);
            return fileStream;
        }

        public static Stream GetCSV(DataTable data, ListViewConfig config)
        {
            Stream fileStream = null;
            string tempFile = $"{Path.GetTempPath()}\\{Path.GetRandomFileName()}.csv";
            using (var outputFile = File.CreateText(tempFile))
            {
                DataTable DDT = data;
                string CsvText = string.Empty;
                int ord = 0;
                foreach (ReportColumn rcol in config.Columns)
                {
                    DataColumn col = DDT.Columns[rcol.Name];
                    if (col != null)
                        col.SetOrdinal(ord++);
                }
                foreach (DataColumn DC in DDT.Columns)
                {
                    var col_inf = config.Columns.Where(m => m.Name == DC.ColumnName).FirstOrDefault();
                    if (col_inf != null)
                    {
                        if (!col_inf.Hidden)
                        {
                            if (CsvText != "")
                                CsvText = CsvText + "," + RemoveEscape(col_inf.Caption, typeof(string), null);
                            else
                                CsvText = RemoveEscape(col_inf.Caption, typeof(string), null);
                        }
                    }
                }
                outputFile.WriteLine(CsvText.ToString().TrimEnd(','));
                CsvText = string.Empty;

                foreach (DataRow DDR in DDT.Rows)
                {
                    foreach (DataColumn DCC in DDT.Columns)
                    {
                        var col_inf = config.Columns.Where(m => m.Name == DCC.ColumnName).FirstOrDefault();
                        if (col_inf != null && !col_inf.Hidden)
                        {
                            if (CsvText != "")
                                CsvText = CsvText + "," + RemoveEscape(DDR[DCC.ColumnName].ToString(), DCC.DataType, DDR[DCC.ColumnName]);
                            else
                                CsvText = RemoveEscape(DDR[DCC.ColumnName].ToString(), DCC.DataType, DDR[DCC.ColumnName]);
                        }
                    }
                    outputFile.WriteLine(CsvText.TrimEnd(','));
                    CsvText = string.Empty;
                }
                outputFile.WriteLine(CsvText.ToString().TrimEnd(','));
                //System.Threading.Thread.Sleep(500);

            }
            //System.Threading.Thread.Sleep(500);
            System.IO.FileInfo fileInfo = new System.IO.FileInfo(tempFile);
            fileStream = new System.IO.FileStream(fileInfo.FullName, System.IO.FileMode.Open, FileAccess.Read, FileShare.Read, 1048575);
            return fileStream;
        }
        private static string RemoveEscape(string text, System.Type type, object orignalData)
        {
            try
            {
                if (type.Name.Contains("Date") && !string.IsNullOrWhiteSpace(Convert.ToString(orignalData)))
                {
                    return $"\"{Convert.ToDateTime(orignalData).ToString("yyyy'/'MM'/'dd HH:mm")}\"";
                }
            }
            catch (Exception)
            {
            }
            try
            {
                //byte[] tempBytes;
                //tempBytes = System.Text.Encoding.GetEncoding(1251).GetBytes(text);
                //text = System.Text.Encoding.UTF8.GetString(tempBytes);
                string normalized = text.Normalize(NormalizationForm.FormKD);
                Encoding removal = Encoding.GetEncoding(Encoding.ASCII.CodePage,
                                                        new EncoderReplacementFallback(""),
                                                        new DecoderReplacementFallback(""));
                byte[] bytes = removal.GetBytes(normalized);
                text = Encoding.ASCII.GetString(bytes);
            }
            catch (Exception)
            {
            }
            if (!string.IsNullOrWhiteSpace(text) && !text.ToLower().Contains("hyperlink"))
                text = text.Replace("\"", "");
            if (!string.IsNullOrEmpty(text) && (text.Contains(",") || text.Contains("\n") || text.Contains("\r") || text.Contains("<")))
                return $"\"{text}\"";

            return text;
        }
    }
}