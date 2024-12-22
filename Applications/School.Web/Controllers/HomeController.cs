using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.NotificationModels;
using School.Models.WebModels.ParentModels;
using School.Services.ALSManager;
using School.Services.Entities;
using School.Services.WebServices.Services;
using School.Web.Models;
using System.Data;
using System.Diagnostics;
using System.Security.Claims;
using System.Xml.Linq;

namespace School.Web.Controllers
{
	[Authorize]
    public class HomeController : BaseController
    {
        private readonly ILogger<HomeController> _logger;
        private IHomeService _IHomeService;
        private ICommonService _ICommonService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private readonly IWebHostEnvironment _hostingEnvironment;

        private readonly IInvoiceService _IInvoiceService;
        private readonly IInvInvoiceDetailManager _iInvInvoiceDetailManager;
        private readonly IParentManager _iParentManager;

        private IParentService _IParentService;
        private IStudentService _IStudentService;
        private readonly IStudentManager _iStudentManager;
        private readonly IMapper _mapper;

        public HomeController(ILogger<HomeController> logger,
                IOptions<AppSettingConfig> appSettingConfig,
                IHttpContextAccessor iHttpContextAccessor,
                IDropdownService iDropdownService,
                IHomeService iHomeService,
                ICommonService iCommonService,
                IWebHostEnvironment hostingEnvironment,
                IInvoiceService iInvoiceService,
                IInvInvoiceDetailManager iInvInvoiceDetailManager,
                IMapper mapper,
                IParentService iParentService,
                IStudentService iStudentService,
                IParentManager iParentManager,
                IStudentManager iStudentManager
           ) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IHomeService = iHomeService;
            _IHttpContextAccessor = iHttpContextAccessor;
            _ICommonService = iCommonService;
            _hostingEnvironment = hostingEnvironment;
            _IInvoiceService = iInvoiceService;
            _iInvInvoiceDetailManager = iInvInvoiceDetailManager;
            _mapper = mapper;
            _iParentManager = iParentManager;
            _IParentService = iParentService;
            _IStudentService = iStudentService;
            _iStudentManager = iStudentManager;
        }
        public IActionResult Index()
        {
            _logger.LogInformation("Start: HomeController");
            if (_IHttpContextAccessor.HttpContext != null && _IHttpContextAccessor.HttpContext.User != null
                && _IHttpContextAccessor.HttpContext.User.Identity.IsAuthenticated
                && _IHttpContextAccessor.HttpContext.Session != null
                && _IHttpContextAccessor.HttpContext.Session.Keys.Any(s => s.Equals("UserMenues")))
            {
                int roleId = Convert.ToInt32(_IHttpContextAccessor.HttpContext.User.FindFirstValue("RoleId"));
                return RedirectToAction($"{Convert.ToString((AppRole)roleId)}Dashboard", "Home");
            }
            else return RedirectToAction("Logout", "Auth");
        }
        public async Task<IActionResult> AdminDashboard()
        {
            if (_IHttpContextAccessor.HttpContext.Session == null
               || !_IHttpContextAccessor.HttpContext.Session.Keys.Any(s => s.Equals("UserMenues")))
            {
                return RedirectToAction("Logout", "Auth");
            }
            var ds = await _IHomeService.GetDashboardAdminDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")));
            return View(ds);
        }
        public async Task<IActionResult> GetInvoiceDataYearly()
        {
            var ds = await _IHomeService.GetInvoiceDataYearly();
            return Json(ds.InvoiceWiseData);
        }
        public async Task<IActionResult> GetCostRevenue()
        {
            var ds = await _IHomeService.GetCostCenterRevenue();
            return Json(ds.CostRevenueData);
        }
        public async Task<IActionResult> GetGradeRevenue()
        {
            var ds = await _IHomeService.GetGradeRevenue();
            return Json(ds.GradeRevenueData);
        }
        public async Task<IActionResult> StudentDashboard()
        {
            if (_IHttpContextAccessor.HttpContext.Session == null
              || !_IHttpContextAccessor.HttpContext.Session.Keys.Any(s => s.Equals("UserMenues")))
            {
                return RedirectToAction("Logout", "Auth");
            }
            var ds = await _IHomeService.GetDashboardAdminDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")));
            return View(ds);
        }
        public async Task<IActionResult> ParentDashboard()
        {
            if (_IHttpContextAccessor.HttpContext.Session == null
              || !_IHttpContextAccessor.HttpContext.Session.Keys.Any(s => s.Equals("UserMenues")))
            {
                return RedirectToAction("Logout", "Auth");
            }
            var ds = await _IHomeService.GetDashboardAdminDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")));
            return View(ds);
        }
        public async Task<IActionResult> TeacherDashboard()
        {
            if (_IHttpContextAccessor.HttpContext.Session == null
              || !_IHttpContextAccessor.HttpContext.Session.Keys.Any(s => s.Equals("UserMenues")))
            {
                return RedirectToAction("Logout", "Auth");
            }
            var ds = await _IHomeService.GetDashboardAdminDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")));
            return View(ds);
        }
        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        #region Notification Openapply data process
        public IActionResult GetNotification()
        {
            return PartialView("_NotificationPartial");
        }
        public async Task<IActionResult> GetNotificationInfo()
        {
            var ds = await _ICommonService.GetNotificationList(Convert.ToInt32(GetUserDataFromClaims("UserId")));

            //List<NotificationApproval> notificationApprovals = new List<NotificationApproval>();
            //foreach (DataRow dr in ds.Tables[0].Rows)
            //{
            //    notificationApprovals.Add(new NotificationApproval
            //    {
            //        NotificationId = Convert.ToInt64(dr["NotificationId"]),
            //        RecordId = Convert.ToString(dr["RecordId"]),
            //        RecordStatus = Convert.ToInt32(dr["RecordStatus"]),
            //        RecordType = Convert.ToInt32(dr["RecordType"])
            //    });
            //}
            NotificationInformation notificationInformation = new NotificationInformation();
            notificationInformation.NotificationCount = ds.Tables[0].Rows.Count;
            return PartialView("_NotificationInfo", notificationInformation);
        }


