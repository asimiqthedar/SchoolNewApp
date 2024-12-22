using Microsoft.Extensions.Options;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;
namespace School.Database.WebRepos
{
	public class ReportRepo
	{
		DbHelper _DbHelper;
		public ReportRepo(IOptions<AppSettingConfig> appSettingConfig)
		{
			_DbHelper = new DbHelper(appSettingConfig);
		}
		public async Task<DataSet> GetCSVReportData(string reportKey, string reportParams)
		{
			List<SqlParameter> ls_p = GetParameterList(reportKey, reportParams);

			string csvSP = $"sp_CSV{reportKey}";
			return await _DbHelper.ExecuteDataProcedureAsync(csvSP, ls_p);
		}
		public List<SqlParameter> GetParameterList(string reportKey, string reportParams)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			if (reportKey == "StudentStatement" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "AcademicYearId")
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentId")
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId")
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "InvoiceExport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "InvoiceId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "Status" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@Status", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceNo" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "InvoiceType" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceType", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentCode" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentCode", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "FatherMobile" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceDateStart" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceDateStart", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceDateEnd" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceDateEnd", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "FatherIqama" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "uniformrevenueexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ItemCode" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ItemCode", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceNo" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "FatherMobile" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentMethod" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentMethod", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentReferenceNumber" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentReferenceNumber", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "entrancerevenueexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "FatherIqama" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYear" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceNo" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "monthlytuitionrevenueexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYearId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentType" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentType", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "TotalRevenueExport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYearId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentType" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentType", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "ParentStudentRevenueExport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYearId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentType" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentType", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "advancefeetuitionrevenueexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "FatherIqama" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYear" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "InvoiceNo" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "discountreportexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYearId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "PaymentType" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@PaymentType", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "generalreportexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "AcademicYear" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "CostCenter" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@CostCenter", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "Grade" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@Grade", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "Gender" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@Gender", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "parentstudentreportexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StudentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYear" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "CostCenter" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@CostCenter", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "Grade" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@Grade", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "Gender" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@Gender", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
					}
				}
			}
			else if (reportKey == "parentreportexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYear" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = itemList[1].Trim() });
						}

						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
					}
				}
			}

			else if (reportKey == "monthlyrevenueexport" && !string.IsNullOrEmpty(reportParams))
			{
				var paremeterList = reportParams.Split('|').ToList();
				foreach (var item in paremeterList)
				{
					var itemList = item.Split(':').ToList();
					if (itemList.Count == 2)
					{
						if (itemList[0].Trim() == "ParentId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "ParentName" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "AcademicYearId" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "StartDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}
						if (itemList[0].Trim() == "EndDate" && !string.IsNullOrEmpty(itemList[1].Trim()))
						{
							ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = itemList[1].Trim() });
						}				
					}
				}
			}

			return ls_p;
		}
		public async Task<DataSet> GetStudentReport(int academicYearId, int parentId, int studentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYearId });
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_ReportStudentStatement", ls_p);
		}
		public async Task<DataSet> GetMonthlyStatementByParentStudents(int parentId, string parentName, int academicYearId, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();			
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYearId });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_MonthlyStatementParentStudent", ls_p);
		}
		public async Task<DataSet> GetMonthlyStatementUniformByParentStudents(string itemCode, long invoiceNo, string parentName, string fatherMobile, string paymentMethod, string paymentRefNo, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ItemCode", SqlDbType.NVarChar) { Value = itemCode });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = fatherMobile });
			ls_p.Add(new SqlParameter("@PaymentMethod", SqlDbType.NVarChar) { Value = paymentMethod });
			ls_p.Add(new SqlParameter("@PaymentReferenceNumber", SqlDbType.NVarChar) { Value = paymentRefNo });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_UniformSalesReport", ls_p);
		}
		public async Task<DataSet> GetTuitionReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = studentName });
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.NVarChar) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_TuitionFeeReport", ls_p);
		}
		public async Task<DataSet> GetEntranceReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@parentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = studentName });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_EntranceFeesReport", ls_p);
		}
		public async Task<DataSet> GetAdvanceFeeReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@parentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@parentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = studentName });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(startDate) });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(endDate) });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_AdvanceFeeReport", ls_p);
		}
		public async Task<DataSet> GetDiscountReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = studentName });
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_DiscountReport", ls_p);
		}
		public async Task<DataSet> GetAllRevenueReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = studentName });
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.NVarChar) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_AllRevenueReport", ls_p);
		}
		public async Task<DataSet> GetStudentParentWise(int parentId, string parentName, string fatherIqama, string fatherMobile)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.BigInt) { Value = parentId });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = parentName });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = fatherIqama });
			ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = fatherMobile });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_GetStudentParentWise", ls_p);
		}
		public async Task<DataSet> GetStudentStatementParentWise(int parentId, int academicYear, int studentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_ReportStudentStatement", ls_p);
		}
		public async Task<DataSet> GetGeneralReport(int academicYear, int costcenter, int grade, int gender)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@CostCenter", SqlDbType.NVarChar) { Value = costcenter });
			ls_p.Add(new SqlParameter("@Grade", SqlDbType.NVarChar) { Value = grade });
			ls_p.Add(new SqlParameter("@Gender", SqlDbType.NVarChar) { Value = gender });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_GeneralReport", ls_p);
		}

		public async Task<DataSet> GetParentStudentReport(int parentId, int studentId, int academicYear, int costcenter, int grade, int gender, string startDate, string endDate)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@CostCenter", SqlDbType.NVarChar) { Value = costcenter });
			ls_p.Add(new SqlParameter("@Grade", SqlDbType.NVarChar) { Value = grade });
			ls_p.Add(new SqlParameter("@Gender", SqlDbType.NVarChar) { Value = gender });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_ParentStudentReport", ls_p);
		}

		public async Task<DataSet> GetParentReport(int parentId, int academicYear, string startDate, string endDate	)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.Int) { Value = academicYear });
			ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = startDate });
			ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = endDate });

			return await _DbHelper.ExecuteDataProcedureAsync("SP_ParentReport", ls_p);
		}
	}
}

