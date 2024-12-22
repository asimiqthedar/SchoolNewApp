using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common.Utility;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.ParentModels;
using School.Services.WebServices.Services;
using System.Data;
namespace School.Services.WebServices.Implementation
{
	public class ReportService : IReportService
	{
		ReportRepo _ReportRepo;
		private readonly ILogger<ReportService> _logger;
		ParentRepo _ParentRepo;

		public ReportService(IOptions<AppSettingConfig> appSettingConfig, ILogger<ReportService> logger)
		{
			_ParentRepo = new ParentRepo(appSettingConfig);
			_ReportRepo = new ReportRepo(appSettingConfig);
			_logger = logger;
		}
		public async Task<DataSet> GetCSVReportData(string reportKey, string reportParams)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetCSVReportData(reportKey, reportParams);
				ds = ExportReportHelper.RemoveAndReplaceColumn(ds, reportKey);

				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetCSVReportData : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetStudentReport(int academicYearId, int parentId, int studentId)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetStudentReport(academicYearId, parentId, studentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetStudentReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetMonthlyStatementByParentStudents(int parentId, string parentName, int academicYearId, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetMonthlyStatementByParentStudents(parentId,  parentName, academicYearId, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetMonthlyStatementByParentStudents : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetMonthlyStatementUniformByParentStudents(string itemCode, long invoiceNo, string parentName, string fatherMobile, string paymentMethod, string paymentRefNo, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetMonthlyStatementUniformByParentStudents(itemCode, invoiceNo, parentName, fatherMobile, paymentMethod, paymentRefNo, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetMonthlyStatementUniformByParentStudents : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetTuitionReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetTuitionReport(parentId, parentName, fatherIqama, studentName, academicYear, invoiceNo, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetTuitionReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetEntranceReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetEntranceReport(academicYear, parentId, fatherIqama, parentName, studentName, invoiceNo, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetEntranceReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetAdvanceFeeReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetAdvanceFeeReport(academicYear, parentId, fatherIqama, parentName, studentName, invoiceNo, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetAdvanceFeeReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetDiscountReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetDiscountReport(parentId, parentName, fatherIqama, studentName, academicYear, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetDiscountReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetAllRevenueReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetAllRevenueReport(parentId, parentName, fatherIqama, studentName, academicYear, invoiceNo, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetAllRevenueReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetStudentStatementParentWise(int parentId, string parentName, string fatherIqama, string fatherMobile, int academicYear)
		{
			try
			{
				DataSet dsStatement = new DataSet();

				DataSet dsStudent = await _ReportRepo.GetStudentParentWise(parentId, parentName, fatherIqama, fatherMobile);
				if (dsStudent != null && dsStudent.Tables.Count > 0 && dsStudent.Tables[0].Rows.Count > 0)
				{
					foreach (DataRow dr in dsStudent.Tables[0].Rows)
					{
						int studentId = Convert.ToInt32(dr["StudentId"]);
						int currentParentId = Convert.ToInt32(dr["ParentId"]);

						// Fetch the statement for each student
						DataSet dsTemp = await _ReportRepo.GetStudentStatementParentWise(currentParentId, academicYear, studentId);

						// Ensure the DataSet is not null and contains at least one table
						if (dsTemp != null && dsTemp.Tables.Count > 0)
						{
							// Create a new DataTable to avoid issues with DataTable ownership
							DataTable newTable = dsTemp.Tables[0].Copy();
							newTable.TableName = $"Statement_{studentId}"; // Optional: Set a unique name for the table

							// Add the copied DataTable to the main DataSet
							dsStatement.Tables.Add(newTable);
						}
					}
				}
				return dsStatement;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetStudentStatementParentWise : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetParent(int parentId)
		{
			try
			{

				DataSet ds = await _ParentRepo.GetParents(parentId, new ParentFilterModel());
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ParentService:GetParents : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetGeneralReport(int academicYear, int costcenter, int grade, int gender)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetGeneralReport(academicYear, costcenter, grade, gender);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetGeneralReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetParentStudentReport(int parentId, int studentId, int academicYear, int costcenter, int grade, int gender, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetParentStudentReport(parentId, studentId, academicYear, costcenter, grade, gender, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetParentStudentReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<DataSet> GetParentReport(int parentId, int academicYear, string startDate, string endDate)
		{
			try
			{
				DataSet ds = await _ReportRepo.GetParentReport(parentId, academicYear, startDate, endDate);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:ReportService:GetParentReport : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
	}
}
