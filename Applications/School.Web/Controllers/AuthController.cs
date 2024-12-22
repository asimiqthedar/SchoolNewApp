using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using School.Services.ALSManager;
using School.Services.WebServices.Services;
using School.Web.Helpers;
using System.Security.Claims;

namespace School.Web.Controllers
{
	public class AuthController : Controller
    {
        private readonly ILogger<AuthController> _logger;
        private IAuthService _IAuthService;
        private readonly IUserManager _iUserManager;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        IEmailHelper _emailHelper;
        public AuthController(ILogger<AuthController> logger, IOptions<AppSettingConfig> appSettingConfig, IAuthService iAuthService, IHttpContextAccessor iHttpContextAccessor, IUserManager iUserManager, IEmailHelper emailHelper)
        {
            _logger = logger;
            _IAuthService = iAuthService;
            _AppSettingConfig = appSettingConfig;
            _IHttpContextAccessor = iHttpContextAccessor;
            _iUserManager = iUserManager;
            _emailHelper = emailHelper;
        }
        public IActionResult Index(string returnUrl = null, string message = null)
        {
            _logger.LogInformation("Start: AuthController");
            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Message"] = message;
            UserModel model = new UserModel();
            if (_IHttpContextAccessor.HttpContext != null && _IHttpContextAccessor.HttpContext.User != null && _IHttpContextAccessor.HttpContext.User.Identity.IsAuthenticated)
            {
                int roleId = Convert.ToInt32(_IHttpContextAccessor.HttpContext.User.FindFirstValue("RoleId"));
                //if (!string.IsNullOrEmpty(returnUrl))
                //    return RedirectToAction(returnUrl);

                return RedirectToAction($"{Convert.ToString((AppRole)roleId)}Dashboard", "Home");
            }
            else
                return View(model);

        }
        [HttpPost]
        public async Task<IActionResult> Index(UserModel userModel, string returnUrl = null)
        {
            try
            {
                UserModel returnUserModel = await _IAuthService.Login(userModel);
                if (returnUserModel.UserId > 0)
                {
                    var claims = new List<Claim>{
                        new Claim(ClaimTypes.UserData, JsonConvert.SerializeObject(returnUserModel)),
                        new Claim(ClaimTypes.Name, Convert.ToString(returnUserModel.UserName)),
                        //new Claim("UserMenues", JsonConvert.SerializeObject(returnUserModel.UserMenueList)),
                        new Claim("UserId", Convert.ToString(returnUserModel.UserId)),
                        new Claim("UserName", Convert.ToString(returnUserModel.UserName)),
						new Claim("UserEmail", Convert.ToString(returnUserModel.UserEmail)),
						new Claim("IsApprover", Convert.ToString(returnUserModel.IsApprover)),
                        new Claim("RoleId", Convert.ToString(returnUserModel.RoleId)){},
                        new Claim(ClaimTypes.Role, Convert.ToString(returnUserModel.RoleName)),
                    };
                    var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                    var authProperties = new AuthenticationProperties
                    {
                        ExpiresUtc = DateTime.Now.AddMinutes(_AppSettingConfig.Value.SessionTime),
                    };

                    HttpContext.Session.Set<List<UserMenuModel>>("UserMenues", returnUserModel.UserMenueList);// JsonConvert.SerializeObject(returnUserModel.UserMenueList));

                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimsIdentity), authProperties);
                    return RedirectToAction($"{Convert.ToString((AppRole)returnUserModel.RoleId)}Dashboard", "Home");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Invalid login attempt.");
                    return RedirectToAction(nameof(Index), new { message = "Invalid login attempt." }); // Redirect with authentication failure message
                }
            }
            catch (Exception)
            {
                throw;
            }
            return View(userModel);
        }
        public async Task<IActionResult> Logout()
        {
            try
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                return RedirectToAction("Index", "Auth");

            }
            catch (Exception)
            {
                throw;
            }
        }

        private string GenerateOtp()
        {
            Random generator = new Random();
            return generator.Next(100000, 999999).ToString(); // Generates a 6-digit OTP
        }

        public async Task<IActionResult> SendOtp(string email)
        {
            var user = await _iUserManager.GetUserByEmail(email);
            if (user == null)
            {
                return Json(new { success = false, message = "Email not found" });
            }

            string otp = GenerateOtp();
            DateTime otpExpiration = DateTime.Now.AddMinutes(10);

            await _iUserManager.SaveOtp(user.UserId, otp, otpExpiration);

            string subject = "Your OTP Code";
            string body = $"Hello {user.UserName}, your OTP code is: {otp}. It is valid for the next 10 minutes.";

            var isEmailSent = await _emailHelper.SendEmailResetPassword(user.UserEmail, subject, body);

            if (!isEmailSent)
            {
                return Json(new { success = false, message = "Failed to send OTP. Please try again later." });
  
            }
            return Json(new { success = true, message = "OTP sent successfully." });
        }

        public async Task<IActionResult> ResetPassword(string email, string otp, string newPassword, string confirmPassword)
        {
            var user = await _iUserManager.GetUserByEmail(email);
            if (user == null)
            {
                return Json(new { success = false, message = "User not found" });
            }
            if (user.Otp == null || user.Otp != otp || user.OtpExpiration < DateTime.Now)
            {
                return Json(new { success = false, message = "Invalid or expired OTP" });
            }

            await _iUserManager.SaveNewPassword(user.UserId, newPassword);
           
            return Json(new { success = true, message = "Password reset successfully" });
        }

        [HttpGet]
        public bool HasSessionExpired()
        {
            var data=HttpContext.Session.Get("UserMenues");
            return data == null;
        }

    }
}
