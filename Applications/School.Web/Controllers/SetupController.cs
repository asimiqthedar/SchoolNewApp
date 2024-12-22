using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.ConfigModel;
using School.Models.WebModels.CostCenterModels;
using School.Models.WebModels.DiscountModels;
using School.Models.WebModels.DocumentTypeModels;
using School.Models.WebModels.GenderModels;
using School.Models.WebModels.GradeModels;
using School.Models.WebModels.InvoiceTypeModels;
using School.Models.WebModels.PaymentMethod;
using School.Models.WebModels.SectionModels;
using School.Models.WebModels.StudentStatus;
using School.Models.WebModels.VatModels;
using School.Services.WebServices.Services;

namespace School.Web.Controllers
{
	[Authorize]
    public class SetupController : BaseController
    {
        private readonly ILogger<SetupController> _logger;
        private ISetupService _ISetupService;
        IOptions<AppSettingConfig> _AppSettingConfig;
        IHttpContextAccessor _IHttpContextAccessor;
        public SetupController(ILogger<SetupController> logger, IOptions<AppSettingConfig> appSettingConfig, ISetupService iSetupService, IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService) : base(iHttpContextAccessor, iDropdownService)
        {
            _logger = logger;
            _AppSettingConfig = appSettingConfig;
            _ISetupService = iSetupService;
            _IHttpContextAccessor = iHttpContextAccessor;
        }

        public async void InitDropdown()
        {
            ViewBag.PaymentMethodCategoryDropdown = await GetAppDropdown(AppDropdown.PaymentMethodCategory, true);
        }

