using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using NuGet.Packaging;
using OfficeOpenXml;
using School.Common;
using School.Common.Helpers;
using School.Common.Utility;
using School.Models.WebModels;
using School.Models.WebModels.StudentModels;
using School.Services.ALSManager;
using School.Services.WebServices.Services;
using System.Data;
using System.Text;
namespace School.Web.Controllers
{
	[Authorize]
	public class ReportController : BaseController
	{
        
        private readonly ILogger<ReportController> _logger;
		private IReportService _IReportService;
		private IStudentService _IStudentService;
		IOptions<AppSettingConfig> _AppSettingConfig;
		IHttpContextAccessor _IHttpContextAccessor;
		private readonly IWebHostEnvironment _IWebHostEnvironment;
		private readonly ISchoolAcademicManager _iSchoolAcademicManager;
		public ReportController(ILogger<ReportController> logger, IOptions<AppSettingConfig> appSettingConfig,
			IReportService iReportService, IHttpContextAccessor iHttpContextAccessor,
			IDropdownService iDropdownService,
			IStudentService iStudentService,
			  IWebHostEnvironment iWebHostEnvironment,
			  ISchoolAcademicManager iSchoolAcademicManager) : base(iHttpContextAccessor, iDropdownService)
		{
			_logger = logger;
			_AppSettingConfig = appSettingConfig;
			_IReportService = iReportService;
			_IHttpContextAccessor = iHttpContextAccessor;
			_IStudentService = iStudentService;
			_IWebHostEnvironment = iWebHostEnvironment;
			_iSchoolAcademicManager = iSchoolAcademicManager;
		}

