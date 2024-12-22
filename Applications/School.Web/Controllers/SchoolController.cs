using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.BranchModels;
using School.Models.WebModels.ContactInformationModels;
using School.Models.WebModels.SchoolAccountInfoModels;
using School.Models.WebModels.SchoolModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Web.Controllers
{
	[Authorize]
    public class SchoolController : BaseController
    {
        private readonly ILogger<SetupController> _logger;
        private ISchoolService _ISchoolService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _IWebHostEnvironment;
        public SchoolController(ILogger<SetupController> logger, IOptions<AppSettingConfig> appSettingConfig, ISchoolService iSchoolService, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IWebHostEnvironment iWebHostEnvironment) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _ISchoolService = iSchoolService;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IWebHostEnvironment = iWebHostEnvironment;
        }

        #region School   
        public async void InitBranchDropdown()
        {
            ViewBag.BranchDropdown = await GetAppDropdown(AppDropdown.Branch, true);
            ViewBag.CountryDropdown = await GetAppDropdown(AppDropdown.Country, true);
            ViewBag.AcadmicYearDropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
            ViewBag.FeeTypeDropdown = await GetAppDropdown(AppDropdown.FeeType, true);
            ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);
        }
        public async Task<IActionResult> School()
        {
            _logger.LogInformation("Start: SchoolController");
            int schoolId = 0;
            DataSet ds = await _ISchoolService.GetSchool(new SchoolFilterModel());

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                schoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
            return RedirectToActionPermanent("AddEditSchool", new { schoolId = schoolId });
            //return View();
        }
        public async Task<IActionResult> AddEditSchool(int schoolId = 0)
        {

            InitBranchDropdown();
            SchoolModel model = new SchoolModel();
            if (schoolId > 0)
            {
                model = await _ISchoolService.GetSchoolById(schoolId);
                if (!string.IsNullOrEmpty(model.Logo))
                    model.Logo = model.Logo.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            }
            return View(model);
        }
        public async Task<IActionResult> SchoolDataPartial(SchoolFilterModel model)
        {
            DataSet ds = await _ISchoolService.GetSchool(model);

            ds.Tables[0].AsEnumerable().ToList().ForEach(row =>
            {
                if (!string.IsNullOrEmpty(Convert.ToString(row["Logo"])))
                    row["Logo"] = row.Field<string>("Logo").Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            });
            return PartialView("_SchoolDataPartial", ds);
        }
        [HttpPost]
        public async Task<IActionResult> SaveSchool(SchoolModel model)//IFormFile logoImage, 
        {
            //if (model.SchoolId == 0)
            //{
            //    if (logoImage != null && logoImage.Length > 0)
            //    {
            //        var uploadsFolder = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "schoolimages");
            //        if (!Directory.Exists(uploadsFolder))
            //        {
            //            Directory.CreateDirectory(uploadsFolder);
            //        }
            //        var fileName = Utility.GetUniqueFileName(logoImage.FileName);
            //        var filePath = Path.Combine(uploadsFolder, fileName);
            //        using (var stream = new FileStream(filePath, FileMode.Create))
            //        {
            //            await logoImage.CopyToAsync(stream);
            //        }
            //        model.Logo = filePath;
            //    }
            //}
            model.Logo = "";
            return Json(new { result = await _ISchoolService.SaveSchool(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteSchool(int schoolId)
        {
            return Json(new { result = await _ISchoolService.DeleteSchool(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolId) });
        }

        #endregion

        #region Branch    
        public async void InitCountryDropdown()
        {
            ViewBag.CountryDropdown = await GetAppDropdown(AppDropdown.Country, true);
        }
        public IActionResult Branch()
        {
            InitCountryDropdown();
            return View();
        }
        public async Task<IActionResult> BranchDataPartial(BranchFilterModel model)
        {
            return PartialView("_BranchDataPartial", await _ISchoolService.GetBranch(model));
        }
        public async Task<IActionResult> BranchEditPartial(int branchId = 0)
        {
            InitCountryDropdown();
            BranchModel model = new BranchModel();
            if (branchId > 0)
                model = await _ISchoolService.GetBranchById(branchId);
            return PartialView("_BranchEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveBranch(BranchModel model)
        {
            return Json(new { result = await _ISchoolService.SaveBranch(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteBranch(int branchId)
        {
            return Json(new { result = await _ISchoolService.DeleteBranch(Convert.ToInt32(GetUserDataFromClaims("UserId")), branchId) });
        }
        #endregion

        #region Contact Information 
        public async Task<IActionResult> ContactInformationDataPartial(int schoolId, ContactInformationFilterModel model)
        {
            return PartialView("_ContactInformationDataPartial", await _ISchoolService.GetContactInformation(schoolId, model));
        }
        public async Task<IActionResult> ContactInformationEditPartial(int schoolId, int contactId = 0)
        {
            ContactInformationModel model = new ContactInformationModel();
            if (contactId > 0)
                model = await _ISchoolService.GetContactInformationById(schoolId, contactId);
            return PartialView("_ContactInformationEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveContactInformation(ContactInformationModel model)
        {
            return Json(new { result = await _ISchoolService.SaveContactInformation(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteContactInformation(int contactId)
        {
            return Json(new { result = await _ISchoolService.DeleteContactInformation(Convert.ToInt32(GetUserDataFromClaims("UserId")), contactId) });
        }
        #endregion

        //#region Academic Year
        //public async Task<IActionResult> SchoolAcademicDataPartial(int schoolId)
        //{
        //    return PartialView("_SchoolAcademicDataPartial", await _ISchoolService.GetSchoolAcademic(schoolId));
        //}
        //public async Task<IActionResult> SchoolAcademicEditPartial( int schoolAcademicId = 0)
        //{
        //    SchoolAcademicModel model = new SchoolAcademicModel();
        //    if (schoolAcademicId > 0)
        //        model = await _ISchoolService.GetSchoolAcademicById(schoolAcademicId);
        //    return PartialView("_SchoolAcademicEditPartial", model);
        //}
        //[HttpPost]
        //public async Task<IActionResult> SaveSchoolAcademic(SchoolAcademicModel model)
        //{
        //    return Json(new { result = await _ISchoolService.SaveSchoolAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        //}
        //public async Task<IActionResult> DeleteSchoolAcademic(int schoolAcademicId)
        //{
        //    return Json(new { result = await _ISchoolService.DeleteSchoolAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolAcademicId) });
        //}
        //#endregion

        //#region Academic Term
        //public async void InitTermAcademicDropdown(int schoolId)
        //{
        //    ViewBag.TermDropdown = await GetAppDropdown(AppDropdown.Term, true);
        //    ViewBag.AcadmicYearDropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true, schoolId);
        //}
        //public async Task<IActionResult> SchoolTermAcademicDataPartial(int schoolId)
        //{
        //    return PartialView("_SchoolTermAcademicDataPartial", await _ISchoolService.GetSchoolTermAcademic(schoolId));
        //}
        //public async Task<IActionResult> SchoolTermAcademicEditPartial(int schoolId, int schoolTermAcademicId = 0)
        //{
        //    InitTermAcademicDropdown(schoolId);
        //    SchoolTermAcademicModel model = new SchoolTermAcademicModel();
        //    if (schoolTermAcademicId > 0)
        //        model = await _ISchoolService.GetSchoolTermAcademicById(schoolId, schoolTermAcademicId);
        //    return PartialView("_SchoolTermAcademicEditPartial", model);
        //}
        //[HttpPost]
        //public async Task<IActionResult> SaveSchoolTermAcademic(SchoolTermAcademicModel model)
        //{
        //    return Json(new { result = await _ISchoolService.SaveSchoolTermAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        //}
        //public async Task<IActionResult> DeleteSchoolTermAcademic(int schoolTermAcademicId)
        //{
        //    return Json(new { result = await _ISchoolService.DeleteSchoolTermAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolTermAcademicId) });
        //}
        //#endregion

        #region Logo
        public async Task<IActionResult> LogoDataPartial(int schoolId)
        {
            DataSet ds = await _ISchoolService.GetSchoolLogo(schoolId);

            ds.Tables[0].AsEnumerable().ToList().ForEach(row =>
            {
                if (!string.IsNullOrEmpty(Convert.ToString(row["LogoPath"])))
                    row["LogoPath"] = row.Field<string>("LogoPath").Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            });
            return PartialView("_LogoDataPartial", ds);
        }
        [HttpPost]
        public async Task<IActionResult> UploadLogoPicture(IFormCollection iFormCollection)
        {
            string imagePath = string.Empty;
            string folderPath = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "schoolimages");
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
            return Json(new { result = await _ISchoolService.UpdateLogoPicture(Convert.ToInt32(GetUserDataFromClaims("UserId")), Convert.ToInt16(iFormCollection["SchoolId"]), imagePath, iFormCollection["LogoName"]) });
        }
        public async Task<IActionResult> DeleteSchoolLogo(int schoolLogoId)
        {
            return Json(new { result = await _ISchoolService.DeleteSchoolLogo(schoolLogoId) });
        }
        #endregion

        #region School Account Info
        public async Task<IActionResult> SchoolAccountInfoDataPartial(int schoolId)
        {
            return PartialView("_SchoolAccountInfoDataPartial", await _ISchoolService.GetSchoolAccountInfo(schoolId));
        }
        public async Task<IActionResult> SchoolAccountInfoEditPartial(int schoolId, int schoolAccountIId = 0)
        {
            SchoolAccountInfoModel model = new SchoolAccountInfoModel();
            if (schoolAccountIId > 0)
                model = await _ISchoolService.GetSchoolAccountInfoById(schoolId, schoolAccountIId);
            return PartialView("_SchoolAccountInfoEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveSchoolAccountInfo(SchoolAccountInfoModel model)
        {
            return Json(new { result = await _ISchoolService.SaveSchoolAccountInfo(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteSchoolAccountInfo(int schoolAccountIId)
        {
            return Json(new { result = await _ISchoolService.DeleteSchoolAccountInfo(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolAccountIId) });
        }
        #endregion

        #region Fee Generate
        public async Task<IActionResult> GenerateFeeDataPartial()
        {
            return PartialView("_GenerateFeeDataPartial", await _ISchoolService.GetGenerateFee());
        }
        [HttpPost]
        public async Task<IActionResult> SaveGenerateFee(GenerateFeeModel model)
        {
            return Json(new { result = await _ISchoolService.SaveGenerateFee(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }

        public async Task<IActionResult> UpdateGenerateFee(int feeGenerateId, int actionId)
        {
            return Json(new { result = await _ISchoolService.UpdateGenerateFee(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeGenerateId, actionId) });
        }
        public async Task<IActionResult> FeeGeneratedStudentPartial(int feeGenerateId)
        {
            return PartialView("_FeeGeneratedStudentPartial", await _ISchoolService.GetGenerateFeeById(feeGenerateId));
        }
        #endregion

        #region Sibling Discount Generate
        public async Task<IActionResult> GenerateSiblingDiscountDataPartial()
        {
            return PartialView("_GenerateSiblingDiscountDataPartial", await _ISchoolService.GetGenerateSiblingDiscount());
        }
        [HttpPost]
        public async Task<IActionResult> SaveGenerateSiblingDiscount(GenerateSiblingDiscountModel model)
        {
            return Json(new { result = await _ISchoolService.SaveGenerateSiblingDiscount(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> UpdateGenerateSiblingDiscount(int siblingDiscountId, int actionId)
        {
            return Json(new { result = await _ISchoolService.UpdateGenerateSiblingDiscount(Convert.ToInt32(GetUserDataFromClaims("UserId")), siblingDiscountId, actionId) });
        }
        public async Task<IActionResult> SiblingDiscountGeneratedStudentPartial(int siblingDiscountId)
        {
            return PartialView("_SiblingDiscountGeneratedStudentPartial", await _ISchoolService.GetGenerateSiblingDiscountById(siblingDiscountId));
        }
        #endregion
        public async Task<IActionResult> GetSiblingDiscountStudent(int academicYearId)
        {
            return PartialView("_SiblingDiscountDetailDataPartial", await _ISchoolService.GetSiblingDiscountDetail(academicYearId));
        }
        [HttpPost]
        public async Task<IActionResult> CancleMultiSiblingDiscount(string studentSiblingDiscountDetailIds)
        {
            try
            {
                return Json(new { result = await _ISchoolService.CancleMultiSiblingDiscount(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentSiblingDiscountDetailIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
    }
}