        #region Cost Center    
        public IActionResult CostCenter()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> CostCenterDataPartial(CostCenterFilterModel model)
        {
            return PartialView("_CostCenterDataPartial", await _ISetupService.GetCostCenters(model));
        }
        public async Task<IActionResult> CostCenterEditPartial(int costCenterId = 0)
        {
            CostCenterModel model = new CostCenterModel();
            if (costCenterId > 0)
                model = await _ISetupService.GetCostCenterById(costCenterId);
            return PartialView("_CostCenterEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveCostCenter(CostCenterModel model)
        {
            model.DebitAccount = string.IsNullOrEmpty(model.DebitAccount) ? string.Empty : model.DebitAccount;
            model.CreditAccount = string.IsNullOrEmpty(model.CreditAccount) ? string.Empty : model.CreditAccount;

            return Json(new { result = await _ISetupService.SaveCostCenter(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteCostCenter(int costCenterId)
        {
            return Json(new { result = await _ISetupService.DeleteCostCenter(Convert.ToInt32(GetUserDataFromClaims("UserId")), costCenterId) });
        }
        #endregion

        #region Gender type   
        public IActionResult Gender()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> GenderDataPartial(GenderFilterModel model)
        {
            return PartialView("_GenderDataPartial", await _ISetupService.GetGenders(model));
        }
        public async Task<IActionResult> GenderEditPartial(int genderTypeId = 0)
        {
            GenderModel model = new GenderModel();
            if (genderTypeId > 0)
                model = await _ISetupService.GetGenderById(genderTypeId);
            return PartialView("_GenderEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveGender(GenderModel model)
        {
            return Json(new { result = await _ISetupService.SaveGender(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteGender(int genderTypeId)
        {
            return Json(new { result = await _ISetupService.DeleteGender(Convert.ToInt32(GetUserDataFromClaims("UserId")), genderTypeId) });
        }
        #endregion

        #region Grade  
        public async void InitGradeDropdown()
        {
            ViewBag.CostCenterDropdown = await GetAppDropdown(AppDropdown.CostCenter, true);
            ViewBag.GenderDropdown = await GetAppDropdown(AppDropdown.Gender, true);
        }
        public IActionResult Grade()
        {
            _logger.LogInformation("Start: SetupController");
            InitGradeDropdown();
            return View();
        }
        public async Task<IActionResult> GradeDataPartial(GradeFilterModel model)
        {
            return PartialView("_GradeDataPartial", await _ISetupService.GetGrades(model));
        }
        public async Task<IActionResult> GradeEditPartial(int gradeId = 0)
        {
            InitGradeDropdown();
            GradeModel model;
            if (gradeId > 0)
                model = await _ISetupService.GetGradeById(gradeId);
            else
                model = await _ISetupService.GetGradeMaxSequenceNo();
            return PartialView("_GradeEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveGrade(GradeModel model)
        {
            model.DebitAccount = string.IsNullOrEmpty(model.DebitAccount) ? string.Empty : model.DebitAccount;
            model.CreditAccount = string.IsNullOrEmpty(model.CreditAccount) ? string.Empty : model.CreditAccount;
            return Json(new { result = await _ISetupService.SaveGrade(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteGrade(int gradeId)
        {
            return Json(new { result = await _ISetupService.DeleteGrade(Convert.ToInt32(GetUserDataFromClaims("UserId")), gradeId) });
        }
        public async Task<IActionResult> AdjustGrade(int gradeId, int value, int sequenceNo)
        {
            return Json(new { result = await _ISetupService.AdjustGrade(gradeId, value, sequenceNo) });
        }
        #endregion

        #region Document Type    
        public IActionResult DocumentType()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> DocumentTypeDataPartial(DocumentTypeFilterModel model)
        {
            return PartialView("_DocumentTypeDataPartial", await _ISetupService.GetDocumentType(model));
        }
        public async Task<IActionResult> DocumentTypeEditPartial(int documentTypeId = 0)
        {
            DocumentTypeModel model = new DocumentTypeModel();
            if (documentTypeId > 0)
                model = await _ISetupService.GetDocumentTypeById(documentTypeId);
            return PartialView("_DocumentTypeEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveDocumentType(DocumentTypeModel model)
        {
            return Json(new { result = await _ISetupService.SaveDocumentType(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteDocumentType(int documentTypeId)
        {
            return Json(new { result = await _ISetupService.DeleteDocumentType(Convert.ToInt32(GetUserDataFromClaims("UserId")), documentTypeId) });
        }
        #endregion

        #region Section
        public IActionResult Section()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> SectionDataPartial(SectionFilterModel model)
        {
            return PartialView("_SectionDataPartial", await _ISetupService.GetSections(model));
        }
        public async Task<IActionResult> SectionEditPartial(int sectionId = 0)
        {
            SectionModel model = new SectionModel();
            if (sectionId > 0)
                model = await _ISetupService.GetSectionById(sectionId);
            return PartialView("_SectionEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveSection(SectionModel model)
        {
            return Json(new { result = await _ISetupService.SaveSection(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteSection(int sectionId)
        {
            return Json(new { result = await _ISetupService.DeleteSection(Convert.ToInt32(GetUserDataFromClaims("UserId")), sectionId) });
        }
        #endregion

        #region Invoice Type    
        public IActionResult InvoiceType()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> InvoiceTypeDataPartial(InvoiceTypeFilterModel model)
        {
            return PartialView("_InvoiceTypeDataPartial", await _ISetupService.GetInvoiceType(model));
        }
        public async Task<IActionResult> InvoiceTypeEditPartial(int invoiceTypeId = 0)
        {
            InvoiceTypeModel model = new InvoiceTypeModel();
            if (invoiceTypeId > 0)
                model = await _ISetupService.GetInvoiceTypeById(invoiceTypeId);
            return PartialView("_InvoiceTypeEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveInvoiceType(InvoiceTypeModel model)
        {
            return Json(new { result = await _ISetupService.SaveInvoiceType(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteInvoiceType(int invoiceTypeId)
        {
            return Json(new { result = await _ISetupService.DeleteInvoiceType(Convert.ToInt32(GetUserDataFromClaims("UserId")), invoiceTypeId) });
        }
        #endregion

        #region Student Status    
        public IActionResult StudentStatus()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> StudentStatusDataPartial(StudentStatusFilterModel model)
        {
            return PartialView("_StudentStatusDataPartial", await _ISetupService.GetStudentStatus(model));
        }
        public async Task<IActionResult> StudentStatusEditPartial(int studentStatusId = 0)
        {
            StudentStatusModel model = new StudentStatusModel();
            if (studentStatusId > 0)
                model = await _ISetupService.GetStudentStatusById(studentStatusId);
            return PartialView("_StudentStatusEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveStudentStatus(StudentStatusModel model)
        {
            return Json(new { result = await _ISetupService.SaveStudentStatus(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteStudentStatus(int studentStatusId)
        {
            return Json(new { result = await _ISetupService.DeleteStudentStatus(Convert.ToInt32(GetUserDataFromClaims("UserId")), studentStatusId) });
        }
        #endregion

        #region OpenApply 
        public IActionResult OpenApply()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> OpenApplyEditPartial()
        {
            OpenApplyModel model = new OpenApplyModel();
            model = await _ISetupService.GetGetOpenApply(0);
            return PartialView("_OpenApplyEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveOpenApply(OpenApplyModel model)
        {
            return Json(new { result = await _ISetupService.SaveOpenApply(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        #endregion OpenApply

        #region Vat   
        public IActionResult Vat()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> VatDataPartial()
        {
            return PartialView("_VatDataPartial", await _ISetupService.GetVats());
        }
        public async Task<IActionResult> VatEditPartial(int vatId = 0)
        {
            ViewBag.FeeTypeDropdown = await GetAppDropdown(AppDropdown.FeeType, true);
            VatModel model = new VatModel();
            if (vatId > 0)
                model = await _ISetupService.GetVatById(vatId);
            return PartialView("_VatEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveVat(VatModel model)
        {
            model.DebitAccount = string.IsNullOrEmpty(model.DebitAccount) ? string.Empty : model.DebitAccount;
            model.CreditAccount = string.IsNullOrEmpty(model.CreditAccount) ? string.Empty : model.CreditAccount;

            return Json(new { result = await _ISetupService.SaveVat(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteVat(int vatId)
        {
            return Json(new { result = await _ISetupService.DeleteVat(Convert.ToInt32(GetUserDataFromClaims("UserId")), vatId) });
        }
        #region Vat Exempted Nation Mapping
        public async Task<IActionResult> VatExemptedNationMappingPartial(long vatId)
        {
            return PartialView("_VatExemptedNationMappingPartial", await _ISetupService.GetVatExemptedNationMapping(vatId));
        }
        [HttpPost]
        public async Task<IActionResult> VatExemptedNationMapping(VatExemptedNationModel model)
        {
            return Json(new { result = await _ISetupService.SaveVatExemptedNationMapping(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        #endregion
        #endregion

        #region Discount   
        public IActionResult Discount()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> DiscountDataPartial()
        {
            return PartialView("_DiscountDataPartial", await _ISetupService.GetSiblingDiscounts());
        }
        public async Task<IActionResult> DiscountEditPartial(int discountId = 0)
        {
            DiscountModel model = new DiscountModel();
            if (discountId > 0)
                model = await _ISetupService.GetSiblingDiscountById(discountId);
            return PartialView("_DiscountEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveDiscount(DiscountModel model)
        {
            return Json(new { result = await _ISetupService.SaveSiblingDiscount(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }
        public async Task<IActionResult> DeleteDiscount(int discountId)
        {
            return Json(new { result = await _ISetupService.DeleteSiblingDiscount(Convert.ToInt32(GetUserDataFromClaims("UserId")), discountId) });
        }
        #endregion

        #region Email
        public IActionResult Email()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }

        public async Task<IActionResult> EmailConfigEditPartial()
        {
            EmailConfigModel model = new EmailConfigModel();
            model = await _ISetupService.GetEmailConfig(0);
            return PartialView("_EmailConfigEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveEmailConfig(EmailConfigModel model)
        {
            return Json(new { result = await _ISetupService.SaveEmailConfig(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }

        #endregion

        #region Whatsapp
        public IActionResult Whatsapp()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }

        public async Task<IActionResult> WhatsappConfigEditPartial()
        {
            WhatsappConfigModel model = new WhatsappConfigModel();
            model = await _ISetupService.GetWhatsappConfig(0);
            return PartialView("_WhatsappConfigEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SaveWhatsappConfig(WhatsappConfigModel model)
        {
           return Json(new { result = await _ISetupService.SaveWhatsappConfig(Convert.ToInt32(GetUserDataFromClaims("UserId")), model) });
        }

		#endregion

		#region Payment Method Category
		public IActionResult PaymentMethodCategory()
		{
			_logger.LogInformation("Start: SetupController");
			return View();
		}
		public async Task<IActionResult> PaymentMethodCategoryDataPartial()
		{
			return PartialView("_PaymentMethodCategoryDataPartial", await _ISetupService.GetPaymentMethodCategory());
		}
		public async Task<IActionResult> PaymentMethodCategoryEditPartial(long paymentMethodCategoryId = 0)
		{
            PaymentMethodCategoryModel model = new PaymentMethodCategoryModel();
			if (paymentMethodCategoryId > 0)
				model = await _ISetupService.GetPaymentMethodCategoryById(paymentMethodCategoryId);
			return PartialView("_PaymentMethodCategoryEditPartial", model);
		}
		[HttpPost]
		public async Task<IActionResult> SavePaymentMethodCategory(PaymentMethodCategoryModel model)
		{
			return Json(new { result = await _ISetupService.SavePaymentMethodCategory(model)});
		}
        #endregion

        #region Payment Method

        public IActionResult PaymentMethod()
        {
            _logger.LogInformation("Start: SetupController");
            return View();
        }
        public async Task<IActionResult> PaymentMethodDataPartial()
        {
            return PartialView("_PaymentMethodDataPartial", await _ISetupService.GetPaymentMethod());
        }
        public async Task<IActionResult> PaymentMethodEditPartial(long paymentMethodId = 0)
        {
            InitDropdown();
            PaymentMethodModel model = new PaymentMethodModel();
            if (paymentMethodId > 0)
                model = await _ISetupService.GetPaymentMethodById(paymentMethodId);
            return PartialView("_PaymentMethodEditPartial", model);
        }
        [HttpPost]
        public async Task<IActionResult> SavePaymentMethod(PaymentMethodModel model)
        {
            return Json(new { result = await _ISetupService.SavePaymentMethod(model) });
        }



        public async Task<IActionResult> DeletePaymentMethod(int paymentMethodId)
        {
            return Json(new { result = await _ISetupService.DeletePaymentMethod(paymentMethodId) });
        }

        #endregion
    }
}