		public async void InitDropdown()
		{
			ViewBag.CountryDropdown = await GetAppDropdown(AppDropdown.Country, true);
			ViewBag.ParentDropdown = await GetAppDropdown(AppDropdown.Parent, true);
			ViewBag.GenderDropdown = await GetAppDropdown(AppDropdown.Gender, true);
			ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.SectionDropdown = await GetAppDropdown(AppDropdown.Section, true);
			ViewBag.TermDropdown = await GetAppDropdown(AppDropdown.Term, true);
			ViewBag.TermYear = await GetAppTermYearDropdown(true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
		}

		[HttpPost]
		public async Task<IActionResult> DownloadReport(ReportModel model)
		{
			DataSet ds = await _IReportService.GetCSVReportData(model.ReportKey, model.Parameters);
			return ExportReportHelper.ExportReport(ds, model.ReportName, Response);
		}

		#region TotalRevenue
		public IActionResult TotalRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> StudentReportDataPartial(int academicYearId, int parentId, int studentId)
		{
			var ds = await _IReportService.GetStudentReport(academicYearId, parentId, studentId);
			return PartialView("_StudentReportDataPartial", ds);
		}
		#endregion

		#region MonthlyRevenue
		public async Task<IActionResult> MonthlyRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			ViewBag.ParentDropdown = await GetAppDropdown(AppDropdown.Parent, true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			return View();
		}
		public async Task<IActionResult> GetMonthlyStatementByParentStudents(int parentId, string parentName, int academicYearId, string startDate, string endDate)
		{
			var ds = await _IReportService.GetMonthlyStatementByParentStudents(parentId, parentName, academicYearId, startDate, endDate);
			return PartialView("_MonthlyStatementByParentStudentDataPartial", ds);
		}
		#endregion

		#region UniformRevenue
		public IActionResult UniformRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> GetMonthlyStatementUniformByParentStudents(string itemCode, long invoiceNo, string parentName, string fatherMobile, string paymentMethod, string paymentRefNo, string startDate, string endDate)
		{
			var ds = await _IReportService.GetMonthlyStatementUniformByParentStudents(itemCode, invoiceNo, parentName, fatherMobile, paymentMethod, paymentRefNo, startDate, endDate);
			return PartialView("_MonthlyUniformStatementByParentStudentDataPartial", ds);
		}
		#endregion

		#region TuitionRevenue
		public IActionResult TuitionRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> TuitionReportDataPartial(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			var ds = await _IReportService.GetTuitionReport(parentId, parentName, fatherIqama, studentName, academicYear, invoiceNo, startDate, endDate);
			return PartialView("_MonthlyTuitionRevenueDataPartial", ds);
		}
		#endregion

		#region EntranceRevenue
		public IActionResult EntranceRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> EntranceReportDataPartial(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			var ds = await _IReportService.GetEntranceReport(academicYear, parentId, fatherIqama, parentName, studentName, invoiceNo, startDate, endDate);
			return PartialView("_MonthlyEntranceRevenueReportDataPartial", ds);
		}
		#endregion

		#region AdvanceFeeRevenue
		public IActionResult AdvanceFeeRevenue()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> AdvanceFeeReportDataPartial(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate)
		{
			var ds = await _IReportService.GetAdvanceFeeReport(academicYear, parentId, fatherIqama, parentName, studentName, invoiceNo, startDate, endDate);
			return PartialView("_AdvanceFeeReportDataPartial", ds);
		}
		#endregion

		#region DiscountReport
		public IActionResult DiscountReport()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> DiscountReportDataPartial(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string startDate, string endDate)
		{
			var ds = await _IReportService.GetDiscountReport(parentId, parentName, fatherIqama, studentName, academicYear, startDate, endDate);
			return PartialView("_DiscountReportDataPartial", ds);
		}
		#endregion

		#region All Revenue Report
		public IActionResult AllRevenueReport()
		{
			_logger.LogInformation("Start: ReportController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> AllRevenueReportDataPartial(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate)
		{
			var ds = await _IReportService.GetAllRevenueReport(parentId, parentName, fatherIqama, studentName, academicYear, invoiceNo, startDate, endDate);
			return PartialView("_AllRevenueReportDataPartial", ds);
		}
		#endregion

		#region General Report
		public async Task<IActionResult> GeneralReport()
		{
			_logger.LogInformation("Start: ReportController");
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.CostCenterDropdown = await GetAppDropdown(AppDropdown.CostCenter, true);
			ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.GenderDropdown = await GetAppDropdown(AppDropdown.Gender, true);
			return View();
		}
		public async Task<IActionResult> GeneralReportDataPartial(int academicYear, int costcenter, int grade, int gender)
		{
			var ds = await _IReportService.GetGeneralReport(academicYear, costcenter, grade, gender);
			return PartialView("_GeneralReportDataPartial", ds);
		}
		#endregion

		#region Parent Student Report
		public async Task<IActionResult> ParentStudentReport()
		{
			_logger.LogInformation("Start: ReportController");
			ViewBag.ParentDropDown = await GetAppDropdown(AppDropdown.Parent, true);
			ViewBag.StudentDropDown = await GetAppDropdown(AppDropdown.Student, true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.CostCenterDropdown = await GetAppDropdown(AppDropdown.CostCenter, true);
			ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.GenderDropdown = await GetAppDropdown(AppDropdown.Gender, true);
			return View();
		}
		public async Task<IActionResult> ParentStudentReportDataPartial(int parentId, int studentId, int academicYear, int costcenter, int grade, int gender, string startDate, string endDate)
		{
			var ds = await _IReportService.GetParentStudentReport(parentId, studentId, academicYear, costcenter, grade, gender, startDate, endDate);
			return PartialView("_ParentStudentReportDataPartial", ds);
		}
		#endregion

		#region Parent Report
		public async Task<IActionResult> ParentReport()
		{
			_logger.LogInformation("Start: ReportController");
			ViewBag.ParentDropDown = await GetAppDropdown(AppDropdown.Parent, true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			return View();
		}
		public async Task<IActionResult> ParentReportDataPartial(int parentId, int academicYear, string startDate, string endDate)
		{
			var ds = await _IReportService.GetParentReport(parentId, academicYear, startDate, endDate);
			return PartialView("_ParentReportDataPartial", ds);
		}


		#endregion

		#region Parent And Student Statement
		public async Task<IActionResult> ParentStudentStatementReport()
		{
			_logger.LogInformation("Start: ReportController");
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.ParentDropdown = await GetAppDropdown(AppDropdown.Parent, true);
			return View();
		}
		public async Task<IActionResult> ParentStudentStatementReportDataPartial(int parentId, string parentName, string fatherIqama, string fatherMobile, int academicYear)
		{
			var ds = await _IReportService.GetStudentStatementParentWise(parentId, parentName, fatherIqama, fatherMobile, academicYear);
			return PartialView("_ParentStudentStatementReportDataPartial", ds);
		}

		[HttpPost]
		public async Task<IActionResult> ExportParentStudentStatemetToExcel([FromBody] FilterData filterData)
		{
			try
			{
				var dsParent = await _IReportService.GetParent(filterData.ParentId);
				// Fetch the data
				var ds = await _IReportService.GetStudentStatementParentWise(
					filterData.ParentId,
					filterData.ParentName,
					filterData.FatherIqama,
					filterData.FatherMobile,
					filterData.AcademicYear);

				if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
				{
					return BadRequest("No data found.");
				}

				using (var package = new ExcelPackage())
				{
					var workbook = package.Workbook;
					var worksheet = workbook.Worksheets.Add("Parent Statement");
					int row = 1;

					// Add header information
					worksheet.Cells[row, 1].Value = "Parent ID";
					if (dsParent != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
						worksheet.Cells[row, 2].Value = dsParent.Tables[0].Rows[0]["ParentCode"];

					worksheet.Cells[row, 4].Value = "Parent Name";
					if (dsParent != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
						worksheet.Cells[row, 5].Value = dsParent.Tables[0].Rows[0]["FatherName"];

					using (var range = worksheet.Cells[row, 1, row, 5])
					{
						range.Style.Font.Bold = true; // Make font bold
						range.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid; // Fill pattern
						range.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray); // Background color
						range.Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center; // Center align
						range.Style.VerticalAlignment = OfficeOpenXml.Style.ExcelVerticalAlignment.Center; // Center vertically
					}

					// Process each DataTable in the DataSet
					decimal totalFeeAmount = 0;
					decimal totalPaidAmount = 0;
					decimal TotalDiscount = 0;
					foreach (DataTable dt in ds.Tables)
					{
						StudentModel model = new StudentModel();
						int studentId = Convert.ToInt32(dt.Rows[0]["StudentId"]);
						if (studentId > 0)
							model = await _IStudentService.GetStudentById(studentId);

						row += 2;
						worksheet.Cells[row, 1].Value = "Student Name: " + dt.Rows[0]["StudentName"];
						worksheet.Cells[row, 2].Value = "Student Code: " + model.StudentCode;
						worksheet.Cells[row, 3].Value = "Grade: " + model.GradeName;
						row += 2;
						worksheet.Cells[row, 1].Value = "S.No";
						worksheet.Cells[row, 2].Value = "Academic Year";
						worksheet.Cells[row, 3].Value = "Student Name";
						worksheet.Cells[row, 4].Value = "Invoice No";
						worksheet.Cells[row, 5].Value = "Date";
						worksheet.Cells[row, 6].Value = "Payment Method";
						worksheet.Cells[row, 7].Value = "Fee Type";
						worksheet.Cells[row, 8].Value = "Fee Amount";
						worksheet.Cells[row, 9].Value = "Paid Amount";

						using (var range = worksheet.Cells[row, 1, row, 9])
						{
							range.Style.Font.Bold = true; // Make font bold
							range.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid; // Fill pattern
							range.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray); // Background color
							range.Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center; // Center align
							range.Style.VerticalAlignment = OfficeOpenXml.Style.ExcelVerticalAlignment.Center; // Center vertically
						}
						row++;
						// Populate data rows
						decimal PaidAmount = 0;
						decimal FeeAmount = 0;
						for (int i = 0; i < dt.Rows.Count; i++)
						{

							var dr = dt.Rows[i];
							if (Convert.ToString(dr["FeeTypeName"]).ToLower().Contains("discount"))
							{
								TotalDiscount = TotalDiscount + Convert.ToDecimal(dr["PaidAmount"]);
							}
							worksheet.Cells[row, 1].Value = i + 1;
							worksheet.Cells[row, 2].Value = dr["AcademicYear"];
							worksheet.Cells[row, 3].Value = dr["StudentName"];
							worksheet.Cells[row, 4].Value = dr["InvoiceNo"];
							worksheet.Cells[row, 5].Value = dr["RecordDate"] != DBNull.Value ?
								Convert.ToDateTime(dr["RecordDate"]).ToString("dd/MM/yyyy") : "";
							worksheet.Cells[row, 6].Value = dr["PaymentMethod"];
							worksheet.Cells[row, 7].Value = dr["FeeTypeName"];
							worksheet.Cells[row, 8].Value = Convert.ToDecimal(dr["FeeAmount"]).ToString("F2");
							worksheet.Cells[row, 9].Value = Convert.ToDecimal(dr["PaidAmount"]).ToString("F2");

							PaidAmount = PaidAmount + Convert.ToDecimal(dr["PaidAmount"]);
							FeeAmount = FeeAmount + Convert.ToDecimal(dr["FeeAmount"]);

							row++;
						}

						totalPaidAmount += PaidAmount;
						totalFeeAmount += FeeAmount;

						worksheet.Cells[row, 8].Value = "Total Balance:";
						worksheet.Cells[row, 9].Value = (FeeAmount - PaidAmount).ToTwoDecimalString();
						using (var range = worksheet.Cells[row, 8, row, 9])
						{
							range.Style.Font.Bold = true; // Make font bold
							range.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid; // Fill pattern
							range.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray); // Background color
							range.Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center; // Center align
							range.Style.VerticalAlignment = OfficeOpenXml.Style.ExcelVerticalAlignment.Center; // Center vertically
						}

					}

					row += 2;
					worksheet.Cells[row, 1].Value = "Grand Total :";
					worksheet.Cells[row, 6].Value = "Total Fee : " + totalFeeAmount.ToTwoDecimalString();
					worksheet.Cells[row, 7].Value = "Total Discount : " + TotalDiscount.ToTwoDecimalString();
					worksheet.Cells[row, 8].Value = "Total Payment : " + (totalPaidAmount - TotalDiscount).ToTwoDecimalString();
					worksheet.Cells[row, 9].Value = "Total Balance : " + (totalFeeAmount - totalPaidAmount).ToTwoDecimalString();
					using (var range = worksheet.Cells[row, 1, row, 9])
					{
						range.Style.Font.Bold = true; // Make font bold
						range.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid; // Fill pattern
						range.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.LightGray); // Background color
						range.Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center; // Center align
						range.Style.VerticalAlignment = OfficeOpenXml.Style.ExcelVerticalAlignment.Center; // Center vertically
					}

					// Auto-fit columns
					worksheet.Cells.AutoFitColumns();

					// Prepare the Excel file for download
					var stream = new MemoryStream();
					package.SaveAs(stream);
					stream.Position = 0;

					var uploadsFolder = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "excelFile");
					if (!Directory.Exists(uploadsFolder))
					{
						Directory.CreateDirectory(uploadsFolder);
					}
					var fileName = Utility.GetUniqueFileName("Parent_Statement.xlsx");
					var excelFilePath = Path.Combine(uploadsFolder, fileName);
					System.IO.File.WriteAllBytes(excelFilePath, stream.ToArray());

					string pdfFilename = "Parent_Statement.pdf";
					pdfFilename = Path.Combine(uploadsFolder, pdfFilename);

					return File(stream, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "Parent_Statement.xlsx");
				}
			}
			catch (Exception ex)
			{
				// Log exception (consider using a logging framework)
				Console.WriteLine($"Exception: {ex.Message}");
				return StatusCode(500, "Internal server error: " + ex.Message);
			}
		}



		private async Task<Dictionary<string, string>> GetPrimaryDataDictionary(DataSet dsParent, DataSet ds)
		{
			Dictionary<string, string> mailData = new Dictionary<string, string>();

			var ECISLogo4 = GetImageBase64Path("ECIS_LOGO.png");
			var IBLogo = GetImageBase64Path("IB_CIS_Logo.png");
			var ALSLogo = GetImageBase64Path("alsLogo.png");
			var CISLogo = GetImageBase64Path("CISlogo.png");
			var MOELogo = GetImageBase64Path("MOE_Logo.png");


            mailData.Add("ECISLogo4", ECISLogo4);
			mailData.Add("IBLogo", IBLogo);
			mailData.Add("ALSLogo", ALSLogo);
			mailData.Add("CISLogo", CISLogo);
			mailData.Add("MOELogo", MOELogo);

			var currentAcademic = await _iSchoolAcademicManager.GetCurrentAcademic();
			if (currentAcademic == null)
			{
                mailData.Add("AcademicYear", DateTime.Now.ToString("yyyy") + (DateTime.Now.Year + 1).ToString());
                mailData.Add("AcademicYearName", "");
			}
			else
			{
				mailData.Add("AcademicYear", currentAcademic.PeriodFrom.ToString("yyyy"));
				mailData.Add("AcademicYearName", currentAcademic.AcademicYear);
                

            }

			if (dsParent != null && dsParent.Tables.Count > 0 && dsParent.Tables[0].Rows.Count > 0)
			{
				mailData.Add("ParentCode", Convert.ToString(dsParent.Tables[0].Rows[0]["ParentCode"]));
				mailData.Add("ParentName", Convert.ToString(dsParent.Tables[0].Rows[0]["FatherName"]));
				if (Convert.ToString(dsParent.Tables[0].Rows[0]["FatherArabicName"]) != "")
				{
					mailData.Add("ParentNameArabic", Convert.ToString(dsParent.Tables[0].Rows[0]["FatherArabicName"]));
				}
				else 
				{
                    mailData.Add("ParentNameArabic", Convert.ToString(dsParent.Tables[0].Rows[0]["FatherName"]));
                }
            }
            else
			{
				mailData.Add("ParentCode", "");
				mailData.Add("ParentName", "");
				mailData.Add("ParentNameArabic", "");
			}

			//mailData.Add("PrintDate", DateTime.Now.ToString("dd/MM/yyyy"));
            mailData.Add("PrintDate", DateTime.Now.ToString("d MMMM yyyy"));


			mailData.Add("PrintDateAr", DateTime.Now.ToString("d MMMM yyyy")
					.Replace("January", "يناير")
					.Replace("February", "فبراير")
					.Replace("March", "مارس")
					.Replace("April", "أبريل")
					.Replace("May", "مايو")
					.Replace("June", "يونيو")
					.Replace("July", "يوليو")
					.Replace("August", "أغسطس")
					.Replace("September", "سبتمبر")
					.Replace("October", "أكتوبر")
					.Replace("November", "نوفمبر")
					.Replace("December", "ديسمبر")
				);
			


			return mailData;
		}


		#region Parent Statement Pdf Detail
		public async Task<IActionResult> ExportParentStudentStatemetToPdf([FromBody] FilterData filterData)
		{
			_logger.LogInformation("Start: SendInvoiceEmailService");
			try
			{
				var dsParent = await _IReportService.GetParent(filterData.ParentId);
				// Fetch the data
				var ds = await _IReportService.GetStudentStatementParentWise(
					filterData.ParentId,
					filterData.ParentName,
					filterData.FatherIqama,
					filterData.FatherMobile,
					filterData.AcademicYear);

				if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
				{
					return BadRequest("No data found.");
				}

				if (ds != null && ds.Tables.Count > 0)
				{
					if (ds.Tables[0].Rows.Count > 0)
					{
						Dictionary<string, string> finalDataDictionary = new Dictionary<string, string>();
						Dictionary<string, string> primaryDataDictionary = await GetPrimaryDataDictionary(dsParent, ds);
						Dictionary<string, string> studentDataDictionary = await GetStatmentDetailDataDictionary(dsParent, ds);

						finalDataDictionary.AddRange(primaryDataDictionary);
						finalDataDictionary.AddRange(studentDataDictionary);

						string mailSubject = PdfUtility.GetTemplateSubject(ConfigTemplate.ParentStatement);
						string mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.ParentStatement);
						mailSubject = PdfUtility.ProcessTemplate(mailSubject, finalDataDictionary);
						mailBody = PdfUtility.ProcessTemplate(mailBody, finalDataDictionary);
						//return await _emailHelper.SendEmail(employeeEmail, mailSubject, mailBody, filePath);

						PdfUtility pdfHelper = new PdfUtility();
						byte[] pdfBuffer = pdfHelper.PhantomHtmlStringToBytes(mailBody);

						string invoicePath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CertificateFolder", "Invoices")}";
						if (!Directory.Exists(invoicePath))
							Directory.CreateDirectory(invoicePath);
						string fileName = $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf";
						string filePath = Path.Combine(invoicePath, fileName);
						if (pdfBuffer != null)
						{
							using (var stream = System.IO.File.Create(filePath))
							{
								stream.Write(pdfBuffer, 0, pdfBuffer.Length);
							}
						}

						var fileStream = System.IO.File.ReadAllBytes(filePath);
						return File(fileStream, "application/pdf", "Parent_Statement.pdf");
					}
				}

			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:EmailService:SendInvoiceEmailWithoutInvoiceAttachment : Message :{JsonConvert.SerializeObject(ex)}");
			}
			return null;
		}

		private async Task<Dictionary<string, string>> GetStatmentDetailDataDictionary(DataSet dsParent, DataSet ds)
		{
			Dictionary<string, string> mailData = new Dictionary<string, string>();

			decimal totalFeeAmount = 0;
			decimal totalPaidAmount = 0;
			decimal totalDiscount = 0;
			decimal totalVAT = 0;
			StringBuilder strInvoiceItem = new StringBuilder();

			foreach (DataTable dt in ds.Tables)
			{
				StudentModel model = new StudentModel();
				int studentId = Convert.ToInt32(dt.Rows[0]["StudentId"]);
				if (studentId > 0)
					model = await _IStudentService.GetStudentById(studentId);

				var studentStatment = GetStudentDetailStatement(dt.Rows[0]["StudentName"].ToString(), model.StudentCode, model.GradeName, dt,
					ref totalFeeAmount, ref totalPaidAmount, ref totalDiscount, ref totalVAT);

				strInvoiceItem.Append(studentStatment);
				strInvoiceItem.AppendLine();
			}

			mailData.Add("StudentStament", strInvoiceItem.ToString());

			mailData.Add("TotalFee", totalFeeAmount.ToTwoDecimalString());
			mailData.Add("TotalDiscount", totalDiscount.ToTwoDecimalString());
			mailData.Add("TotalPayment", (totalPaidAmount - totalDiscount).ToTwoDecimalString());
			mailData.Add("TotalBalance", (totalFeeAmount - totalPaidAmount).ToTwoDecimalString());

			return mailData;
		}

		private string GetStudentDetailStatement(string studentName, string studentCode, string gradeName, DataTable dt,
		ref decimal totalFeeAmount,
		ref decimal totalPaidAmount,
		ref decimal TotalDiscount,
		ref decimal totalVAT
			)
		{
			//Student Information with code name
			StringBuilder strInvoiceItem = new StringBuilder();

			//Add Studen stament table here
			string studentStatementTableString = GetStudentDetailStatementTableSummary(dt, ref totalFeeAmount, ref totalPaidAmount, ref TotalDiscount, ref totalVAT);

			strInvoiceItem.Append(@"
			<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>");

			strInvoiceItem.AppendFormat(@"
                <tr>  
                    <td style='text-align: left;font-weight: bold;'>Student Name: {0}</td>
                    <td style='text-align: left;font-weight: bold;'>Student Code: {1}</td>
                    <td style='text-align: left;font-weight: bold;'>Grade: {2}</td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
                </tr>",
				studentName,
				studentCode,
				gradeName
				);

			//Add space here
			strInvoiceItem.AppendFormat(@"
                <tr>  
                    <td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
					<td style='text-align: left;'></td>
                </tr>"
				);


			strInvoiceItem.AppendFormat(@"
                <tr>  
                    <td colspan='8'  style='text-align: left;'>{0}</td>
                </tr>"
				, studentStatementTableString
				);

			strInvoiceItem.AppendFormat(@"</table>");
			return strInvoiceItem.ToString();
		}

		private string GetStudentDetailStatementTableSummary(DataTable dt,
			ref decimal totalFeeAmount,
			ref decimal totalPaidAmount,
			ref decimal totalDiscount,
			ref decimal totalVAT)
		{
			StringBuilder strInvoiceItem = new StringBuilder();
			strInvoiceItem.Append(@"
			<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
				<tr style='background-color: #00b0f0; color: white;'>
					<th width='10%' style='border: 1px solid #FFFFFF; text-align: center;'>S.No</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Academic Year</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Invoice No</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Date</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Payment Method</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Fee Type</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Fee Amount</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Paid Amount</th>
				</tr>");

			decimal PaidAmount = 0;
			decimal FeeAmount = 0;
			decimal taxAmount = 0;
			for (int i = 0; i < dt.Rows.Count; i++)
			{
				var dr = dt.Rows[i];
				string feeTypeNameName = dr["FeeTypeName"].ToString();

				if (Convert.ToString(dr["FeeTypeName"]).ToLower().Contains("discount"))
				{
					totalDiscount = totalDiscount + Convert.ToDecimal(dr["PaidAmount"]);
					feeTypeNameName = "Discount";
				}

				if (Convert.ToString(dr["FeeTypeName"]).ToLower().Contains("opening"))
				{
					feeTypeNameName = "Open Bal";
				}

				strInvoiceItem.AppendFormat(@"
				<tr>
					<td width='5%' style='text-align: center;'>{0}</td>
					<td width='10%'  style='text-align: center;'>{1}</td>
					<td width='5%'  style='text-align: center;'>{2}</td>
					<td width='10%'  style='text-align: center;'>{3}</td>
					<td width='10%'  style='text-align: center;'>{4}</td>
					<td width='10%'  style='text-align: center;'>{5}</td>
					<td width='15%'  style='text-align: right;'>{6}</td>
					<td width='15%'  style='text-align: right;'>{7}</td>
				</tr>"
			, (i + 1).ToString()
			, dr["AcademicYear"].ToString()
			, dr["InvoiceNo"].ToString().Equals("0") ? "" : dr["InvoiceNo"].ToString()
			, dr["RecordDate"] != DBNull.Value ? Convert.ToDateTime(dr["RecordDate"]).ToString("dd/MM/yyyy") : ""
			, string.IsNullOrWhiteSpace(dr["PaymentMethod"].ToString()) ? "" : dr["PaymentMethod"].ToString().Substring(0, 4)
			, feeTypeNameName
			, Convert.ToDecimal(dr["FeeAmount"]).ToTwoDecimalString()
			, Convert.ToDecimal(dr["PaidAmount"]).ToTwoDecimalString()
			);

				PaidAmount = PaidAmount + Convert.ToDecimal(dr["PaidAmount"]);
				FeeAmount = FeeAmount + Convert.ToDecimal(dr["FeeAmount"]);

				taxAmount = taxAmount + Convert.ToDecimal(dr["TaxAmount"]);
			}

			strInvoiceItem.AppendFormat(@"
					<tr>
						<td width='5%' style='text-align: center;font-weight: bold;'>{0}</td>
						<td width='10%'  style='text-align: center;font-weight: bold;'>{1}</td>
						<td width='5%'  style='text-align: center;'>{2}</td>
						<td width='10%'  style='text-align: center;'>{3}</td>
						<td width='10%'  style='text-align: center;'>{4}</td>
						<td width='10%'  style='text-align: center;'>{5}</td>
						<td width='15%'  style='text-align: right;font-weight: bold;'>{6}</td>
						<td width='15%'  style='text-align: right;font-weight: bold;'>{7}</td>
					</tr>"
				, ""
				, "Totals"
				, ""
				, ""
				, ""
				, ""
				, FeeAmount.ToTwoDecimalString()
				, (PaidAmount).ToTwoDecimalString()
				);

			//Total balance Line
			totalPaidAmount += PaidAmount;
			totalFeeAmount += FeeAmount;

			strInvoiceItem.AppendFormat(@"
				<tr>
					<td width='10%' colspan='2' style='text-align: right;'></td>	
                 	<td width='10%' style='text-align: right;font-weight: bold;'></td>
	                 <td width='10%' style='text-align: right;font-weight: bold;'>{0}</td>
					<td width='10%' style='text-align: right;font-weight: bold;'>Total VAT</td>		
					<td width='10%' style='text-align: right;font-weight: bold;'>{1}</td>
					<td width='10%' style='text-align: right;font-weight: bold;'>Total Due Balance</td>		
					<td width='10%' style='text-align: right;font-weight: bold;'>{2}</td>
				</tr>"
			 , ""
			, taxAmount.ToTwoDecimalString()
			, (FeeAmount - PaidAmount).ToTwoDecimalString()
			);

			strInvoiceItem.AppendFormat(@"</table>");

			return strInvoiceItem.ToString();
		}

        #endregion
        public async Task<IActionResult> ExportParentStudentStatemetToSummaryPdfEnAr([FromBody] FilterData filterData)
        {
            _logger.LogInformation("Start: SendInvoiceEmailService");
            try
            {
                var dsParent = await _IReportService.GetParent(filterData.ParentId);
                // Fetch the data
                var ds = await _IReportService.GetStudentStatementParentWise(
                    filterData.ParentId,
                    filterData.ParentName,
                    filterData.FatherIqama,
                    filterData.FatherMobile,
                    filterData.AcademicYear);

                if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                {
                    return BadRequest("No data found.");
                }

				

				if (ds != null && ds.Tables.Count > 0)
                {
                    if (ds.Tables[0].Rows.Count > 0)
                    {
                        Dictionary<string, string> finalDataDictionary = new Dictionary<string, string>();
                        Dictionary<string, string> primaryDataDictionary = await GetPrimaryDataDictionary(dsParent, ds);
                        Dictionary<string, string> studentDataDictionary = await GetStatmentSummaryDataDictionary(dsParent, ds);

                        finalDataDictionary.AddRange(primaryDataDictionary);
                        finalDataDictionary.AddRange(studentDataDictionary);
						string mailBody = "";

						string mailSubject = PdfUtility.GetTemplateSubject(ConfigTemplate.ParentStatement);
						if (filterData.type == "en")
						{
							 mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.ParentStatementSummaryGov);
						}
						else {
							 mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.ParentStatementSummaryGovAr);

						}
						

                        
						mailSubject = PdfUtility.ProcessTemplate(mailSubject, finalDataDictionary);
                        mailBody = PdfUtility.ProcessTemplate(mailBody, finalDataDictionary);
                        //return await _emailHelper.SendEmail(employeeEmail, mailSubject, mailBody, filePath);

                        PdfUtility pdfHelper = new PdfUtility();
						//
						byte[] pdfBuffer = pdfHelper.PhantomHtmlStringToBytesSummary(mailBody,filterData.type);


						string invoicePath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CertificateFolder", "Invoices")}";
                        if (!Directory.Exists(invoicePath))
                            Directory.CreateDirectory(invoicePath);
                        string fileName = $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf";
                        string filePath = Path.Combine(invoicePath, fileName);
                        if (pdfBuffer != null)
                        {
                            using (var stream = System.IO.File.Create(filePath))
                            {
                                stream.Write(pdfBuffer, 0, pdfBuffer.Length);
                            }
                        }

                        var fileStream = System.IO.File.ReadAllBytes(filePath);
                        return File(fileStream, "application/pdf", "Parent_Statement.pdf");
                    }
                }

            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:EmailService:SendInvoiceEmailWithoutInvoiceAttachment : Message :{JsonConvert.SerializeObject(ex)}");
            }
            return null;
        }

        #region Parent Statement Pdf Summary
        public async Task<IActionResult> ExportParentStudentStatemetToSummaryPdf([FromBody] FilterData filterData)
		{
			_logger.LogInformation("Start: SendInvoiceEmailService");
			try
			{
				var dsParent = await _IReportService.GetParent(filterData.ParentId);
				// Fetch the data
				var ds = await _IReportService.GetStudentStatementParentWise(
					filterData.ParentId,
					filterData.ParentName,
					filterData.FatherIqama,
					filterData.FatherMobile,
					filterData.AcademicYear);

				if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
				{
					return BadRequest("No data found.");
				}

				if (ds != null && ds.Tables.Count > 0)
				{
					if (ds.Tables[0].Rows.Count > 0)
					{
						Dictionary<string, string> finalDataDictionary = new Dictionary<string, string>();
						Dictionary<string, string> primaryDataDictionary = await GetPrimaryDataDictionary(dsParent, ds);
						Dictionary<string, string> studentDataDictionary = await GetStatmentSummaryDataDictionary(dsParent, ds);

						finalDataDictionary.AddRange(primaryDataDictionary);
						finalDataDictionary.AddRange(studentDataDictionary);

						string mailSubject = PdfUtility.GetTemplateSubject(ConfigTemplate.ParentStatement);
						string mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.ParentStatement);
						mailSubject = PdfUtility.ProcessTemplate(mailSubject, finalDataDictionary);
						mailBody = PdfUtility.ProcessTemplate(mailBody, finalDataDictionary);
						//return await _emailHelper.SendEmail(employeeEmail, mailSubject, mailBody, filePath);

						PdfUtility pdfHelper = new PdfUtility();
						byte[] pdfBuffer = pdfHelper.PhantomHtmlStringToBytes(mailBody);
                        

                        string invoicePath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CertificateFolder", "Invoices")}";
						if (!Directory.Exists(invoicePath))
							Directory.CreateDirectory(invoicePath);
						string fileName = $"Invoice_{DateTime.Now:yyyyMMddHHmmss}.pdf";
						string filePath = Path.Combine(invoicePath, fileName);
						if (pdfBuffer != null)
						{
							using (var stream = System.IO.File.Create(filePath))
							{
								stream.Write(pdfBuffer, 0, pdfBuffer.Length);
							}
						}

						var fileStream = System.IO.File.ReadAllBytes(filePath);
						return File(fileStream, "application/pdf", "Parent_Statement.pdf");
					}
				}

			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:EmailService:SendInvoiceEmailWithoutInvoiceAttachment : Message :{JsonConvert.SerializeObject(ex)}");
			}
			return null;
		}

