using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.SchoolAcademicModels;
using School.Services.WebServices.Services;

namespace School.Web.Controllers
{
	[Authorize]
    public class AcademicYearController : BaseController
    {
        private readonly ILogger<AcademicYearController> _logger;
        private IAcademicYearService _IAcademicYearService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _IWebHostEnvironment;
        public AcademicYearController(ILogger<AcademicYearController> logger, IOptions<AppSettingConfig> appSettingConfig, IAcademicYearService iAcademicYearService, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IWebHostEnvironment iWebHostEnvironment) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IAcademicYearService = iAcademicYearService;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IWebHostEnvironment = iWebHostEnvironment;
        }
        #region Academic Year

        public IActionResult AcademicYear()
        {
            _logger.LogInformation("Start: AcademicYearController");
            return View();
        }
        public async Task<IActionResult> SchoolAcademicDataPartial()
        {
            return PartialView("_SchoolAcademicDataPartial", await _IAcademicYearService.GetSchoolAcademic(0));
        }
        public async Task<IActionResult> SchoolAcademicEditPartial(int schoolAcademicId = 0)
        {
            SchoolAcademicModel model = new SchoolAcademicModel();
            if (schoolAcademicId > 0)
                model = await _IAcademicYearService.GetSchoolAcademicById(schoolAcademicId);
            return PartialView("_SchoolAcademicEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveSchoolAcademic(SchoolAcademicModel model)
        {
            DateTime periodFromDate = GetDatetimeWithDDMMMYYYY(model.PeriodFrom);
            DateTime periodToDate = GetDatetimeWithDDMMMYYYY(model.PeriodTo);

            if (periodFromDate == DateTime.MinValue || periodToDate == DateTime.MinValue || periodFromDate > periodToDate)
            {
                return Json(new { result = -3 });
            }

            model.DebitAccount = string.IsNullOrEmpty(model.DebitAccount) ? string.Empty : model.DebitAccount.Trim();
            model.CreditAccount = string.IsNullOrEmpty(model.CreditAccount) ? string.Empty : model.CreditAccount.Trim();

            return Json(new { result = await _IAcademicYearService.SaveSchoolAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteSchoolAcademic(int schoolAcademicId)
        {
            return Json(new { result = await _IAcademicYearService.DeleteSchoolAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolAcademicId) });
        }
        #endregion
    }
}
