using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.NotificationModels;
using School.Models.WebModels.StudentModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Web.Controllers
{
	[Authorize]
	public class StudentController : BaseController
	{
		private readonly ILogger<StudentController> _logger;
		private IStudentService _IStudentService;
		private ICommonService _ICommonService;
		IOptions<AppSettingConfig> _AppSettingConfig;
		IHttpContextAccessor _IHttpContextAccessor;
		private readonly IWebHostEnvironment _IWebHostEnvironment;
		public StudentController(ILogger<StudentController> logger, IOptions<AppSettingConfig> appSettingConfig,
			IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService,
			IWebHostEnvironment iWebHostEnvironment,
			 IStudentService iStudentService,
			  ICommonService iCommonService
			) : base(iHttpContextAccessor, iDropdownService)
		{
			_logger = logger;
			_AppSettingConfig = appSettingConfig;
			_IHttpContextAccessor = iHttpContextAccessor;
			_IWebHostEnvironment = iWebHostEnvironment;
			_IStudentService = iStudentService;
			_ICommonService = iCommonService;
		}
		#region Student
		public async void InitDropdown()
		{
			ViewBag.CountryDropdown = await GetAppDropdown(AppDropdown.Country, true);
			ViewBag.ParentDropdown = await GetAppDropdown(AppDropdown.Parent, true);
			ViewBag.GenderDropdown = await GetAppDropdown(AppDropdown.Gender, true);
			ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.CostCenterDropdown = await GetAppDropdown(AppDropdown.CostCenter, true);
			ViewBag.SectionDropdown = await GetAppDropdown(AppDropdown.Section, true);
			ViewBag.StudentStatusDropdown = await GetAppDropdown(AppDropdown.StudentStatus, true);
			ViewBag.TermDropdown = await GetAppDropdown(AppDropdown.Term, true);
			ViewBag.TermYear = await GetAppTermYearDropdown(true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.AllStudentStatusDropDown = await GetAppDropdown(AppDropdown.AllStudentStatus, true);
		}
		public async Task<IActionResult> ParentLookupPartial()
		{
			return PartialView("_ParentLookupPartial");
		}
		[HttpPost]
		public async Task<IActionResult> ParentLookup(ParentLookupModel model)
		{
			return PartialView("_ParentDataPartial", await _IStudentService.GetParentLookup(model));
		}
		public async Task<IActionResult> StudentList()
		{
			_logger.LogInformation("Start: StudentController");
			InitDropdown();
			return View();
		}
		public async Task<IActionResult> ViewStudent(int studentId)
		{
			InitDropdown();
			StudentModel model = new StudentModel();
			model = await _IStudentService.GetStudentById(studentId);
			if (!string.IsNullOrEmpty(model.StudentImage))
				model.StudentImage = model.StudentImage.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
			return View(model);
		}

	

		public async Task<IActionResult> StudentDataPartial(StudentFilterModel model)
		{
			DataSet ds = await _IStudentService.GetStudents(model);

			ds.Tables[0].AsEnumerable().ToList().ForEach(row =>
			{
				if (!string.IsNullOrEmpty(Convert.ToString(row["StudentImage"])))
					row["StudentImage"] = row.Field<string>("StudentImage").Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
			});
			return PartialView("_StudentDataPartial", ds);
		}

		public async Task<IActionResult> AddEditStudent(int studentId = 0)
		{
			InitDropdown();
			StudentModel model = new StudentModel();
			if (studentId > 0)
			{
				model = await _IStudentService.GetStudentById(studentId);
				DateTime AdmissionYearDate;
				if (DateTime.TryParse(model.AdmissionYear, out AdmissionYearDate))
				{
					model.AdmissionYear = AdmissionYearDate.ToString("yyyy");
				}
				else if (!string.IsNullOrEmpty(model.AdmissionYear) && model.AdmissionYear.Length == 4)
					model.AdmissionYear = model.AdmissionYear;
				else
					model.AdmissionYear = string.Empty;

				if (!string.IsNullOrEmpty(model.StudentImage))
					model.StudentImage = model.StudentImage.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
			}
			return View(model);
		}

		[HttpPost]
		public async Task<IActionResult> SaveStudent(IFormFile studentImage, StudentModel model)
		{
			if (model.StudentId == 0)
			{
				if (studentImage != null && studentImage.Length > 0)
				{
					var uploadsFolder = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "studentimages");
					if (!Directory.Exists(uploadsFolder))
					{
						Directory.CreateDirectory(uploadsFolder);
					}
					var fileName = Utility.GetUniqueFileName(studentImage.FileName);
					var filePath = Path.Combine(uploadsFolder, fileName);
					using (var stream = new FileStream(filePath, FileMode.Create))
					{
						await studentImage.CopyToAsync(stream);
					}
					model.StudentImage = filePath;
				}
			}
			return Json(new { result = await _IStudentService.SaveStudent(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
		}

		[HttpPost]
		public async Task<IActionResult> UploadProfilePicture(IFormCollection iFormCollection)
		{
			string imagePath = string.Empty;
			string folderPath = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "studentimages");
			if (!Directory.Exists(folderPath))
			{
				Directory.CreateDirectory(folderPath);
			}
			foreach (var file in iFormCollection.Files)
			{
				var uniqueFileName = Utility.GetUniqueFileName(file.FileName);
				imagePath = Path.Combine(folderPath, uniqueFileName);
				using var fileStream = new FileStream(imagePath, FileMode.Create);
				await file.CopyToAsync(fileStream);
			}
			return Json(new { result = await _IStudentService.UpdateStudentProfilePicture(Convert.ToInt32(GetUserDataFromClaims("UserId")), Convert.ToInt16(iFormCollection["studentId"]), imagePath) });
		}

		public async Task<IActionResult> DeleteStudent(int studentId)
		{
			return Json(new { result = await _IStudentService.DeleteStudent(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentId) });
		}
		[HttpGet]
		public JsonResult GetGrade(int costCenterId)
		{
			var grades = _IStudentService.GetGrades(costCenterId);
			return Json(grades);
		}
		#endregion

		public async Task<IActionResult> NotificationList()
		{
			return View();
		}

		public async Task<IActionResult> NotificationPartial()
		{
			//DataSet ds = await _IStudentService.GetStudents(model);
			var ds = await _ICommonService.GetNotificationList(Convert.ToInt32(GetUserDataFromClaims("UserId")));

			return PartialView("_NotificationPartial", ds);
		}
		[HttpPost]
		public async Task<IActionResult> ApproveNotification(NotificationApproval notificationApproval)
		{
			try
			{
				return Json(new { result = await _ICommonService.ApproveNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationApproval.NotificationIds) });
			}
			catch (Exception)
			{
				return Json(new { isSuccess = false });
			}
			return Json(new { isSuccess = false });
		}

		public async Task<IActionResult> WithdrawStudent(int studentId)
		{
			InitDropdown();
			StudentModel model = new StudentModel();
			model = await _IStudentService.GetStudentById(studentId);
			return View(model);
		}

		public async Task<IActionResult> WithdrawStudentFinal(long studentId)
		{
			var result = 1;
            result =await _IStudentService.FinalStudentWithdraw(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentId);
			return Json(new { result = result });
		}
		#region Student Fee

		public async void IniStudentFeeDetailDropdown()
		{
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.FeeTypeDropDown = await GetAppDropdown(AppDropdown.FeeType, true);
		}
		//public async Task<IActionResult> StudentFeeTypeDetail(int studentId)
		//{
		//    IniStudentFeeDetailDropdown();
		//    StudentFeeMasterModel studentFeeMasterModel = new StudentFeeMasterModel() { StudentId = studentId };
		//    return PartialView("_StudentFeeTypeDetail", studentFeeMasterModel);
		//}

		public async Task<IActionResult> StudentFeeStatementDataPartial(int academicYearId, int parentId, int studentId)
		{
			var ds = await _IStudentService.GetStudentFeeStatement(academicYearId, parentId, studentId);
			return PartialView("_StudentFeeStatementDataPartial", ds);
		}

		public async Task<IActionResult> StudentFeeDetailDataPartial(int studentId, bool isReadOnly = false)
		{
			StudentFeeDetail studentFeeDetail = new StudentFeeDetail()
			{
				StudentId = studentId,
				IsReadOnly = isReadOnly,
				StudentFeeRecords = await _IStudentService.GetStudentFeeDetail(studentId)
			};

			return PartialView("_StudentFeeTypeDetailDataPartial", studentFeeDetail);
		}


		public async Task<IActionResult> StudentFeeTypeDetailEditPartial(int studentId, int studentFeeDetailId)
		{
			IniStudentFeeDetailDropdown();

			StudentFeeMasterModel model = new StudentFeeMasterModel();
			model.StudentFeeDetailId = 0;
			model.GradeId = await _IStudentService.GetStudentGrade(studentId);
			if (studentFeeDetailId > 0)
			{
				model = await _IStudentService.GetStudentFeeDetailById(studentId, studentFeeDetailId);
			}
			return PartialView("_StudentFeeTypeDetailEditPartial", model);
		}
		public async Task<IActionResult> GetStudentFeeTypeAmount(long studentId, long gradeId, long feeTypeId, long academicYearId)
		{
			return Json(new { result = await _IStudentService.GetStudentFeeTypeAmount(studentId, gradeId, feeTypeId, academicYearId) });
		}
		[HttpPost]
		public async Task<IActionResult> SaveStudentFeeTypeDetail(StudentFeeMasterModel model)
		{
			return Json(new { result = await _IStudentService.SaveStudentFeeDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
		}
		public async Task<IActionResult> DeleteStudentFeeTypeDetail(int studentFeeDetailId)
		{
			return Json(new { result = await _IStudentService.DeleteStudentFeeDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentFeeDetailId) });
		}
		#endregion

		#region Sibling
		public async Task<IActionResult> SiblingDiscountDetailDataPartial(int studentId, bool isReadOnly = false)
		{
			StudentSiblingDiscountDetail studentSiblingDiscountDetail = new StudentSiblingDiscountDetail()
			{
				StudentId = studentId,
				IsReadOnly = isReadOnly,
				StudentSiblingDiscountRecords = await _IStudentService.GetSiblingDiscountDetail(studentId)
			};
			return PartialView("_SiblingDiscountDetailDataPartial", studentSiblingDiscountDetail);
		}

		public async Task<IActionResult> SiblingDiscountDetailEditPartial(long studentId, long studentSiblingDiscountDetailId, int academicYearId, decimal discountPercent)
		{
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			SiblingDiscountDetailModel siblingDiscountDetailModel = new SiblingDiscountDetailModel()
			{
				StudentId = studentId,
				StudentSiblingDiscountDetailId = studentSiblingDiscountDetailId,
				AcademicYearId = academicYearId,
				DiscountPercent = discountPercent
			};
			return PartialView("_SiblingDiscountDetailEditPartial", siblingDiscountDetailModel);
		}

		public async Task<IActionResult> SaveSiblingDiscountDetail(SiblingDiscountDetailModel model)
		{
			return Json(new { result = await _IStudentService.SaveSiblingDiscountDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
		}

		public async Task<IActionResult> DeleteStudentSiblingDiscountDetail(int studentSiblingDiscountDetailId)
		{
			return Json(new { result = await _IStudentService.DeleteStudentSiblingDiscountDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentSiblingDiscountDetailId) });
		}

		public async Task<IActionResult> UpdateSiblingDiscountStatus(int actionId, int studentSiblingDiscountDetailId)
		{
			return Json(new { result = await _IStudentService.UpdateSiblingDiscountStatus(Convert.ToInt32(GetUserDataFromClaims("UserId")), actionId, studentSiblingDiscountDetailId) });
		}
		#endregion

		#region Other Discount
		public async Task<IActionResult> OtherDiscountDetailDataPartial(int studentId, bool isReadOnly = false)
		{
			StudentOtherDiscountDetail studentOtherDiscountDetail = new StudentOtherDiscountDetail()
			{
				StudentId = studentId,
				IsReadOnly = isReadOnly,
				StudentOtherDiscountRecords = await _IStudentService.GetOtherDiscountDetail(studentId)
			};
			return PartialView("_OtherDiscountDetailDataPartial", studentOtherDiscountDetail);
		}

		public async Task<IActionResult> OtherDiscountDetailEditPartial(long studentId, long studentOtherDiscountDetailId, int academicYearId, decimal discountAmount, string discountName)
		{
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			OtherDiscountDetailModel otherDiscountDetailModel = new OtherDiscountDetailModel()
			{
				StudentId = studentId,
				StudentOtherDiscountDetailId = studentOtherDiscountDetailId,
				AcademicYearId = academicYearId,
				DiscountName = discountName,
				DiscountAmount = discountAmount
			};
			return PartialView("_OtherDiscountDetailEditPartial", otherDiscountDetailModel);
		}

		public async Task<IActionResult> SaveOtherDiscountDetail(OtherDiscountDetailModel model)
		{
			return Json(new { result = await _IStudentService.SaveOtherDiscountDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
		}

		public async Task<IActionResult> DeleteStudentOtherDiscountDetail(int studentOtherDiscountDetailId)
		{
			return Json(new { result = await _IStudentService.DeleteStudentOtherDiscountDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentOtherDiscountDetailId) });
		}
		public async Task<IActionResult> UpdateOtherDiscountStatus(int actionId, int studentOtherDiscountDetailId)
		{
			return Json(new { result = await _IStudentService.UpdateOtherDiscountStatus(Convert.ToInt32(GetUserDataFromClaims("UserId")), actionId, studentOtherDiscountDetailId) });
		}
		#endregion
	}
}