		private async Task<Dictionary<string, string>> GetStatmentSummaryDataDictionary(DataSet dsParent, DataSet ds)
		{
			Dictionary<string, string> mailData = new Dictionary<string, string>();

			decimal totalFeeAmount = 0;
			decimal totalPaidAmount = 0;
			decimal totalDiscount = 0;
			decimal totalVAT = 0;
			StringBuilder strInvoiceItem = new StringBuilder();
            StringBuilder strInvoiceItemAr = new StringBuilder();

            strInvoiceItem.Append(@"
			<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
				<tr style='background-color: #00b0f0; color: white;'>
					<th width='10%' style='display:none;border: 1px solid #FFFFFF; text-align: center;'>#</th>
					<th width='20%'  style='border: 1px solid #FFFFFF; text-align: center;'>Student Name</th>
					<th width='10%' style='border: 1px solid #FFFFFF; text-align: center;'>Grade</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Fee Amount</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Discount</th>					
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>Paid Amount</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>VAT</th>
					<th width='20%'  style='border: 1px solid #FFFFFF; text-align: center;'>Due Balance</th>
				</tr>");

            strInvoiceItemAr.Append(@"
			<table  cellpadding='4' cellspacing='0' style='width:100%; border: 1px solid #ddd; border-collapse: separate; font-size: 12px;page-break-inside: avoid;'>
				<tr style='background-color: #00b0f0; color: white;'>
					<th width='10%' style='display:none;border: 1px solid #FFFFFF; text-align: center;'>#</th>
					<th width='20%'  style='border: 1px solid #FFFFFF; text-align: center;'>اسم الطالب</th>
					<th width='20%' style='border: 1px solid #FFFFFF; text-align: center;'>الدراسية المرحلة</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>الدراسي قيمةالقسط</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>خصم األخوة</th>					
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>المبالغ المدفوعة</th>
					<th width='10%'  style='border: 1px solid #FFFFFF; text-align: center;'>المضافة قيمة الضريبة</th>
					<th width='20%'  style='border: 1px solid #FFFFFF; text-align: center;'>المبالغ المستحقة</th>
				</tr>");


            int rowNow = 0;
            var studentName = "";
			var gradeArabic = "";

			foreach (DataTable dt in ds.Tables)
			{
				rowNow++;
				StudentModel model = new StudentModel();
				int studentId = Convert.ToInt32(dt.Rows[0]["StudentId"]);
				if (studentId > 0)
					model =  await _IStudentService.GetStudentById(studentId);

				gradeArabic = await _IStudentService.GetStudentGradeAr(studentId);

				

				decimal PaidAmount = 0;
				decimal FeeAmount = 0;
				decimal DiscountAmount = 0;
				decimal taxAmount = 0;
				
				for (int i = 0; i < dt.Rows.Count; i++)
				{
					var dr = dt.Rows[i];

					if (Convert.ToString(dr["FeeTypeName"]).ToLower().Contains("discount"))
					{
						DiscountAmount = DiscountAmount + Convert.ToDecimal(dr["PaidAmount"]);
					}
					else
					{
						PaidAmount = PaidAmount + Convert.ToDecimal(dr["PaidAmount"]);
					}
					FeeAmount = FeeAmount + Convert.ToDecimal(dr["FeeAmount"]);
					taxAmount = taxAmount + Convert.ToDecimal(dr["TaxAmount"]);
					  
				}

				
				Console.WriteLine(" model GradeNameArabic" + gradeArabic);


				if (studentName == "")
                {
                    studentName = studentName + dt.Rows[0]["StudentName"].ToString();
                }
                else
                {
                    studentName = studentName + "," + dt.Rows[0]["StudentName"].ToString();
                }
                strInvoiceItem.AppendFormat(@"
					<tr>
						<td width='10%' style='display:none;text-align: center;'>{0}</td>
						<td width='20%' style='text-align: left;'>{1}</td>
						<td width='10%' style='text-align: center;'>{2}</td>
						<td width='10%' style='text-align: right;'>{3}</td>
						<td width='10%' style='text-align: right;'>{4}</td>
						<td width='10%' style='text-align: right;'>{5}</td>
						<td width='10%' style='text-align: right;'>{6}</td>
						<td width='20%' style='text-align: right;'>{7}</td>
					</tr>"
				, rowNow
				, dt.Rows[0]["StudentName"].ToString()
				, model.GradeName
				, FeeAmount.ToTwoDecimalString()
				, DiscountAmount.ToTwoDecimalString()
				, PaidAmount.ToTwoDecimalString()
				, taxAmount.ToTwoDecimalString()
				, (FeeAmount - PaidAmount - DiscountAmount).ToTwoDecimalString()
				);

                strInvoiceItemAr.AppendFormat(@"
					<tr>
						<td width='10%' style='display:none;text-align: center;'>{0}</td>
						<td width='20%' style='text-align: right;'>{1}</td>
						<td width='20%' style='text-align: center;'>{2}</td>
						<td width='10%' style='text-align: right;'>{3}</td>
						<td width='10%' style='text-align: right;'>{4}</td>
						<td width='10%' style='text-align: right;'>{5}</td>
						<td width='10%' style='text-align: right;'>{6}</td>
						<td width='20%' style='text-align: right;'>{7}</td>
					</tr>"
                , rowNow
                , model.StudentArabicName.ToString()
				, (gradeArabic != "" ) ? gradeArabic : model.GradeName
				, FeeAmount.ToTwoDecimalString()
                , DiscountAmount.ToTwoDecimalString()
                , PaidAmount.ToTwoDecimalString()
                , taxAmount.ToTwoDecimalString()
                , (FeeAmount - PaidAmount - DiscountAmount).ToTwoDecimalString()
                );

                //Total balance Line
                totalPaidAmount += PaidAmount;
				totalFeeAmount += FeeAmount;
				totalDiscount += DiscountAmount;
				totalVAT += taxAmount;
			}

			strInvoiceItem.AppendFormat(@"
					<tr>
						<td width='10%' style='display:none;text-align: center;'><b>{0}</b></td>
						<td width='20%' style='text-align: center;'><b>{1}</b></td>
						<td width='10%' style='text-align: center;'><b>{2}</b></td>
						<td width='10%' style='text-align: right;'><b>{3}</b></td>
						<td width='10%' style='text-align: right;'><b>{4}</b></td>
						<td width='10%' style='text-align: right;'><b>{5}</b></td>
						<td width='10%' style='text-align: right;'><b>{6}</b></td>
						<td width='20%' style='text-align: right;'><b>{7}</b></td>
					</tr>"
				, ""
				, "Totals"
				, ""
				, totalFeeAmount.ToTwoDecimalString()
				, totalDiscount.ToTwoDecimalString()
				, totalPaidAmount.ToTwoDecimalString()
				, totalVAT.ToTwoDecimalString()
				, (totalFeeAmount - totalPaidAmount - totalDiscount).ToTwoDecimalString()
				);


            strInvoiceItemAr.AppendFormat(@"
					<tr>
						<td width='10%' style='display:none;text-align: center;'><b>{0}</b></td>
						<td width='20%' style='text-align: center;'><b>{1}</b></td>
						<td width='20%' style='text-align: center;'><b>{2}</b></td>
						<td width='10%' style='text-align: right;'><b>{3}</b></td>
						<td width='10%' style='text-align: right;'><b>{4}</b></td>
						<td width='10%' style='text-align: right;'><b>{5}</b></td>
						<td width='10%' style='text-align: right;'><b>{6}</b></td>
						<td width='20%' style='text-align: right;'><b>{7}</b></td>
					</tr>"
                , ""
                , "المجموع"
                , ""
                , totalFeeAmount.ToTwoDecimalString()
                , totalDiscount.ToTwoDecimalString()
                , totalPaidAmount.ToTwoDecimalString()
                , totalVAT.ToTwoDecimalString()
                , (totalFeeAmount - totalPaidAmount - totalDiscount).ToTwoDecimalString()
                );

            strInvoiceItem.AppendFormat(@"</table>");

            strInvoiceItemAr.AppendFormat(@"</table>");
            mailData.Add("StudentStament", strInvoiceItem.ToString());
			
            mailData.Add("StudentStamentArabic", strInvoiceItemAr.ToString());
            
            mailData.Add("StudentName", studentName);
            mailData.Add("TotalFee", totalFeeAmount.ToTwoDecimalString());
			mailData.Add("TotalDiscount", totalDiscount.ToTwoDecimalString());
			mailData.Add("TotalPayment", (totalPaidAmount - totalDiscount).ToTwoDecimalString());
			mailData.Add("TotalBalance", (totalFeeAmount - totalPaidAmount - totalDiscount).ToTwoDecimalString());
			mailData.Add("TotalVAT", totalVAT.ToTwoDecimalString());

			return mailData;
		}

		#endregion Parent Statement Pdf Summary

		private string GetImageBase64Path(string fileName)
		{
			try
			{
				var qrPath = $"{System.IO.Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")}/EmailTemplates/Images/";
				//string qrPath = $"{Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Configurations", "Images")}";
				// Ensure the folder exists, create it if it doesn't
				if (!System.IO.Directory.Exists(qrPath))
					System.IO.Directory.CreateDirectory(qrPath);

				string qrfilePath = Path.Combine(qrPath, fileName);

				byte[] imageBytes = System.IO.File.ReadAllBytes(qrfilePath);
				string base64String = Convert.ToBase64String(imageBytes);
				string qrImg = $"data:image/png;base64,{base64String}";
				return qrImg;
			}
			catch (Exception ex)
			{
				return null;
			}
		}
		#endregion

		public async Task<IActionResult> GetCurrentAcademicYear()
		{
			var data = await _iSchoolAcademicManager.GetCurrentAcademic();
			return Json(data);
		}
	}
	public class FilterData
	{
		public int ParentId { get; set; }
		public string ParentName { get; set; }
		public string FatherIqama { get; set; }
		public string FatherMobile { get; set; }
		public int AcademicYear { get; set; }
		public string type { get; set; }
	}
}
