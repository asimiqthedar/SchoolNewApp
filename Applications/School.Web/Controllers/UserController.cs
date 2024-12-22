using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using School.Services.WebServices.Services;

namespace School.Web.Controllers
{
	[Authorize]
    public class UserController : BaseController
    {
        private readonly ILogger<UserController> _logger;
        private IUserService _IUserService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        public UserController(ILogger<UserController> logger, IOptions<AppSettingConfig> appSettingConfig, IUserService iUserService, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IUserService = iUserService;
            _IHttpContextAccessor = iHttpContextAccessor;
        }

        #region User
        public async void InitDropdown()
        {
            ViewBag.RoleDropdown = await GetAppDropdown(AppDropdown.Role, true);
        }
        public IActionResult Index()
        {
            _logger.LogInformation("Start: UserController");
            InitDropdown();
            return View();
        }
        public async Task<IActionResult> UserDataPartial(UserFilterModel model)
        {
            return PartialView("_UserDataPartial", await _IUserService.GetUsers(model));
        }
        public async Task<IActionResult> UserEditPartial(int userId = 0)
        {
            InitDropdown();
            UserModel model = new UserModel();
            if (userId > 0)
                model = await _IUserService.GetUserById(userId);
            return PartialView("_UserEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveUser(UserModel model)
        {
            return Json(new { result = await _IUserService.SaveUser(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteUser(int userId)
        {
            return Json(new { result = await _IUserService.DeleteUser(Convert.ToInt32(GetUserDataFromClaims("UserId")), userId) });
        }
        [HttpPost]
        public async Task<IActionResult> UploadUserImage()
        {
            try
            {
                var filePath = string.Empty;
                var imageFile = Request.Form.Files["image"];
                int userId = Convert.ToInt32(Request.Form["UserId"]);
                if (imageFile != null && imageFile.Length > 0)
                {
                    var fileName = $"user_{userId}{Path.GetExtension(imageFile.FileName)}";
                    var dir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "userimages");
                    filePath = Path.Combine(dir, fileName);
                    if (!Directory.Exists(dir))
                    {
                        Directory.CreateDirectory(dir);
                    }
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        imageFile.CopyTo(stream);
                    }
                }
                if (!string.IsNullOrEmpty(filePath))
                {
                    var replaceVal = $"{Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")}";
                    var savingPath = filePath.Replace(replaceVal, "~").Replace('\\', '/');
                    return Json(new { result = await _IUserService.SaveUserImage(Convert.ToInt32(GetUserDataFromClaims("UserId")), userId, savingPath) });
                }
                else
                {
                    return Json(new { result = -3 });
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }

        }
        public async Task<IActionResult> UploadUserImagePartial(int userId)
        {
            return PartialView("_UploadUserImagePartial", userId);
        }
        #endregion       
    }
}