        #endregion Ntfication Openapply data process

        #region Notification Group
        public async Task<IActionResult> GetNotificationGroup()
        {
            return PartialView("_NotificationGroupPartial", await _IHomeService.GetNotificationGroup(Convert.ToInt32(GetUserDataFromClaims("UserId"))));
        }
        public async Task<IActionResult> GetNotificationGroupDetail(int NotificationGroupId, int NotificationTypeId)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            return View("NotificationGroupDetail");
        }
        public async Task<IActionResult> GetNotificationGroupDetailPartial(int NotificationGroupId, int NotificationTypeId)
        {
            return PartialView("_NotificationGroupDetailPartial", await _IHomeService.GetNotificationGroupDetail(NotificationGroupId, NotificationTypeId));
        }
        public async Task<IActionResult> RejectNotification(int notificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.RejectNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationGroupDetailId) });
        }
        public async Task<IActionResult> ApproveNotification(int notificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.ApproveNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationGroupDetailId) });
        }

        public async Task<IActionResult> NotificationPartial()
        {
            //DataSet ds = await _IStudentService.GetStudents(model);
            var ds = await _ICommonService.GetNotificationList(Convert.ToInt32(GetUserDataFromClaims("UserId")));

            return PartialView("_NotificationPartial", ds);
        }

        [HttpPost]
        public async Task<IActionResult> ApproveMultiNotification(string notificationIds, int NotificationGroupId = 0, int NotificationTypeId = 0)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveNotifications(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds, NotificationGroupId, NotificationTypeId) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        public async Task<IActionResult> ViewJsonPartial(long notificationGroupDetailId)
        {
            string xmlFilePath = Path.Combine(_hostingEnvironment.WebRootPath, "Configurations", "JsonReplaceKeys.xml");

            XElement xmlData = XElement.Load(xmlFilePath);
            ViewBag.XmlData = xmlData;
            DataSet ds = await _IHomeService.GetNotificationGroupDetailById(notificationGroupDetailId);
            return PartialView("_ViewJsonPartial", ds);
        }

        #region Fee Notification
        public async Task<IActionResult> NotificationGenerateFee(int NotificationGroupId, int NotificationTypeId)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            return View("NotificationGenerateFee");
        }
        public async Task<IActionResult> GetNotificationGenerateFeePartial()
        {
            return PartialView("_NotificationGenerateFeePartial", await _IHomeService.GetNotificationGenerateFee());
        }
        public async Task<IActionResult> RejectGenerateFeeNotification(int feeGenerateId)
        {
            return Json(new { result = await _IHomeService.RejectGenerateFeeNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeGenerateId) });
        }
        public async Task<IActionResult> ApproveGenerateFeeNotification(int feeGenerateId)
        {
            return Json(new { result = await _IHomeService.ApproveGenerateFeeNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeGenerateId) });
        }
        [HttpPost]
        public async Task<IActionResult> ApproveMultiGenerateFeeNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiGenerateFeeNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        public async Task<IActionResult> FeeGeneratedStudentPartial(int feeGenerateId)
        {
            return PartialView("_FeeGeneratedStudentPartial", await _IHomeService.GetGenerateFeeById(feeGenerateId));
        }
        #endregion

        #region Sibling Discount Notification
        public async Task<IActionResult> NotificationGenerateSiblingDiscount(int NotificationGroupId, int NotificationTypeId)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            return View("NotificationGenerateSiblingDiscount");
        }
        public async Task<IActionResult> GetNotificationGenerateSiblingDiscountPartial()
        {
            return PartialView("_NotificationGenerateSiblingDiscountPartial", await _IHomeService.GetNotificationGenerateSiblingDiscount());
        }
        public async Task<IActionResult> RejectGenerateSiblingDiscountNotification(int siblingDiscountId)
        {
            return Json(new { result = await _IHomeService.RejectGenerateSiblingDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), siblingDiscountId) });
        }
        public async Task<IActionResult> ApproveGenerateSiblingDiscountNotification(int siblingDiscountId)
        {
            return Json(new { result = await _IHomeService.ApproveGenerateSiblingDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), siblingDiscountId) });
        }
        [HttpPost]
        public async Task<IActionResult> ApproveMultiGenerateSiblingDiscountNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiGenerateSiblingDiscountNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        public async Task<IActionResult> SiblingDiscountGeneratedStudentPartial(int siblingDiscountId)
        {
            return PartialView("_SiblingDiscountGeneratedStudentPartial", await _IHomeService.GetGenerateSiblingDiscountById(siblingDiscountId));
        }
        #endregion

        #region Other Discount Notification
        public async Task<IActionResult> NotificationOtherDiscount(int NotificationGroupId, int NotificationTypeId)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            return View("NotificationOtherDiscount");
        }
        public async Task<IActionResult> GetNotificationOtherDiscountPartial()
        {
            return PartialView("_NotificationOtherDiscountPartial", await _IHomeService.GetNotificationOtherDiscount());
        }
        public async Task<IActionResult> RejectOtherDiscountNotification(int studentOtherDiscountDetailId)
        {
            return Json(new { result = await _IHomeService.RejectOtherDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentOtherDiscountDetailId) });
        }
        public async Task<IActionResult> ApproveOtherDiscountNotification(int studentOtherDiscountDetailId)
        {
            return Json(new { result = await _IHomeService.ApproveOtherDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentOtherDiscountDetailId) });
        }
        [HttpPost]
        public async Task<IActionResult> ApproveMultiOtherDiscountNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiOtherDiscountNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        #endregion

        #region Sibling Discount Indivisual
        public async Task<IActionResult> NotificationSiblingDiscount(int NotificationGroupId, int NotificationTypeId)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            return View("NotificationSiblingDiscount");
        }
        public async Task<IActionResult> GetNotificationSiblingDiscountPartial()
        {
            return PartialView("_NotificationSiblingDiscountPartial", await _IHomeService.GetNotificationSiblingDiscount());
        }
        public async Task<IActionResult> RejectSiblingDiscountNotification(int studentSiblingDiscountDetailId)
        {
            return Json(new { result = await _IHomeService.RejectSiblingDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentSiblingDiscountDetailId) });
        }
        public async Task<IActionResult> ApproveSiblingDiscountNotification(int studentSiblingDiscountDetailId)
        {
            return Json(new { result = await _IHomeService.ApproveSiblingDiscountNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentSiblingDiscountDetailId) });
        }
        [HttpPost]
        public async Task<IActionResult> ApproveMultiSiblingDiscountNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiSiblingDiscountNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        #endregion
        #endregion

        #region ParenDashboard

        public async Task<IActionResult> ParentDashboardTotalAndMonthlyChartPartial()
        {
            var parent = await GetParentInfo();
            var ds = await _IHomeService.GetParentFeeInfo(parent.ParentId);
            return PartialView("_ParentDashboardTotalAndMonthlyChart", ds);
        }
        public async Task<IActionResult> ParentDashboardChartsPartial()
        {
            var parent = await GetParentInfo();
            var ds = await _IHomeService.GetParentFeeInfo(parent.ParentId);
            return PartialView("_ParentDashboardCharts", ds);
        }


        public async Task<IActionResult> GetTotalParentFeeInfo()
        {
            var parent = await GetParentInfo();
            var ds = await _IHomeService.GetTotalParentFeeInfo(392);
            return Json(ds);
        }

        public async Task<IActionResult> GetParentYearwiseFeeInfo()
        {
            var parent = await GetParentInfo();
            var ds = await _IHomeService.GetParentYearwiseFeeInfo(parent.ParentId);
            return Json(ds.ParentYearwiseFeeInfo);
        }

        public async Task<IActionResult> GetParentMonthwiseFeeInfo()
        {
            var parent = await GetParentInfo();
            var ds = await _IHomeService.GetParentMonthwiseFeeInfo(parent.ParentId);
            return Json(ds.ParentMonthwiseFeeInfo);
        }

        public async Task<IActionResult> ParentDashboardStudentInfoPartial()
        {
            var parent = await GetParentInfo();
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(Convert.ToInt32(parent.ParentId));
            return PartialView("_ParentDashboardStudentInfo", model);
        }

        public IActionResult ParentDashboarStudentInfo()
        {
            _logger.LogInformation("Start: HomeController");
            return View();
        }
        public async Task<IActionResult> ParentStudentDashboardStudentDataPartial()
        {
            var parent = await GetParentInfo();
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(Convert.ToInt32(parent.ParentId));
            return PartialView("_ParentStudentDashboardStudentDataPartial", model);
        }
        public async Task<IActionResult> ParentDashboardFatherInfoPartial()
        {
            var parent = await GetParentInfo();
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(Convert.ToInt32(parent.ParentId));

            return PartialView("_ParentDashboardFatherInfo", model);
        }
        public async Task<IActionResult> ParentDashboardMotherInfoPartial(int academicYearId, int parentId, int studentId)
        {
            var parent = await GetParentInfo();
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(Convert.ToInt32(parent.ParentId));
            return PartialView("_ParentDashboardMotherInfo", model);
        }

        public IActionResult ParentDashboardParentInfo()
        {
            _logger.LogInformation("Start: HomeController");
            return View();
        }

        public async Task<IActionResult> ParentDashboardParentInfoDataPartial()
        {
            var parent = await GetParentInfo();
            ParentModel model = new ParentModel();
            model = await _IParentService.GetParentById(Convert.ToInt32(parent.ParentId));
            return PartialView("_ParentDashboardParentInfoDataPartial", model);
        }
        public async Task<IActionResult> ParentDashboardNotificationsPartial(int academicYearId, int parentId, int studentId)
        {
            //var ds = await _IParentService.GetStudentFeeStatement(academicYearId, parentId, studentId);
            return PartialView("_ParentDashboardNotifications");
        }
        public async Task<IActionResult> ParentDashboardFeeDetailsPartial(int academicYearId, int parentId, int studentId)
        {
            //var ds = await _IParentService.GetStudentFeeStatement(academicYearId, parentId, studentId);
            return PartialView("_ParentDashboardFeeDetails");
        }

        public IActionResult ParentDashboardInvoiceDetail()
        {
            _logger.LogInformation("Start: HomeController");
            return View();
        }
        public async Task<IActionResult> ParentDashboardInvoiceDetailsPartial(int academicYearId, int parentId, int studentId)
        {
            var parent = await GetParentInfo();
            var invoiceDetails = await _iInvInvoiceDetailManager.GetAllByParentCode(parent.ParentCode);
            var detailList = _mapper.Map<List<InvInvoiceDetailModel>>(invoiceDetails);
            return PartialView("_ParentDashboardInvoiceDetails", detailList);
        }

        private async Task<TblParent> GetParentInfo()
        {
            var UserEmail = GetUserDataFromClaims("UserEmail");
            TblParent tblParent = new TblParent();

            var parentInfo = await _iParentManager.GetByEmail(UserEmail);
            if (parentInfo != null)
            {
                tblParent = parentInfo;
            }

            return tblParent;
        }

        public IActionResult ParentDashboardFeeStatement()
        {
            _logger.LogInformation("Start: HomeController");
            return View();
        }

        public async Task<IActionResult> ParentDashboardFeeStatementDataPartial()
        {
            var parent = await GetParentInfo();
            var invoiceDetails = await _IParentService.GetStudentFeeStatement(0, Convert.ToInt32(parent.ParentId), 0);

            return PartialView("_ParentDashboardFeeStatementDataPartial", invoiceDetails);
        }


        #endregion

        #region OpenApply Student Notification
        public async Task<IActionResult> NotificationOpenApplyStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId = 0)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            ViewBag.NotificationGroupDetailId = NotificationGroupDetailId;
            return View("NotificationOpenApplyStudent");
        }
        public async Task<IActionResult> GetNotificationOpenApplyStudentPartial(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
        {
            return PartialView("_NotificationOpenApplyStudentPartial", await _IHomeService.GetNotificationOpenApplyStudent(NotificationTypeId, NotificationGroupId, NotificationGroupDetailId));
        }
		public async Task<IActionResult> ApproveOtherOpenApplyStudentNotification(int NotificationGroupDetailId)
		{
			return Json(new { result = await _IHomeService.ApproveOpenApplyStudentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
		}
		public async Task<IActionResult> RejectOtherOpenApplyStudentNotification(int NotificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.RejectOpenApplyStudentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
        }      
        [HttpPost]
        public async Task<IActionResult> ApproveMultiOpenApplyStudentNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiOpenApplyStudentNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        #endregion

        #region OpenApply Parent Notification
        public async Task<IActionResult> NotificationOpenApplyParent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId = 0)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            ViewBag.NotificationGroupDetailId = NotificationGroupDetailId;
            return View("NotificationOpenApplyParent");
        }
        public async Task<IActionResult> GetNotificationOpenApplyParentPartial(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
        {
            return PartialView("_NotificationOpenApplyParentPartial", await _IHomeService.GetNotificationOpenApplyParent(NotificationTypeId, NotificationGroupId, NotificationGroupDetailId));
        }
        public async Task<IActionResult> ApproveOtherOpenApplyParentNotification(int NotificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.ApproveOpenApplyParentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
        }
        public async Task<IActionResult> RejectOtherOpenApplyParentNotification(int NotificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.RejectOpenApplyParentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
        }

        [HttpPost]
        public async Task<IActionResult> ApproveMultiOpenApplyParentNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiOpenApplyParentNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        #endregion

        #region withdraw student
        public async Task<IActionResult> NotificationWithdrawStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId = 0)
        {
            ViewBag.NotificationGroupId = NotificationGroupId;
            ViewBag.NotificationTypeId = NotificationTypeId;
            ViewBag.NotificationGroupDetailId = NotificationGroupDetailId;
            return View("NotificationWithdrawStudent");
        }
        public async Task<IActionResult> GetNotificationWithdrawStudentPartial(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
        {
            return PartialView("_NotificationWithdrawStudentPartial", await _IHomeService.GetNotificationWithdrawStudent(NotificationTypeId, NotificationGroupId, NotificationGroupDetailId));
        }

        public async Task<IActionResult> ApproveOtherWithdrawStudentNotification(int NotificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.ApproveWithdrawStudentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
        }
        public async Task<IActionResult> RejectOtherWithdrawStudentNotification(int NotificationGroupDetailId)
        {
            return Json(new { result = await _IHomeService.RejectWithdrawStudentNotificationById(Convert.ToInt32(GetUserDataFromClaims("UserId")), NotificationGroupDetailId) });
        }
        [HttpPost]
        public async Task<IActionResult> ApproveMultiWithdrawStudentNotification(string notificationIds)
        {
            try
            {
                return Json(new { result = await _IHomeService.ApproveMultiWithdrawStudentNotification(Convert.ToInt32(GetUserDataFromClaims("UserId")), notificationIds) });
            }
            catch
            {
                return Json(new { isSuccess = false, result = 0 });
            }
        }
        #endregion
    }
}
