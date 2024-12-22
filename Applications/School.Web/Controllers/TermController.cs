using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.SchoolTermAcademicModels;
using School.Services.WebServices.Services;

namespace School.Web.Controllers
{
	[Authorize]
    public class TermController : BaseController
    {
        private readonly ILogger<TermController> _logger;
        private IAcademicTermService _IAcademicTermService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _IWebHostEnvironment;
        public TermController(ILogger<TermController> logger, IOptions<AppSettingConfig> appSettingConfig, IAcademicTermService iAcademicTermService, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IWebHostEnvironment iWebHostEnvironment) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IAcademicTermService = iAcademicTermService;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IWebHostEnvironment = iWebHostEnvironment;
        }
        #region Academic Term
        public async void InitTermAcademicDropdown()
        {
            //ViewBag.TermDropdown = await GetAppDropdown(AppDropdown.Term, true);
            ViewBag.AcadmicYearDropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
        }

        public IActionResult Term()
        {
            _logger.LogInformation("Start: TermController");
            InitTermAcademicDropdown();
            return View();
        }
        public async Task<IActionResult> TermAcademicDataPartial(int academicTermId)
        {
            return PartialView("_TermAcademicDataPartial", await _IAcademicTermService.GetTermAcademic(academicTermId));
        }
        public async Task<IActionResult> TermAcademicEditPartial( int schoolTermAcademicId = 0)
        {
            InitTermAcademicDropdown();
            SchoolTermAcademicModel model = new SchoolTermAcademicModel();
            if (schoolTermAcademicId > 0)
                model = await _IAcademicTermService.GetTermAcademicById(schoolTermAcademicId);
            return PartialView("_TermAcademicEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveTermAcademic(SchoolTermAcademicModel model)
        {
            if (Convert.ToDateTime(model.StartDate) > Convert.ToDateTime(model.EndDate))
            {
                return Json(new { result = -3 });
            }
            return Json(new { result = await _IAcademicTermService.SaveTermAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteTermAcademic(int schoolTermAcademicId)
        {
            return Json(new { result = await _IAcademicTermService.DeleteTermAcademic(Convert.ToInt32(GetUserDataFromClaims("UserId")), schoolTermAcademicId) });
        }
        #endregion
    }
}
