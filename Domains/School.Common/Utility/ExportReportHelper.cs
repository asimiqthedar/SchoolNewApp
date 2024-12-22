using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Text;
using System.Xml;

namespace School.Common.Utility
{
	public static class ExportReportHelper
	{
		public static FileStreamResult ExportReport(DataSet ds, string filename, HttpResponse response, string reportExportType = "csv")
		{		
			System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.InvariantCulture;
			string content_type = "application/vnd.ms-excel";
			var removeAcentChars = false;
			var reportTableStyle = 0;
			var showFilter = false;

			if (!string.IsNullOrWhiteSpace(reportExportType) && reportExportType == "xls")
			{
				var excelXml = ExcelHelper.ToExcel(ds, filename, response);
				byte[] byteArray = Encoding.ASCII.GetBytes(excelXml);
				MemoryStream streamXls = new MemoryStream(byteArray);
				var rsXls = new FileStreamResult(streamXls, content_type);
				rsXls.FileDownloadName = $"{filename}.xls";
				return rsXls;
			}
			else if (!string.IsNullOrWhiteSpace(reportExportType) && reportExportType == "xlsx")
			{
				var streamXlsx = ExcelXlsxHelper.ToExcel(ds, filename, reportTableStyle, removeAcentChars, showFilter);
				var rsXlsx = new FileStreamResult(streamXlsx, content_type);
				rsXlsx.FileDownloadName = $"{filename}.xlsx";
				return rsXlsx;
			}
			//other is csv
			var stream = CSVUtility.GetCSV(ds);
			var rs = new FileStreamResult(stream, content_type);
			rs.FileDownloadName = $"{filename}.csv";
			return rs;
		}

		//public static FileStreamResult ExportReport(DataTable dt, string filename, HttpResponse response)
		//{
		//    DataSet ds = new DataSet();
		//    ds.Tables.Add(dt.Copy());
		//    return ExportReport(ds, filename, response);
		//}
		public static DataSet RemoveAndReplaceColumn(DataSet ds, string key)
		{
			// Get the mapping of dbcolumnname to reportcolumn
			Dictionary<string, string> columnMap = GetReportColumnList(key);
			DataTable table = ds.Tables[0];

			// Gather columns to remove
			var columnsToRemove = new List<DataColumn>();
			foreach (DataColumn column in table.Columns)
			{
				if (!columnMap.ContainsKey(column.ColumnName))
				{
					columnsToRemove.Add(column);
				}
			}

			// Remove extra columns
			foreach (DataColumn column in columnsToRemove)
			{
				table.Columns.Remove(column);
			}

			// Rename remaining columns
			 foreach (DataColumn column in table.Columns)
			{
				if (columnMap.ContainsKey(column.ColumnName))
				{
					string newName = columnMap[column.ColumnName];
					//if (table.Columns.Contains(newName))
					//{
					//	throw new Exception($"Column name '{newName}' already exists in the table.");
					//}
					column.ColumnName = newName;
				}
			}

			return ds;
		}
		public static Dictionary<string, string> GetReportColumnList(string key)
		{
			var columnMap = new Dictionary<string, string>();
			try
			{
				XmlDocument xDoc = new XmlDocument();
				var ConfigPath = $"{Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")}/Configurations/Report.config";
				xDoc.Load(ConfigPath);
				XmlNode oXmlNode = xDoc.SelectSingleNode($".//report[@active='yes' and @id='{key.ToLower()}']");
				if (oXmlNode != null)
				{
					XmlNodeList columnNodes = oXmlNode.SelectNodes("column");
					foreach (XmlNode columnNode in columnNodes)
					{
						if (columnNode.Attributes["dbcolumnname"] != null &&
							columnNode.Attributes["reportcolumn"] != null)
						{
							// Map dbcolumnname to reportcolumn
							columnMap[columnNode.Attributes["dbcolumnname"].Value] = columnNode.Attributes["reportcolumn"].Value;
						}
					}
				}
			}
			catch (Exception ex)
			{
				// Log the exception or handle it as needed
			}
			return columnMap;
		}		
	}
}
