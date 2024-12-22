using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Extensions.Options;
using School.Common;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.ParentModels;
using School.Services.ALSManager;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Web.Controllers
{
	[Authorize]
    public class ParentController : BaseController
    {
        private readonly ILogger<ParentController> _logger;
        private IParentService _IParentService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _IWebHostEnvironment;
        private readonly IParentManager _iParentManager;
        private readonly IStudentManager _iStudentManager;

        public ParentController(ILogger<ParentController> logger, IOptions<AppSettingConfig> appSettingConfig, 
            IParentService iParentService,
            IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService,
            IWebHostEnvironment iWebHostEnvironment,
                 IParentManager iParentManager,
             IStudentManager iStudentManager) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IParentService = iParentService;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IWebHostEnvironment = iWebHostEnvironment;

            _iParentManager = iParentManager;
            _iStudentManager = iStudentManager;
        }
        #region Parent
        public async void InitDropdown()
        {
            ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
            ViewBag.AcademicYearStatementDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, false);
            ViewBag.CountryDropdown = await GetAppDropdown(AppDropdown.Country, true);
        }
        private async void InitCustomDropdown(int parentId)
        {
            var studentRecord = await _iStudentManager.GetStudentByParentId(Convert.ToInt64(parentId));
            List<SelectListItem> selectList = new List<SelectListItem>();
            if (studentRecord != null)
            {
                selectList = studentRecord.Select(s => new SelectListItem
                {
                    Value = s.StudentId.ToString(),
                    Text = s.StudentName.ToString()
                }).ToList();
            }
            selectList.Insert(0, new SelectListItem()
            {
                Text = "--All--",
                Value = "0"
            });
            ViewBag.StudentDropdown = selectList;
        }
        public async Task<IActionResult> ParentList()
        {
            _logger.LogInformation("Start: ParentController");
            InitDropdown();
            return View();
        }
        public async Task<IActionResult> ViewParent(int parentId)
        {
            InitDropdown();
            InitCustomDropdown(parentId);
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(parentId);
            if (!string.IsNullOrEmpty(model.ParentImage))
                model.ParentImage = model.ParentImage.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            return View(model);
        }
        public async Task<IActionResult> ParentDataPartial(ParentFilterModel model)
        {
            DataSet ds = await _IParentService.GetParents(model);

            ds.Tables[0].AsEnumerable().ToList().ForEach(row =>
            {
                if (!string.IsNullOrEmpty(Convert.ToString(row["ParentImage"])))
                    row["ParentImage"] = row.Field<string>("ParentImage").Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            });
            return PartialView("_ParentDataPartial", ds);
        }

        public async Task<IActionResult> AddEditParent(int parentId = 0)
        {
            InitDropdown();
            InitCustomDropdown(parentId);
            ParentModel model = new ParentModel();
            if (parentId > 0)
            {
                model = await _IParentService.GetParentById(parentId);
                if (!string.IsNullOrEmpty(model.ParentImage))
                    model.ParentImage = model.ParentImage.Replace(_IWebHostEnvironment.WebRootPath, _AppSettingConfig.Value.VertualDirectoryPath);
            }
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> SaveParent(IFormFile parentImage, ParentModel model)
        {
            if (model.ParentId == 0)
            {
                if (parentImage != null && parentImage.Length > 0)
                {
                    var uploadsFolder = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "parentimages");
                    if (!Directory.Exists(uploadsFolder))
                    {
                        Directory.CreateDirectory(uploadsFolder);
                    }
                    var fileName = Utility.GetUniqueFileName(parentImage.FileName);
                    var filePath = Path.Combine(uploadsFolder, fileName);
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await parentImage.CopyToAsync(stream);
                    }
                    model.ParentImage = filePath;
                }
            }
            return Json(new { result = await _IParentService.SaveParent(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }

        [HttpPost]
        public async Task<IActionResult> UploadProfilePicture(IFormCollection iFormCollection)
        {
            string imagePath = string.Empty;
            string folderPath = Path.Combine(_IWebHostEnvironment.WebRootPath, "uploads", "parentimages");
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
            return Json(new { result = await _IParentService.UpdateParentProfilePicture(Convert.ToInt32(GetUserDataFromClaims("UserId")), Convert.ToInt16(iFormCollection["ParentId"]), imagePath) });
        }
        [HttpPost]
        public async Task<IActionResult> UpdateAccount(ParentAccountModel model)
        {
            return Json(new { result = await _IParentService.UpdateAccount(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteParent(int parentId)
        {
            return Json(new { result = await _IParentService.DeleteParent(Convert.ToInt32(GetUserDataFromClaims("UserId")), parentId) });
        }

        public async Task<IActionResult> StudentFeeStatementDataPartial(int academicYearId, int parentId, int studentId)
        {
            var ds = await _IParentService.GetStudentFeeStatement(academicYearId, parentId, studentId);
            return PartialView("_StudentFeeStatementDataPartial", ds);
        }

        #endregion
    }
}
