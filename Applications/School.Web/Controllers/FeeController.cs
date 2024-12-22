using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.FeeModels;
using School.Models.WebModels.FeetypeModels;
using School.Models.WebModels.PaymentPlanModels;
using School.Services.WebServices.Services;
using System.Data;
using System.Text.Json;


namespace School.Web.Controllers
{
	[Authorize]
    public class FeeController : BaseController
    {
        private readonly ILogger<FeeController> _logger;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        private IFeeService _IFeeService;
        public FeeController(ILogger<FeeController> logger, IOptions<AppSettingConfig> appSettingConfig,
            IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IFeeService iFeeService
            ) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _IHttpContextAccessor = iHttpContextAccessor;
            _IFeeService = iFeeService;
        }

        #region Fee Type    
        public IActionResult FeeType()
        {
            _logger.LogInformation("Start: FeeController");
            return View();
        }
        public async Task<IActionResult> FeeTypeDataPartial()
        {
            return PartialView("_FeeTypeDataPartial", await _IFeeService.GetFeeType());
        }
        public async Task<IActionResult> FeeTypeEditPartial(long feeTypeId = 0)
        {
            FeeTypeModel model = new FeeTypeModel();
            if (feeTypeId > 0)
                model = await _IFeeService.GetFeeTypeById(feeTypeId);
            return PartialView("_FeeTypeEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveFeeType(FeeTypeModel model)
        {
            model.DebitAccount = string.IsNullOrEmpty(model.DebitAccount) ? string.Empty : model.DebitAccount;
            model.CreditAccount = string.IsNullOrEmpty(model.CreditAccount) ? string.Empty : model.CreditAccount;

            return Json(new { result = await _IFeeService.SaveFeeType(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteFeeType(long feeTypeId)
        {
            return Json(new { result = await _IFeeService.DeleteFeeType(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeTypeId) });
        }
        #endregion

        #region Fee type detail

        public async Task<IActionResult> FeeTypeDetail(long feeTypeId = 0)
        {
            //ViewBag.DiscountRuleDropdown = await GetAppDropdown(AppDropdown.DiscountRule, false);
            //DiscountDetailModel model = new DiscountDetailModel();
            //if (discountId > 0)
            //    model = await _ISetupService.GetDiscountById(discountId);
            //return PartialView("_DiscountEditPartial", model);

            ViewBag.AcadmicYearDropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
            ViewBag.FeeTypeDropdown = await GetAppDropdown(AppDropdown.FeeType, true);
            ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);

            FeeTermDetailModel model = new FeeTermDetailModel() { FeeTypeId = feeTypeId };
            if (feeTypeId > 0)
                model = await _IFeeService.GetFeeTypeDetailById(feeTypeId, 0);

            //Always save record
            model.FeeTypeId = feeTypeId;
            model.FeeTypeDetailId = 0;
            return View(model);
        }
        public async Task<IActionResult> FeeTypeDataDetailPartial(long feeTypeId,  long feeTypeDetailId = 0)
        {
            var feeTypeDetails = await _IFeeService.GetFeeTypeDetails(feeTypeId, feeTypeDetailId);
            return PartialView("_FeeTypeDetailDataPartial", feeTypeDetails);
        }

        public async Task<IActionResult> FeeTypeDetailEditPartial(long feeTypeId, long feeTypeDetailId = 0)
        {
            ViewBag.AcadmicYearDropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
            ViewBag.FeeTypeDropdown = await GetAppDropdown(AppDropdown.FeeType, true);
            ViewBag.GradeDropdown = await GetAppDropdown(AppDropdown.Grade, true);

            var feetype = await _IFeeService.GetFeeTypeById(feeTypeId);

            FeeTermDetailModel model = new FeeTermDetailModel();
            if (feeTypeDetailId > 0)
                model = await _IFeeService.GetFeeTypeDetailById(feeTypeId, feeTypeDetailId);
            if (feetype != null)
            {
                model.FeeTypeId = feetype.FeeTypeId;
                model.IsPaymentPlan = feetype.IsPaymentPlan;
                model.IsTermPlan = feetype.IsTermPlan;
                model.IsGradeWise = feetype.IsGradeWise;
            }
            return PartialView("_FeeTypeDetailEditPartial", model);
        }

        public async Task<IActionResult> TermPlanDetail(long feeTypeId = 0, long feeTypeDetailId = 0)
        {
            FeeTermDetailModel model = new FeeTermDetailModel() { FeeTypeId = feeTypeId, FeeTypeDetailId = feeTypeDetailId };
            if (feeTypeId > 0)
                model = await _IFeeService.GetFeeTypeDetailById(feeTypeId, feeTypeDetailId);

            return PartialView("_TermPlanDetail", model);

            //return Json(new { result = await _IFeeService.DeleteFeeType(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeTypeDetailId) });
        }

        public async Task<IActionResult> DeleteFeeTypeDetail(long feeTypeDetailId)
        {
            return Json(new { result = await _IFeeService.DeleteFeeTypeDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeTypeDetailId) });
        }

        [HttpPost]
        public async Task<IActionResult> SaveFeeTypeDetail(FeeTermDetailSaveModel model)
        {
            return Json(new { result = await _IFeeService.SaveFeeTypeDetail(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        #endregion Fee type detail

        #region Fee Plan
        public async Task<IActionResult> FeePlan(long feeTypeId)
        {
            ViewBag.TermYear = await GetAppTermYearDropdown(true);
            return View(await _IFeeService.GetFeeTypeById(feeTypeId));
        }
        public async Task<IActionResult> GetFeePlanWithoutGradewiseDataPartial(long feeTypeId)
        {
            DataSet ds = await _IFeeService.GetFeePlanWithoutGradewise(feeTypeId);
            return PartialView("_GetFeePlanWithoutGradewiseDataPartial", ds);
        }
        public async Task<IActionResult> FeePlanWithoutGradewiseEdit(long feeTypeId, long feeStructureId)
        {
            FeePlanModel model = new FeePlanModel();
            if (feeStructureId > 0)
                model = await _IFeeService.GetFeePlanWithoutGradewiseById(feeTypeId, feeStructureId);

            return Json(new { AcademicYear = model.AcademicYear, FeeAmount = model.FeeAmount, IsGradeWise = model.IsGradeWise });
        }
        [HttpPost]
        public async Task<IActionResult> SaveFeePlanWithoutGradewise(FeePlanModel model)
        {
            return Json(new { result = await _IFeeService.SaveFeePlanWithoutGradewise(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteFeePlanWithoutGradewise(long feeStructureId)
        {
            return Json(new { result = await _IFeeService.DeleteFeePlanWithoutGradewise(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeStructureId) });
        }

        public async Task<IActionResult> GetFeePlanWithGradewiseDataPartial(long feeTypeId, string academicYear)
        {
            DataSet ds = await _IFeeService.GetFeePlanWithGradewise(feeTypeId, academicYear);
            return PartialView("_GetFeePlanWithGradewiseDataPartial", ds);
        }
        [HttpPost]
        public async Task<IActionResult> SaveFeePlanWithGradewise(string FeeStructureWithGradwiseList)
        {
            try
            {
                List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList = JsonSerializer.Deserialize<List<GradeWiseFeeStructureModel>>(FeeStructureWithGradwiseList);
                return Json(new { result = await _IFeeService.SaveFeePlanWithoutGradewise(Convert.ToInt32(GetUserDataFromClaims("UserId")), gradeWiseFeeStructureModelList) });
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    result = -1
                });
            }
        }
        #endregion

        #region Fee Structure
        public async Task<IActionResult> FeeStructure()
        {
            ViewBag.TermYear = await GetAppTermYearDropdown(true);
            return View();
        }
        public async Task<IActionResult> GetFeeStructureDataPartial(string academicYear)
        {
            DataSet ds = await _IFeeService.GetFeeStructure(academicYear);
            return PartialView("_FeeStructureDataPartial", ds);
        }
        [HttpPost]
        public async Task<IActionResult> SaveFeeStructure(string FeeStructureWithoutGradwiseList, string FeeStructureWithGradwiseList)
        {
            try
            {
                List<FeeStructureModel> feeStructureModelList = JsonSerializer.Deserialize<List<FeeStructureModel>>(FeeStructureWithoutGradwiseList);
                List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList = JsonSerializer.Deserialize<List<GradeWiseFeeStructureModel>>(FeeStructureWithGradwiseList);
                return Json(new { result = await _IFeeService.SaveFeeStructure(Convert.ToInt32(GetUserDataFromClaims("UserId")), feeStructureModelList, gradeWiseFeeStructureModelList) });
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    result = -1
                });
            }
        }
        #endregion

        #region Fee Payment Plan
        public async Task<IActionResult> FeePaymentPlanPartial(long feeTypeId,long feeTypeDetailId)
        {

            return PartialView("_FeePaymentPlanPartial", await _IFeeService.GetFeeTypeDetailById(feeTypeId, feeTypeDetailId));
        }
        public async Task<IActionResult> FeePaymentPlanDataPartial(long feeTypeDetailId)
        {
            return PartialView("_FeePaymentPlanDataPartial", await _IFeeService.GetFeePaymentPlan(feeTypeDetailId));
        }
        [HttpPost]
        public async Task<IActionResult> SaveFeePaymentPlan(PaymentPlanModel model)
        {
            return Json(new { result = await _IFeeService.SaveFeePaymentPlan(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteFeePaymentPlan(long feePaymentPlanId)
        {
            return Json(new { result = await _IFeeService.DeleteFeePaymentPlan(Convert.ToInt32(GetUserDataFromClaims("UserId")), feePaymentPlanId) });
        }
        public async Task<IActionResult> GetFeePaymentPlan(long feePaymentPlanId,long feeTypeDetailId)
        {
            PaymentPlanModel model = await _IFeeService.GetFeePaymentPlanById(feeTypeDetailId, feePaymentPlanId);
            return Json(new { FeePaymentPlanId = model.FeePaymentPlanId, PaymentPlanAmount = model.PaymentPlanAmount, DueDate = model.DueDate });
        }
        #endregion

    }
}
