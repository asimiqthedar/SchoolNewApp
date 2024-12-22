using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.VatModels;
using School.Models.ZatcaModels;
using School.Services.ALSManager;
using School.Services.Entities;
using School.Services.WebServices.Services;
using School.Services.ZatcaEntities;
using School.Services.ZatcaManager;
using School.Web.Helpers;
using School.Web.Models;
using System.Data;
using System.Net;

namespace School.Web.Controllers
{
	[Authorize]
	public class InvoiceSetupController : BaseController
	{
		private readonly ILogger<InvoiceSetupController> _logger;
		private readonly ICommonService _ICommonService;

		private readonly IInvoiceService _IInvoiceService;
		private readonly IOptions<AppSettingConfig> _AppSettingConfig;
		private readonly IOptions<ZatcaAppSettingConfig> _ZatcaAppSettingConfig;
       
        private readonly IHttpContextAccessor _IHttpContextAccessor;
		private readonly IWebHostEnvironment _IWebHostEnvironment;
		private readonly IInvSummaryManager _iInvSummaryManager;
		private readonly IInvInvoiceDetailManager _iInvInvoiceDetailManager;
		private readonly IInvInvoicePaymentManager _iInvInvoicePaymentManager;
		private readonly IMapper _mapper;
		private readonly IParentManager _iParentManager;
		private readonly IParentAccountManager _iParentAccountManager;
		private readonly IStudentManager _iStudentManager;

		private readonly IZatcaInvoiceSummaryManager _iZatcaInvoiceSummaryManager;
		private readonly IZatcaInvoiceDetailManager _iZatcaInvoiceDetailManager;
		private readonly IZatcaInvoicePaymentManager _iZatcaInvoicePaymentManager;

		private readonly IZatcaInvoiceUniformManager _iZatcaInvoiceUniformManager;
		private readonly ISchoolAcademicManager _iSchoolAcademicManager;

		private readonly IConfigurationRoot _config;
		private readonly ICountryManager _countryManager;
		private readonly IEmailService _emailService;
		private readonly IVATManager _iVATManager;
		private readonly IPaymentMethodManager _iPaymentMethodManager;
        private readonly ALSContext _ALSContextDB;
        private readonly ILogger<ZatcaHelper> _zatcalogger;
        //private readonly log4net.ILog _zatcalogger;
        public InvoiceSetupController(ILogger<InvoiceSetupController> logger, IOptions<AppSettingConfig> appSettingConfig, IOptions<ZatcaAppSettingConfig> zatcaAppSettingConfig,
			IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService,
            ALSContext ALSContextDB,
            ILogger<ZatcaHelper> zatcalogger,
            IInvoiceService iInvoiceService,
			IWebHostEnvironment iWebHostEnvironment,
			  ICommonService iCommonService,
			  IMapper mapper,
			  IInvSummaryManager iInvSummaryManager,
			  IInvInvoiceDetailManager iInvInvoiceDetailManager,
			  IInvInvoicePaymentManager iInvInvoicePaymentManager,

			 IParentManager iParentManager,
			 IStudentManager iStudentManager,

			IZatcaInvoiceSummaryManager iZatcaInvoiceSummaryManager,
			IZatcaInvoiceDetailManager iZatcaInvoiceDetailManager,
			IZatcaInvoicePaymentManager iZatcaInvoicePaymentManager,

			IZatcaInvoiceUniformManager iZatcaInvoiceUniformManager,

			ICountryManager countryManager,
			IEmailService emailService,
			ISchoolAcademicManager iSchoolAcademicManager,
			IParentAccountManager iParentAccountManager,

			IVATManager iVATManager,
			IPaymentMethodManager iPaymentMethodManager
			) : base(iHttpContextAccessor, iDropdownService)
		{
			_ALSContextDB = ALSContextDB;
			_zatcalogger = zatcalogger;
            _iZatcaInvoiceSummaryManager = iZatcaInvoiceSummaryManager;
			_iZatcaInvoiceDetailManager = iZatcaInvoiceDetailManager;
			_iZatcaInvoicePaymentManager = iZatcaInvoicePaymentManager;

			_ZatcaAppSettingConfig = zatcaAppSettingConfig;
			_logger = logger;
			_AppSettingConfig = appSettingConfig;
			_IHttpContextAccessor = iHttpContextAccessor;
			_IWebHostEnvironment = iWebHostEnvironment;
			_ICommonService = iCommonService;
			_mapper = mapper;
			_IInvoiceService = iInvoiceService;

			_iInvSummaryManager = iInvSummaryManager;
			_iInvInvoiceDetailManager = iInvInvoiceDetailManager;
			_iInvInvoicePaymentManager = iInvInvoicePaymentManager;
			_iParentManager = iParentManager;
			_iStudentManager = iStudentManager;

			_iInvInvoicePaymentManager = iInvInvoicePaymentManager;
			_iParentManager = iParentManager;
			_iStudentManager = iStudentManager;
			_iZatcaInvoiceUniformManager = iZatcaInvoiceUniformManager;

			_countryManager = countryManager;
			_emailService = emailService;
			_iSchoolAcademicManager = iSchoolAcademicManager;
			_iParentAccountManager = iParentAccountManager;

			_iVATManager = iVATManager;
			_iPaymentMethodManager = iPaymentMethodManager;
		}

		public async void InitDropdown()
		{
			ViewBag.ParentDropdown = await GetAppDropdown(AppDropdown.Parent, true);
			//ViewBag.StudentDropdown = await GetAppDropdown(AppDropdown.Student, true);
			ViewBag.InvoiceTypeDropdown = await GetAppDropdown(AppDropdown.FeeType, true);
			ViewBag.AcademicYearDropDown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
			ViewBag.GradeDropDown = await GetAppDropdown(AppDropdown.Grade, true);
			ViewBag.CountryDropDown = await GetAppDropdown(AppDropdown.Country, true);
		}

		#region Invoice Action
		public IActionResult Invoice(int printInvoiceno = 0)
		{
			_logger.LogInformation("Start: InvoiceSetupController");
			ViewBag.PrintInvoiceno = printInvoiceno;
			return View();
		}

		public async Task<IActionResult> InvoiceDataPartial(InvoiceFilterModel filterModel)
		{
			DataSet ds = await _IInvoiceService.GetInvoice(filterModel);
			return PartialView("_InvoiceDataPartial", ds);
		}

		public async Task<IActionResult> AddEditInvoice(long invoiceNo)
		{
			Guid sessionKeyId = Guid.NewGuid();
			string SessionKeyTime = GetSessionKey(invoiceNo, sessionKeyId.ToString());
			InvInvoiceSummaryModel invInvoiceSummaryModel = new InvInvoiceSummaryModel() { InvoiceSessionKey = SessionKeyTime, InvoiceNo = invoiceNo };

			var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
			if (invoiceNoSummaryRecord != null)
				invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;

			var vatAccountNotAvaialble = await _iVATManager.IsAccountExist();
			var paymentMethodAccountNotAvaialble = await _iPaymentMethodManager.IsAccountExist();

			invInvoiceSummaryModel.VATAccountExist = vatAccountNotAvaialble;
			invInvoiceSummaryModel.PaymentMethodAccountExist = paymentMethodAccountNotAvaialble;

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				//HttpContext.Session.Set<DateTime>(SessionKeyTime, currentTime);
			}
			if (invoiceNo > 0)
			{
				var invoiceSummary = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
				var invoiceDetails = await _iInvInvoiceDetailManager.GetAllByInvoiceNo(invoiceNo);
				var invoicePayments = await _iInvInvoicePaymentManager.GetAllByInvoiceNo(invoiceNo);

				invInvoiceSummaryModel = _mapper.Map<InvInvoiceSummaryModel>(invoiceSummary);
				invInvoiceSummaryModel.InvoiceSessionKey = SessionKeyTime;

				var detailList = _mapper.Map<List<InvInvoiceDetailModel>>(invoiceDetails);
				var paymentList = _mapper.Map<List<InvInvoicePaymentModel>>(invoicePayments);

				var dropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
				foreach (var s in detailList)
				{
					if (!string.IsNullOrEmpty(s.ParentId))
					{
						var parentRecord = await _iParentManager.GetById(Convert.ToInt64(s.ParentId));
						if (parentRecord != null)
						{
							s.ParentName = parentRecord.FatherName;
							s.ParentCode = parentRecord.ParentCode;
						}
					}
					if (!string.IsNullOrEmpty(s.StudentId))
					{
						var studentRecord = await _iStudentManager.GetById(Convert.ToInt64(s.StudentId));
						if (studentRecord != null)
						{
							s.StudentName = studentRecord.StudentName;
							s.StudentCode = studentRecord.StudentCode;
						}
					}

					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceNo = invoiceNo;

					var academicYear = dropdown.FirstOrDefault(x => x.Value == s.AcademicYear);
					if (academicYear != null)
					{
						s.AcademicYearName = academicYear.Text;
					}
				}

				paymentList.ForEach(s =>
				{
					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceNo = invoiceNo;
				});



				invInvoiceSummaryModel.InvoiceDetailList = detailList;
				invInvoiceSummaryModel.InvoicePaymentList = paymentList;
			}
			HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

			return View(invInvoiceSummaryModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailDataPartial(long invoiceNo, string invoiceSessionKey)
		{
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			List<InvInvoiceDetailModel> invoiceDetailList = new List<InvInvoiceDetailModel>();

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				invoiceDetailList = _mapper.Map<List<InvInvoiceDetailModel>>(invInvoiceSummaryModel.InvoiceDetailList);
				foreach (var item in invoiceDetailList)
				{
					item.IsEditRestricted = invInvoiceSummaryModel.Status != null && invInvoiceSummaryModel.Status.ToLower().Equals("posted");
				}
			}

			return PartialView("_InvoiceDetailDataPartial", invoiceDetailList);
		}

		[HttpPost]
		public async Task<IActionResult> InvoicePaymentDataPartial(long invoiceNo, string invoiceSessionKey)
		{
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			List<InvInvoicePaymentModel> invoiceDetailList = new List<InvInvoicePaymentModel>();
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				invoiceDetailList = invInvoiceSummaryModel.InvoicePaymentList;

				foreach (var item in invoiceDetailList)
				{
					item.IsEditRestricted = invInvoiceSummaryModel.Status != null && invInvoiceSummaryModel.Status.ToLower().Equals("posted");
				}
			}

			return PartialView("_InvoicePaymentDataPartial", invoiceDetailList);
		}

		[HttpPost]
		public async Task<IActionResult> InvoicePaymentAddEdit(InvInvoicePaymentModel model)
		{
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			var isInAddMode = string.IsNullOrEmpty(model.SessionKey);

			model.SessionKey = string.IsNullOrEmpty(model.SessionKey) ? Guid.NewGuid().ToString() : model.SessionKey;
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var InvoiceDetailList = invInvoiceSummaryModel.InvoiceDetailList;
				var totalAmount = InvoiceDetailList.Sum(s => Math.Round(s.ItemSubtotal, 0, MidpointRounding.AwayFromZero));

				var InvoiceDetailModel = invInvoiceSummaryModel.InvoicePaymentList.Where(s => s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel == null)
				{
					var totalPaymentCollected = invInvoiceSummaryModel.InvoicePaymentList.Sum(s => Math.Round(s.PaymentAmount, 0, MidpointRounding.AwayFromZero));
					model.PaymentAmount = Math.Round(model.PaymentAmount, 0, MidpointRounding.AwayFromZero);
					if (isInAddMode && totalAmount < (totalPaymentCollected + model.PaymentAmount))
					{
						return Json(new { result = -2 });
					}
					invInvoiceSummaryModel.InvoicePaymentList.Add(_mapper.Map<InvInvoicePaymentModel>(model));
				}
				else if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoicePaymentList.Remove(invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));

					var totalPaymentCollected = invInvoiceSummaryModel.InvoicePaymentList.Sum(s => Math.Round(s.PaymentAmount, 0, MidpointRounding.AwayFromZero));

					model.PaymentAmount = Math.Round(model.PaymentAmount, 0, MidpointRounding.AwayFromZero);
					if (!isInAddMode && totalAmount < (totalPaymentCollected + model.PaymentAmount))
					{
						return Json(new { result = -2 });
					}

					invInvoiceSummaryModel.InvoicePaymentList.Add(_mapper.Map<InvInvoicePaymentModel>(model));
				}
				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> InvoiceSave(InvInvoiceSummaryModel model)
		{
			return await Save(model, "Saved");
		}

		public async Task<IActionResult> PostInvoice(InvInvoiceSummaryModel model)
		{
			return await PostInvoiceZatca(model, "Posted");
		}

		public async Task<IActionResult> DeleteInvoice(long invoiceId)
		{
			return Json(new { result = await _IInvoiceService.DeleteInvoice(Convert.ToInt32(GetUserDataFromClaims("UserId")), invoiceId) });
		}

		public async Task<IActionResult> loadParentEmail(long invoiceId)
		{
			var fatherEmail = string.Empty;
			var motherEmail = string.Empty;
			var invoiceSummary = await _iInvSummaryManager.GetById(invoiceId);
			var parentInfo = await _iParentManager.GetById(Convert.ToInt32(invoiceSummary.ParentId));
			if (parentInfo != null)
			{
				fatherEmail = parentInfo.FatherEmail ?? string.Empty;
				motherEmail = parentInfo.MotherEmail ?? string.Empty;
			}
			return Json(new { fatherEmail, motherEmail });
		}

		public async Task<IActionResult> SendInvoice(long invoiceId)
		{
			var response = await SendEmail(invoiceId);
			return Json(new { result = response ? 0 : -1 });
			//return Json(new { result = await _IInvoiceService.SendInvoice(invoiceId) });
		}

		public async Task<IActionResult> SendInvoiceToEmails(long invoiceId, string emailids)
		{
			var response = await SendEmail(invoiceId, emailids);
			return Json(new { result = response ? 0 : -1 });
			//return Json(new { result = await _IInvoiceService.SendInvoice(invoiceId) });
		}

		public async Task<IActionResult> GetInvoicePdfPath(string invoiceNo)
		{
			byte[] invoicePdfBytes = null;
			try
			{
				if (!string.IsNullOrEmpty(invoiceNo))
				{
					long invoice_no = Int64.Parse(invoiceNo);
                    var invoiceSummary = await _iZatcaInvoiceSummaryManager.GetByInvoiceNo(invoice_no);

                    if (invoiceSummary != null && !string.IsNullOrEmpty(invoiceSummary.InvoicePdfPath))
                    {
                        string pdfFilePath = invoiceSummary.InvoicePdfPath;
                        invoicePdfBytes = System.IO.File.ReadAllBytes(pdfFilePath);
                        return Json(new { result = 0, invoicePdfPath = invoiceSummary.InvoicePdfPath, invoicePdfBytes = invoicePdfBytes });
                    }
                }
				
				return Json(new
				{
					result = -1,
					invoicePdfPath = "",
					invoicePdfBytes = invoicePdfBytes
				});
			}
			catch
			{
				return Json(new
				{
					result = -1,
					invoicePdfPath = string.Empty,
					invoicePdfBytes
				});
			}
		}

		private async Task<bool> SendEmail(long invoiceId, string emailids = null)
		{
			try
			{
				var invoiceSummary = await _iInvSummaryManager.GetById(invoiceId);
				var zatcaInvoiceSummary = await _iZatcaInvoiceSummaryManager.GetByInvoiceNo(invoiceSummary.InvoiceNo);

				if (!string.IsNullOrWhiteSpace(emailids))
				{
					var response = await _emailService.SendInvoiceEmailWithInvoiceAttachment(invoiceId, zatcaInvoiceSummary?.InvoicePdfPath, emailids);
					return response;
				}
				else
				{
					var response = await _emailService.SendInvoiceEmailWithInvoiceAttachment(invoiceId, zatcaInvoiceSummary?.InvoicePdfPath, zatcaInvoiceSummary?.EmailID);
					return response;
				}
			}
			catch (Exception ex)
			{
				return false;
			}
		}

		private async Task<bool> SendEmail(long invoiceId, long invoiceNo, string pdfPtah)
		{
			try
			{
				var invoiceSummary = await _iInvSummaryManager.GetById(invoiceNo);
				var invoicedetails = await _iInvInvoiceDetailManager.GetAllByInvoiceNo(invoiceNo);
				var emailid = string.Empty;
				if (invoicedetails.Any(s => !string.IsNullOrEmpty(s.ParentId) && Convert.ToInt64(s.ParentId) > 0))
				{
					var parentId = invoicedetails.FirstOrDefault(s => !string.IsNullOrEmpty(s.ParentId) && Convert.ToInt64(s.ParentId) > 0).ParentId;
					if (!string.IsNullOrEmpty(parentId))
					{
						var parentRecord = await _iParentManager.GetById(Convert.ToInt64(parentId));
						if (parentRecord != null)
						{
							if (!string.IsNullOrEmpty(parentRecord.FatherEmail))
								emailid = parentRecord.FatherEmail;
							if (!string.IsNullOrEmpty(parentRecord.MotherEmail))
								emailid = string.IsNullOrEmpty(emailid) ? parentRecord.MotherEmail : emailid + "," + parentRecord.MotherEmail;

						}
					}
				}

				var response = await _emailService.SendInvoiceEmailWithInvoiceAttachment(invoiceId, pdfPtah, emailid);
				return response;
			}
			catch (Exception ex)
			{
				return false;
			}
		}

		private async Task<IActionResult> Save(InvInvoiceSummaryModel model, string status = "Saved")
		{
			InvoiceSavePostedResponse invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = 0 };
			_logger.LogInformation($"Start Save: status:{status}, model: {JsonConvert.SerializeObject(model)}");
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);
			try
			{
				if (!HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
				{
					invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -8 };//Error in process
					return Json(invoiceSavePostedResponse);
				}

				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				if (model.InvoiceDate != DateTime.MinValue)
				{
					invInvoiceSummaryModel.InvoiceDate = model.InvoiceDate;
				}

				List<InvInvoiceDetail> invInvoiceDetails = _mapper.Map<List<InvInvoiceDetail>>(invInvoiceSummaryModel.InvoiceDetailList);
				List<InvInvoicePayment> invInvoicePayments = _mapper.Map<List<InvInvoicePayment>>(invInvoiceSummaryModel.InvoicePaymentList);

				var isValidPayment = await CheckValidPayment(invoiceSavePostedResponse, invInvoiceDetails, invInvoicePayments);
				if (!isValidPayment)
				{
					return Json(invoiceSavePostedResponse);
				}

				bool isParenAccountAvailable = await CheckValidParent(invoiceSavePostedResponse, invInvoiceDetails, invInvoicePayments, invInvoiceSummaryModel);

				if (!isParenAccountAvailable)
				{
					return Json(invoiceSavePostedResponse);
				}

				long latestInvoiceno = model.InvoiceNo;
				if (invInvoiceSummaryModel.InvoiceId <= 0)
				{
					//Moved logic on final save
					//latestInvoiceno = await _IInvoiceService.GetLatestInvoice();
					invInvoiceSummaryModel.InvoiceDate = (!model.InvoiceDate.HasValue && model.InvoiceDate != DateTime.MinValue) ? DateTime.Now : model.InvoiceDate;
				}
				else
				{
					var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(model.InvoiceNo);
					if (invoiceNoSummaryRecord != null && model.InvoiceDate == DateTime.MinValue)
						invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;
					else
						invInvoiceSummaryModel.InvoiceDate = (!model.InvoiceDate.HasValue && model.InvoiceDate != DateTime.MinValue) ? DateTime.Now : model.InvoiceDate;
				}

				invInvoiceSummaryModel.InvoiceNo = latestInvoiceno;

				foreach (var item in invInvoiceDetails)
				{
					item.UnitPrice = Math.Round(item.UnitPrice, 2, MidpointRounding.AwayFromZero);
					item.Discount = Math.Round(item.Discount.Value, 0, MidpointRounding.AwayFromZero);
					item.TaxableAmount = Math.Round(item.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);

					item.AcademicYear = string.IsNullOrEmpty(item.AcademicYear) ? string.Empty : item.AcademicYear;
					item.InvoiceNo = latestInvoiceno;
					item.UpdateDate = DateTime.Now.Date;
					item.UpdateBy = Convert.ToInt32(GetUserDataFromClaims("UserId"));
					item.Quantity = item.Quantity <= 0 ? 1 : item.Quantity;

					if (!item.TaxableAmount.HasValue || item.TaxableAmount.Value == 0)
						item.TaxableAmount = (item.Quantity * item.UnitPrice);

					//if (!item.TaxAmount.HasValue || item.TaxAmount.Value == 0)
					item.TaxAmount = Math.Round(Convert.ToDecimal((item.Quantity * item.UnitPrice) * item.TaxRate / 100), 2, MidpointRounding.AwayFromZero);

					if (!item.Discount.HasValue || item.Discount.Value == 0)
						item.Discount = item.Discount.HasValue ? Math.Round(item.Discount.Value, 0, MidpointRounding.AwayFromZero) : 0;

					if (item.ItemSubtotal == 0)
						item.ItemSubtotal = Math.Round(item.TaxableAmount.Value, 0, MidpointRounding.AwayFromZero)
							- Math.Round(item.Discount.Value, 0, MidpointRounding.AwayFromZero)
							+ Math.Round(item.TaxAmount.Value, 0, MidpointRounding.AwayFromZero);

				}

				foreach (var item in invInvoicePayments)
				{
					item.InvoiceNo = latestInvoiceno;
					item.UpdateDate = DateTime.Now.Date;
					item.UpdateBy = Convert.ToInt32(GetUserDataFromClaims("UserId"));
				}

				invInvoiceSummaryModel.Status = status;
				invInvoiceSummaryModel.PublishedBy = GetUserDataFromClaims("UserId");

				invInvoiceSummaryModel.InvoiceType = "Invoice";
				invInvoiceSummaryModel.InvoiceRefNo = 0;

				foreach (var item in invInvoiceDetails)
				{
					item.TaxableAmount = Math.Round((item.ItemSubtotal - (item.TaxAmount.HasValue ? item.TaxAmount.Value : 0)), 0, MidpointRounding.AwayFromZero);
				}

				InvInvoiceSummary invInvoiceSummary = _mapper.Map<InvInvoiceSummary>(invInvoiceSummaryModel);

				var saveInvoiceSummary = await _iInvSummaryManager.SaveInvoice(status, invInvoiceSummary, invInvoiceDetails, invInvoicePayments);

				//await _iInvInvoiceDetailManager.SaveRange(invInvoiceDetails, invInvoiceSummary.InvoiceNo);

				//await _iInvInvoicePaymentManager.SaveRange(invInvoicePayments, invInvoiceSummary.InvoiceNo);

				_logger.LogInformation($"Save ALS Live: saveInvoiceSummary:{JsonConvert.SerializeObject(saveInvoiceSummary)}");

				if (invInvoiceSummary.InvoiceNo <= 0)
				{
					invoiceSavePostedResponse = new InvoiceSavePostedResponse { result = -1 };// No invoice record found		
				}
				else
				{
					//Update session for invoice no, so that if save again then latest invoice number available
					invInvoiceSummaryModel.InvoiceNo = invInvoiceSummary.InvoiceNo;
					invInvoiceSummaryModel.InvoiceRefNo = invInvoiceSummary.InvoiceRefNo.HasValue ? invInvoiceSummary.InvoiceRefNo.Value : 0;
					invoiceSavePostedResponse.invoiceNo = invInvoiceSummaryModel.InvoiceNo;

					HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
				}

				ProcessGPAndStatement(invInvoiceSummary.InvoiceNo, status);

				//call, zatca to get pdf file from saved and posteds

				//_logger.LogInformation($"Posted- Start: Zatca Property Update");
				//bool zatcaSaved = await UpdateZatcaProperty(invInvoiceSummary, invInvoiceDetails, invInvoicePayments);

				//_logger.LogInformation($"Posted- End: Zatca Property Update. ZatcaSaved: {zatcaSaved}");

				//if (!zatcaSaved)
				//{
				//	var invoiceRecord = await _iInvSummaryManager.GetById(invInvoiceSummary.InvoiceId);
				//	if (invoiceRecord != null)
				//	{
				//		invoiceRecord.Status = "Saved";
				//		await _iInvSummaryManager.Save(invoiceRecord);
				//		invoiceSavePostedResponse = new InvoiceSavePostedResponse { result = -3 };// No invoice record found						
				//	}
				//}
				//else
				//{
				//	try
				//	{
				//bool isZatcaProcessRequired = true;
				//bool mailRequiredToSend = true;

				if (status == "Saved" && _AppSettingConfig.Value.EnablePDFGenerateOnSave.ToLower().Equals("false"))
				{
					//isZatcaProcessRequired = false;
					invoiceSavePostedResponse.isPrintNotRequired = true;
				}

						//		if (isZatcaProcessRequired)
						//		{
						//			////Run in seperate process
						//			//Task.Run(async () =>
						//			//{
						//			//Call to process for invoice pdf
						//			using (var client = new HttpClient())
						//			{
						//				var jsonObject = new
						//				{
						//					invoiceNo = invInvoiceSummary.InvoiceNo
						//				};

						//				var invoicePostUrl = _ZatcaAppSettingConfig.Value.ZatcaSaveInvoiceUrl;

						//				if (status == "Posted" && _AppSettingConfig.Value.IsAllowInvoicePostClearance.ToLower().Equals("true"))
						//				{
						//					invoicePostUrl = _ZatcaAppSettingConfig.Value.ZatcaInvoiceClearanceUrl;
						//				}
						//				else if (status == "Posted")
						//				{
						//					invoicePostUrl = _ZatcaAppSettingConfig.Value.ZatcaPostInvoiceUrl;
						//				}

						//				_logger.LogInformation($"Save Calling Zatca: URL:{invoicePostUrl},  jsonObject:{JsonConvert.SerializeObject(jsonObject)}");

						//				// Make the GET request to the API endpoint
						//				client.Timeout = TimeSpan.FromSeconds(200);
						//				var response = client.PostAsJsonAsync(invoicePostUrl, jsonObject).Result;

						//				// Read the response as a stream
						//				var responseStream = response.Content.ReadAsStreamAsync().Result;

						//				var stringRespons = StreamToString(responseStream);

						//				_logger.LogInformation($"Save Response from Zatca: URL:{invoicePostUrl},  response :{stringRespons}. response StatusCode: {response.StatusCode}");

						//				if (response.StatusCode != HttpStatusCode.OK)
						//				{
						//					invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -4 };
						//					// Unable to process zatca
						//					//Notification service- Implementation
						//					//return Json(invoiceSavePostedResponse);
						//				}
						//				var zatcaResponse = JsonConvert.DeserializeObject<ZatcaResponseModel>(stringRespons);

						//				_logger.LogInformation($"Zatca response: {JsonConvert.SerializeObject(zatcaResponse)}");

						//				if (zatcaResponse != null && (!string.IsNullOrEmpty(zatcaResponse.QRImg) || !string.IsNullOrEmpty(zatcaResponse.PdfPath)))
						//				{
						//					_logger.LogInformation($"Email- Start: Email Sending");

						//					var emailResult = await SendEmail(saveInvoiceSummary.InvoiceId, latestInvoiceno, zatcaResponse.PdfPath);

						//					_logger.LogInformation($"Email- End: Email Sending. emailResult:{emailResult}");

						//					if (!emailResult)
						//					{
						//						invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -5 };
						//						// unable to send email
						//						//Notification service- Implementation
						//						//return Json(invoiceSavePostedResponse);
						//					}
						//				}
						//				else
						//				{
						//					invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -6 };
						//					//Unbale to process zatca
						//					//Notification service- Implementation
						//					//return Json(invoiceSavePostedResponse);
						//				}
						//			}
						//			//});

						//			//Hold for few second to process previous step first
						//			//Thread.Sleep(12000);
						//		}
				//	}
				//	catch (Exception ex)
				//	{
				//		_logger.LogError($"Exception Calling Zatca : Message :{JsonConvert.SerializeObject(ex)}");
				//		invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -7, message = ex.Message };// Exception in calling zatca
				//	}
				//}
			}
			catch (Exception ex)
			{
				invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -9, message = ex.Message };// Error in process
			}

			if (invoiceSavePostedResponse.result == 0)
				HttpContext.Session.Remove(SessionKeyTime);
			return Json(invoiceSavePostedResponse);// Error in process
		}

        private async Task<IActionResult> PostInvoiceZatca(InvInvoiceSummaryModel model, string status = "Posted")
        {
            InvoiceSavePostedResponse invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = 0 };
            _logger.LogInformation($"Start Save: status:{status}, model: {JsonConvert.SerializeObject(model)}");
            string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);
            try
            {
                if (!HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
                {
                    invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -8 };//Error in process
                    return Json(invoiceSavePostedResponse);
                }

                if (model.InvoiceNo <= 0)
                {
                    invoiceSavePostedResponse = new InvoiceSavePostedResponse { result = -1 };// No invoice record found		
                return Json(invoiceSavePostedResponse);
				}
               
                    try
                    {
					
					//here

					var isGeneratePdfOnPostedOnly = true;
					
					ZatcaHelper zatcaHelper = new ZatcaHelper(_AppSettingConfig,_ALSContextDB,_mapper, _zatcalogger, _IWebHostEnvironment);
					
                        var zatcaResponse = await zatcaHelper.ProcessZatcaPostedInvoiceAndGeneratePdf(model.InvoiceNo,"", isGeneratePdfOnPostedOnly);
					//////////
					if (zatcaResponse != null && zatcaResponse.IsSuccess == true)
					{
                        invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = 0 };
                    }
					//review and test it tommorow
					//if (zatcaResponse != null && (!string.IsNullOrEmpty(zatcaResponse.QRImg) || !string.IsNullOrEmpty(zatcaResponse.PdfPath)))
					//{
					//	_logger.LogInformation($"Email- Start: Email Sending");

					//	var emailResult = await SendEmail(model.InvoiceNo, model.InvoiceNo, zatcaResponse.PdfPath);

					//	_logger.LogInformation($"Email- End: Email Sending. emailResult:{emailResult}");

					//	if (!emailResult)
					//	{
					//		invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -5 };
					//		// unable to send email
					//		//Notification service- Implementation
					//		//return Json(invoiceSavePostedResponse);
					//	}
					//}
					//else
					//{
					//	invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -6 };
					//	//Unbale to process zatca
					//	//Notification service- Implementation
					//	//return Json(invoiceSavePostedResponse);
					//}
					////////////
					//}
					//});

					//Hold for few second to process previous step first
					//Thread.Sleep(12000);
					//}
				}
                    catch (Exception ex)
                    {
                        _logger.LogError($"Exception Calling Zatca : Message :{JsonConvert.SerializeObject(ex)}");
                        invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -7, message = ex.Message };// Exception in calling zatca
                    }
                //}
            }
            catch (Exception ex)
            {
                invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -9, message = ex.Message };// Error in process
            }

            if (invoiceSavePostedResponse.result == 0)
                HttpContext.Session.Remove(SessionKeyTime);
            return Json(invoiceSavePostedResponse);// Error in process
        }
        private async Task<IActionResult> PostRefundZatca(InvInvoiceSaveRefundModel model, string status = "Posted")
        {
            InvoiceSavePostedResponse invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = 0 };
            _logger.LogInformation($"Start Save: status:{status}, model: {JsonConvert.SerializeObject(model)}");
            string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);
            try
            {
                if (!HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
                {
                    invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -8 };//Error in process
                    return Json(invoiceSavePostedResponse);
                }

                if (model.InvoiceNo <= 0)
                {
                    invoiceSavePostedResponse = new InvoiceSavePostedResponse { result = -1 };// No invoice record found		
                    return Json(invoiceSavePostedResponse);
                }

                try
                {

                    //here

                    var isGeneratePdfOnPostedOnly = true;

                    ZatcaHelper zatcaHelper = new ZatcaHelper(_AppSettingConfig, _ALSContextDB, _mapper, _zatcalogger, _IWebHostEnvironment);

                    var zatcaResponse = await zatcaHelper.ProcessZatcaPostedInvoiceAndGeneratePdf(model.InvoiceNo, "", isGeneratePdfOnPostedOnly);
                    //////////
                    if (zatcaResponse != null && zatcaResponse.IsSuccess == true)
                    {
                        invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = 0 };
                    }
                    //review and test it tommorow
                    //if (zatcaResponse != null && (!string.IsNullOrEmpty(zatcaResponse.QRImg) || !string.IsNullOrEmpty(zatcaResponse.PdfPath)))
                    //{
                    //	_logger.LogInformation($"Email- Start: Email Sending");

                    //	var emailResult = await SendEmail(model.InvoiceNo, model.InvoiceNo, zatcaResponse.PdfPath);

                    //	_logger.LogInformation($"Email- End: Email Sending. emailResult:{emailResult}");

                    //	if (!emailResult)
                    //	{
                    //		invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -5 };
                    //		// unable to send email
                    //		//Notification service- Implementation
                    //		//return Json(invoiceSavePostedResponse);
                    //	}
                    //}
                    //else
                    //{
                    //	invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -6 };
                    //	//Unbale to process zatca
                    //	//Notification service- Implementation
                    //	//return Json(invoiceSavePostedResponse);
                    //}
                    ////////////
                    //}
                    //});

                    //Hold for few second to process previous step first
                    //Thread.Sleep(12000);
                    //}
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Exception Calling Zatca : Message :{JsonConvert.SerializeObject(ex)}");
                    invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -7, message = ex.Message };// Exception in calling zatca
                }
                //}
            }
            catch (Exception ex)
            {
                invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -9, message = ex.Message };// Error in process
            }

            if (invoiceSavePostedResponse.result == 0)
                HttpContext.Session.Remove(SessionKeyTime);
            return Json(invoiceSavePostedResponse);// Error in process
        }

        private void ProcessGPAndStatement(long invoiceNo, string status)
		{
			if (status == "Posted")
			{
				//Task.Run(() =>
				//{
				//Add record to zatca

				_logger.LogInformation($"Posted- Start : ALS Live: ProcessInvoiceStatement");

				var satementResult = _IInvoiceService.ProcessInvoiceStatement(invoiceNo);

				_logger.LogInformation($"Posted- End : ALS Live: ProcessInvoiceStatement- satementResult " + satementResult);

				_logger.LogInformation($"Posted- Start: ALS Live: Process GP");

				var gPResult = _IInvoiceService.ProcessGP(invoiceNo);

				_logger.LogInformation($"Posted- End: ALS Live: Process GP- gPResult " + gPResult);
				//});
			}
		}
		private async Task<bool> UpdateZatcaProperty(InvInvoiceSummary invInvoiceSummary, List<InvInvoiceDetail> invInvoiceDetails, List<InvInvoicePayment> invInvoicePayments)
		{
            //InvoiceSummary invInvoiceSummaryZatca = _mapper.Map<InvoiceSummary>(invInvoiceSummary);

            List<InvoiceDetail> invInvoiceDetailsZatca = new List<InvoiceDetail>();
			List<UniformDetail> invInvoiceDetailsUniformZatca = new List<UniformDetail>();

			if (invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("tuition")))
			{
				var invInvoiceDetailTuitionRecord = invInvoiceDetails.FirstOrDefault(s => s.InvoiceType.ToLower().Contains("tuition") && !string.IsNullOrEmpty(s.ParentName));
				var parentRecord = invInvoiceDetails.FirstOrDefault(s => s.InvoiceType.ToLower().Contains("tuition") && !string.IsNullOrEmpty(s.ParentId) && Convert.ToInt32(s.ParentId) > 0);

				if (parentRecord != null)
				{
					var parent = await _iParentManager.GetById(Convert.ToInt64(parentRecord.ParentId));
					if (parent != null)
					{
						invInvoiceSummary.IqamaNumber = parent.FatherIqamaNo;
						invInvoiceSummary.EmailID = parent.FatherEmail;
						invInvoiceSummary.MobileNo = parent.FatherMobile;
						var countryRecord = await _countryManager.GetById(parent.FatherNationalityId);
						if (countryRecord != null)
						{
							invInvoiceSummary.Nationality = countryRecord.CountryName;
						}
					}
				}

				invInvoiceSummary.ParentName = invInvoiceDetailTuitionRecord != null ? invInvoiceDetailTuitionRecord.ParentName : invInvoiceSummary.ParentName;
			}

			if (invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("uniform")))
			{
				var invInvoiceDetailUniformRecord = invInvoiceDetails.FirstOrDefault(s => s.InvoiceType.ToLower().Contains("uniform") && !string.IsNullOrEmpty(s.ParentName));
				invInvoiceSummary.ParentName = string.IsNullOrEmpty(invInvoiceSummary.ParentName) && invInvoiceDetailUniformRecord != null ? invInvoiceDetailUniformRecord.ParentName : invInvoiceSummary.ParentName;
				invInvoiceSummary.IqamaNumber = string.IsNullOrEmpty(invInvoiceSummary.IqamaNumber) && invInvoiceDetailUniformRecord != null ? invInvoiceDetailUniformRecord.IqamaNumber : invInvoiceSummary.IqamaNumber;
				invInvoiceSummary.MobileNo = string.IsNullOrEmpty(invInvoiceSummary.MobileNo) && invInvoiceDetailUniformRecord != null ? invInvoiceDetailUniformRecord.FatherMobile : invInvoiceSummary.MobileNo;

				long countryId = 0;
				if (invInvoiceDetailUniformRecord != null && !string.IsNullOrEmpty(invInvoiceDetailUniformRecord.NationalityId) && long.TryParse(invInvoiceDetailUniformRecord.NationalityId, out countryId))
				{
					var countryRecord = await _countryManager.GetById(countryId);
					if (countryRecord != null)
					{
						invInvoiceSummary.Nationality = countryRecord.CountryName;
					}

					var parent = await _iParentManager.GetById(Convert.ToInt64(invInvoiceDetailUniformRecord.ParentId));
					if (parent != null)
					{
						invInvoiceSummary.IqamaNumber = parent.FatherIqamaNo;
						invInvoiceSummary.EmailID = parent.FatherEmail;
						invInvoiceSummary.MobileNo = parent.FatherMobile;
					}
				}
			}

			if (invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("entrance")))
			{
				var invInvoiceDetailEntranceRecord = invInvoiceDetails.FirstOrDefault(s => s.InvoiceType.ToLower().Contains("entrance") && !string.IsNullOrEmpty(s.ParentName));
				invInvoiceSummary.ParentName = string.IsNullOrEmpty(invInvoiceSummary.ParentName) && invInvoiceDetailEntranceRecord != null ? invInvoiceDetailEntranceRecord.ParentName : invInvoiceSummary.ParentName;
				invInvoiceSummary.IqamaNumber = string.IsNullOrEmpty(invInvoiceSummary.IqamaNumber) && invInvoiceDetailEntranceRecord != null ? invInvoiceDetailEntranceRecord.IqamaNumber : invInvoiceSummary.IqamaNumber;
				invInvoiceSummary.MobileNo = string.IsNullOrEmpty(invInvoiceSummary.MobileNo) && invInvoiceDetailEntranceRecord != null ? invInvoiceDetailEntranceRecord.FatherMobile : invInvoiceSummary.MobileNo;

				long countryId = 0;
				if (invInvoiceDetailEntranceRecord != null && !string.IsNullOrEmpty(invInvoiceDetailEntranceRecord.NationalityId) && long.TryParse(invInvoiceDetailEntranceRecord.NationalityId, out countryId))
				{
					var countryRecord = await _countryManager.GetById(countryId);
					if (countryRecord != null)
					{
						invInvoiceSummary.Nationality = countryRecord.CountryName;
					}
				}
			}

			invInvoiceDetails.ToList().ForEach(item =>
			{
				//InvoiceDetail invInvoiceDetailsZatcaItem = _mapper.Map<InvoiceDetail>(item);
				if (item.InvoiceType.ToLower().Contains("uniform"))
				{
                    item.Description = string.IsNullOrEmpty(item.InvoiceType) ? item.Description : item.InvoiceType;
				}
				else
				{
                    item.Description = string.IsNullOrEmpty(item.Description) ? item.InvoiceType : item.Description;
				}

				item.Quantity = item.Quantity <= 0 ? 1 : item.Quantity;

				if (item.UnitPrice == 0)
					item.UnitPrice = Math.Round(item.UnitPrice, 2, MidpointRounding.AwayFromZero);

				if (item.TaxableAmount == 0)
                    item.TaxableAmount = item.UnitPrice * item.Quantity;

				if (item.TaxAmount == 0)
				{
                    item.TaxAmount = ((item.UnitPrice * item.TaxRate.Value) / 100) * item.Quantity;
                    item.TaxAmount = Math.Round(item.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				}

				if (item.ItemSubtotal == 0)
                    item.ItemSubtotal = Math.Round(item.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero) + Math.Round(item.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				//invInvoiceDetailsZatca.Add(invInvoiceDetailsZatcaItem);
			});

			invInvoiceDetailsUniformZatca = _mapper.Map<List<UniformDetail>>(invInvoiceDetails.Where(s => s.InvoiceType.ToLower().Contains("uniform")));

			//List<InvoicePayment> invInvoicePaymentsZatca = _mapper.Map<List<InvoicePayment>>(invInvoicePayments);


			if (string.IsNullOrEmpty(invInvoiceSummary.PaymentMethod))
			{
				if (invInvoicePayments.Any())
					invInvoiceSummary.PaymentMethod = invInvoicePayments.OrderByDescending(s => s.PaymentAmount).FirstOrDefault().PaymentMethod;
				else
					invInvoiceSummary.PaymentMethod = "cash"; // set default cash
			}

			if (string.IsNullOrEmpty(invInvoiceSummary.CustomerName))
			{
				invInvoiceSummary.CustomerName = invInvoiceSummary.ParentName;
			}

			var saveInvoiceSummaryZatca = await _iZatcaInvoiceSummaryManager.Save(invInvoiceSummary
				, invInvoiceDetails
                , invInvoiceDetailsUniformZatca
				, invInvoicePayments
				, invInvoiceSummary.InvoiceNo
				);

			//_logger.LogInformation($"Save Zatca data: saveInvoiceSummary:{JsonConvert.SerializeObject(saveInvoiceSummary)}");

			return saveInvoiceSummaryZatca.InvoiceId > 0;
		}
       
        private async Task<bool> CheckValidPayment(InvoiceSavePostedResponse invoiceSavePostedResponse, List<InvInvoiceDetail> invInvoiceDetails, List<InvInvoicePayment> invInvoicePayments)
		{
			var totalPayableAmount = invInvoiceDetails.Sum(s => Math.Round(s.ItemSubtotal, 0, MidpointRounding.AwayFromZero));
			var totalPaiAmount = invInvoicePayments.Sum(s => Math.Round(s.PaymentAmount, 0, MidpointRounding.AwayFromZero));

			if (totalPayableAmount != totalPaiAmount)
			{
				invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -2 }; // Payment not matching				
			}

			//Check all payment method records exsist in table.
			var isAllPaymentMethosExists = await _iPaymentMethodManager.IsAllPaymentMethosExists(invInvoicePayments.Select(s => s.PaymentMethod).ToList());
			if (!isAllPaymentMethosExists)
			{
				invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -13 }; // Payment not matching				
			}

			return invoiceSavePostedResponse.result == 0;
		}

		private async Task<bool> CheckValidParent(InvoiceSavePostedResponse invoiceSavePostedResponse,
			List<InvInvoiceDetail> invInvoiceDetails, List<InvInvoicePayment> invInvoicePayments,
			InvInvoiceSummaryModel invInvoiceSummaryModel)
		{
			bool isParenAccountNotAvailable = false;
			if (invInvoiceDetails.Any())
			{
				foreach (var item in invInvoiceDetails.Where(s => !string.IsNullOrEmpty(s.ParentId) && Convert.ToInt32(s.ParentId) > 0))
				{
					var recordAccount = await _iParentAccountManager.GetByParentId(Convert.ToInt32(item.ParentId));
					if (recordAccount == null)
					{
						isParenAccountNotAvailable = true;
						break;
					}
				}

				foreach (var item in invInvoiceDetails.Where(s => !string.IsNullOrEmpty(s.ParentId) && Convert.ToInt32(s.ParentId) > 0))
				{
					var recordAccount = await _iParentManager.GetById(Convert.ToInt32(item.ParentId));
					if (recordAccount != null)
					{
						item.ParentCode = recordAccount.ParentCode;
						if (item.IqamaNumber == null || string.IsNullOrEmpty(item.IqamaNumber))
						{
							item.IqamaNumber = recordAccount.FatherIqamaNo;
						}
					}
				}

				foreach (var item in invInvoiceDetails.Where(s => !string.IsNullOrEmpty(s.StudentId) && Convert.ToInt32(s.StudentId) > 0))
				{
					var recordAccount = await _iStudentManager.GetById(Convert.ToInt32(item.StudentId));
					if (recordAccount != null)
					{
						item.StudentCode = recordAccount.StudentCode;
					}
				}
			}
			var vatAccountNotAvaialble = await _iVATManager.IsAccountExist();
			var paymentMethodAccountNotAvaialble = await _iPaymentMethodManager.IsAccountExist();

			if (vatAccountNotAvaialble)
			{
				invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -11, message = "VAT Accounts Does Not exists." };
			}
			if (paymentMethodAccountNotAvaialble)
			{
				invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -12, message = "Payment account Does Not exists." };
			}

			var isUniformExists = invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("uniform"));
			var isEntranceExists = invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("entrance"));
			var isTuitionExists = invInvoiceDetails.Any(s => s.InvoiceType.ToLower().Contains("tuition"));

			if (isEntranceExists || isTuitionExists)
			{
				bool isInValidIqamaNumbExist = invInvoiceDetails.Any(s => string.IsNullOrEmpty(s.IqamaNumber) || string.IsNullOrWhiteSpace(s.IqamaNumber));
				if (isInValidIqamaNumbExist)
				{
					invoiceSavePostedResponse = new InvoiceSavePostedResponse() { result = -14, message = "Invalid iqama number." };
				}
			}

			var detailrecord = invInvoiceDetails.Where(s => !string.IsNullOrEmpty(s.IqamaNumber)).FirstOrDefault();
			if (detailrecord != null)
			{
				invInvoiceSummaryModel.IqamaNumber = detailrecord.IqamaNumber;
				invInvoiceSummaryModel.CustomerName = detailrecord.ParentName;
				invInvoiceSummaryModel.ParentId = detailrecord.ParentId;
			}

			if (string.IsNullOrEmpty(invInvoiceSummaryModel.IqamaNumber))
				invInvoiceSummaryModel.IqamaNumber = "";

			if (string.IsNullOrEmpty(invInvoiceSummaryModel.CustomerName))
				invInvoiceSummaryModel.CustomerName = "";

			if (string.IsNullOrEmpty(invInvoiceSummaryModel.ParentId))
				invInvoiceSummaryModel.ParentId = "0";

			return invoiceSavePostedResponse.result == 0;
		}
		#region Fee

		public async Task<IActionResult> InvoiceDetailEntranceFeeEditPartial(long invoiceNo, string invoiceSessionKey, string sessionKeyId)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			InvInvoiceDetailEntranceFeeModel invInvoiceDetailEntranceFeeModel = new InvInvoiceDetailEntranceFeeModel()
			{
				InvoiceNo = invoiceNo,
				InvoiceSessionKey = invoiceSessionKey,
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId,
			};

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
				{
					model.Quantity = model.Quantity == 0 ? 1 : model.Quantity;
					model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
					model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.ItemSubtotal = Math.Round(model.ItemSubtotal, 0, MidpointRounding.AwayFromZero);
					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailEntranceFeeModel>(model);
				}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}
			UpdateParentInfoForEntrance(SessionKeyTime, invInvoiceDetailEntranceFeeModel);

			return PartialView("_InvoiceDetailEntranceFeeEdit", invInvoiceDetailEntranceFeeModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailEntranceFeeEditPartial(InvInvoiceDetailEntranceFeeModel model)
		{
			InitDropdown();
			if (!model.Discount.HasValue)
			{
				model.Discount = 0;
			}
			if (!model.TaxRate.HasValue)
			{
				model.TaxRate = 0;
			}
			if (!model.TaxableAmount.HasValue)
			{
				model.TaxableAmount = 0;
			}
			if (!model.TaxAmount.HasValue)
			{
				model.TaxAmount = 0;
			}

			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				var dropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
				var academicYear = dropdown.FirstOrDefault(x => x.Value == model.AcademicYear);
				if (academicYear != null)
				{
					model.AcademicYearName = academicYear.Text;
				}

				model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
				model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

				//model.TaxableAmount = model.TaxableAmount;
				model.TaxAmount = model.TaxableAmount * model.TaxRate / 100;
				model.ItemSubtotal = model.TaxableAmount.Value + model.TaxAmount.Value - model.Discount.Value;

				model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.ItemSubtotal = Math.Round(model.ItemSubtotal, 0, MidpointRounding.AwayFromZero);
				model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

				if (InvoiceDetailModel == null)
				{
					invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
				}
				else if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoiceDetailList.Remove(invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
					invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
				}
				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				//return PartialView("_InvoiceDetailTuitionFeeEdit", invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey));
				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> InvoiceDetailUniformFeeEditPartial(long invoiceNo, string invoiceSessionKey, string sessionKeyId)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			var IsEditMode = !string.IsNullOrEmpty(sessionKeyId);
			InvInvoiceDetailUniformFeeModel invInvoiceDetailEntranceFeeModel = new InvInvoiceDetailUniformFeeModel()
			{
				InvoiceNo = invoiceNo,
				InvoiceSessionKey = invoiceSessionKey,
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId,
				IsEditMode = IsEditMode,
				Quantity = 1
			};
			string parentId = invInvoiceDetailEntranceFeeModel.ParentId;
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
				{
					model.Quantity = model.Quantity == 0 ? 1 : model.Quantity;
					model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
					model.TaxableAmount = Math.Round((model.UnitPrice * model.Quantity), 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailUniformFeeModel>(model);
					invInvoiceDetailEntranceFeeModel.IsEditMode = IsEditMode;
				}
				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}
			UpdateParentInfoForUniform(SessionKeyTime, invInvoiceDetailEntranceFeeModel);

			return PartialView("_InvoiceDetailUniformFeeEdit", invInvoiceDetailEntranceFeeModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailUniformFeeEditPartial(InvInvoiceDetailUniformFeeModel model)
		{
			InitDropdown();
			if (!model.Discount.HasValue)
			{
				model.Discount = 0;
			}
			if (!model.TaxRate.HasValue)
			{
				model.TaxRate = 0;
			}
			if (!model.TaxableAmount.HasValue)
			{
				model.TaxableAmount = 0;
			}
			if (!model.TaxAmount.HasValue)
			{
				model.TaxAmount = 0;
			}
			if (!string.IsNullOrEmpty(model.Description))
			{
				model.StudentName = model.Description;
			}
			if (string.IsNullOrEmpty(model.IqamaNumber))
			{
				model.IqamaNumber = string.Empty;
			}

			if (model.TaxRate.Value <= 0 && string.IsNullOrEmpty(model.IqamaNumber))
			{
				return Json(new { result = -3 });//IqamaNumber is required
			}
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (invInvoiceSummaryModel.InvoiceDetailList.Any(s => Convert.ToInt64(s.ParentId) > 0 && s.ParentId != model.ParentId))
				{
					return Json(new { result = -2 });
				}

				model.Quantity = model.Quantity == 0 ? 1 : model.Quantity;
				model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
				model.TaxableAmount = Math.Round((model.UnitPrice * model.Quantity), 2, MidpointRounding.AwayFromZero);
				model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

				model.TaxAmount = (Math.Round((model.UnitPrice * model.Quantity), 2, MidpointRounding.AwayFromZero)) * model.TaxRate / 100;
				model.ItemSubtotal = model.TaxableAmount.Value + model.TaxAmount.Value - model.Discount.Value;

				model.TaxableAmount = Math.Round((model.UnitPrice * model.Quantity), 2, MidpointRounding.AwayFromZero);
				model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
				model.ItemSubtotal = Math.Round(model.ItemSubtotal, 0, MidpointRounding.AwayFromZero);
				model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

				if (InvoiceDetailModel == null)
				{
					invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
				}
				else if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoiceDetailList.Remove(invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
					invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
				}

				invInvoiceSummaryModel.IqamaNumber = model.IqamaNumber;
				invInvoiceSummaryModel.CustomerName = model.ParentName;
				invInvoiceSummaryModel.ParentId = model.ParentId;

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		[HttpPost]
		public async Task<IActionResult> DeleteInvoiceDetail(InvInvoiceDetailUniformFeeModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoiceDetailList.Remove(invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
				}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> DeleteInvoicePayment(InvInvoicePaymentModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var InvoiceDetailModel = invInvoiceSummaryModel.InvoicePaymentList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoicePaymentList.Remove(invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
				}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> GetInvoiceCalculatedValue(long invoiceNo, string invoiceSessionKey)
		{
			InvInvoiceSummaryModel invInvoiceSummaryModel = new InvInvoiceSummaryModel();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
			}

			return Json(new
			{
				result = 0,
				Model = new
				{
					totalPaid = Math.Round(invInvoiceSummaryModel.TotalPaid, 0, MidpointRounding.AwayFromZero),
					taxableAmount = Math.Round(invInvoiceSummaryModel.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero),
					taxAmount = Math.Round(invInvoiceSummaryModel.TaxAmount.Value, 2, MidpointRounding.AwayFromZero),
					totalDiscount = Math.Round(invInvoiceSummaryModel.TotalDiscount, 0, MidpointRounding.AwayFromZero),
					itemSubtotal = Math.Round(invInvoiceSummaryModel.ItemSubtotal, 0, MidpointRounding.AwayFromZero),
					remainingAmount = Math.Round(invInvoiceSummaryModel.ItemSubtotal, 0, MidpointRounding.AwayFromZero) - Math.Round(invInvoiceSummaryModel.TotalPaid, 0, MidpointRounding.AwayFromZero),

					tototalInvoicePrice = Math.Round(invInvoiceSummaryModel.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero) - Math.Round(invInvoiceSummaryModel.TaxAmount.Value, 2, MidpointRounding.AwayFromZero),
					isUniformExists = invInvoiceSummaryModel.InvoiceDetailList.Any(s => s.InvoiceType.ToLower().Contains("uniform")),
					isEntranceExists = invInvoiceSummaryModel.InvoiceDetailList.Any(s => s.InvoiceType.ToLower().Contains("entrance")),
					isTuitionExists = invInvoiceSummaryModel.InvoiceDetailList.Any(s => s.InvoiceType.ToLower().Contains("tuition")),
				}
			});
		}
		#endregion Fee

		#region Uniform ItemCode
		public async Task<IActionResult> GetItemCodeRecords()
		{
			var dataSet = await _IInvoiceService.GetItemCodeRecords();

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		public async Task<IActionResult> GetUniformByItemCode(string itemCode, int nationalId = 0)
		{
			var dataSet = await _IInvoiceService.GetUniformByItemCode(itemCode, nationalId);

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		#endregion Uniform ItemCode

		#region TuitionFee
		public async Task<IActionResult> GetStudentByParentId(long parentId)
		{
			InitDropdown();
			var dataSet = await _IInvoiceService.GetStudentByParentId(parentId);

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		public async Task<IActionResult> GetStudentById(long studentId)
		{
			InitDropdown();
			var dataSet = await _IInvoiceService.GetStudentById(studentId);

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		public async Task<IActionResult> GetParentById(long parentId)
		{
			InitDropdown();
			var dataSet = await _IInvoiceService.GetParentById(parentId);

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		public async Task<IActionResult> GetVATDetail(string invoiceTypeName, int nationalId = 0)
		{
			VatDetailModel result = await _IInvoiceService.GetVATDetail(invoiceTypeName, nationalId);
			return Json(result);
		}

		public async Task<IActionResult> GetFeeAmount(long academicYearId, string invoiceTypeName, long studentId = 0)
		{
			InvoiceFeeDetailModel result = await _IInvoiceService.GetFeeAmount(academicYearId, studentId, invoiceTypeName);
			return Json(result);
		}

		public async Task<IActionResult> GetFeeAmountParentStudent(long academicYearId, string invoiceTypeName, long parentid = 0)
		{
			List<InvoiceFeeDetailParentStudentModel> result = await _IInvoiceService.GetFeeAmountParentStudent(academicYearId, parentid, invoiceTypeName);
			return Json(result);
		}

		// change this function to allow user to put amount for advance year
		public async Task<IActionResult> GetAcademicYearInfo(int academicYearId)
		{
			var recordAccount = await _iSchoolAcademicManager.IsAdvanceAcademic(academicYearId);
			var successResult = recordAccount != null ? 1 : 0;
			return Json(new { isSuccess = true, successResult });
		}

		#endregion TuitionFee

		#region Tuition Fee new and Old
		public async Task<IActionResult> InvoiceDetailTuitionFeeParentwiseEdit(long invoiceNo, string invoiceSessionKey, string sessionKeyId)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);

			InvInvoiceDetailTuitionFeeModel invInvoiceDetailEntranceFeeModel = new InvInvoiceDetailTuitionFeeModel()
			{
				InvoiceNo = invoiceNo,
				InvoiceSessionKey = invoiceSessionKey,
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId
			};
			string parentId = invInvoiceDetailEntranceFeeModel.ParentId;
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
				{
					model.Quantity = model.Quantity == 0 ? 1 : model.Quantity;
					model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
					model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailTuitionFeeModel>(model);
				}

				UpdateParentInfoForTuition(SessionKeyTime, invInvoiceDetailEntranceFeeModel);

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return PartialView("_InvoiceDetailTuitionFeeParentwiseEdit", invInvoiceDetailEntranceFeeModel);
		}
		public async Task<IActionResult> InvoiceDetailTuitionFeeEditPartial(long invoiceNo, string invoiceSessionKey, string sessionKeyId)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);

			InvInvoiceDetailTuitionFeeModel invInvoiceDetailEntranceFeeModel = new InvInvoiceDetailTuitionFeeModel()
			{
				InvoiceNo = invoiceNo,
				InvoiceSessionKey = invoiceSessionKey,
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId
			};
			string parentId = invInvoiceDetailEntranceFeeModel.ParentId;
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
				{
					model.Quantity = model.Quantity == 0 ? 1 : model.Quantity;
					model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
					model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailTuitionFeeModel>(model);
				}

				UpdateParentInfoForTuition(SessionKeyTime, invInvoiceDetailEntranceFeeModel);

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return PartialView("_InvoiceDetailTuitionFeeEdit", invInvoiceDetailEntranceFeeModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailTuitionFeeEditPartial(InvInvoiceDetailTuitionFeeModel model)
		{
			InitDropdown();
			try
			{
				if (!model.Discount.HasValue)
				{
					model.Discount = 0;
				}
				if (!model.TaxRate.HasValue)
				{
					model.TaxRate = 0;
				}
				if (!model.TaxableAmount.HasValue)
				{
					model.TaxableAmount = 0;
				}
				if (!model.TaxAmount.HasValue)
				{
					model.TaxAmount = 0;
				}

				string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

				if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
				{
					var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
					var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
						.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

					var parentRecord = await _iParentManager.GetById(Convert.ToInt64(model.ParentId));
					if (parentRecord != null)
					{
						model.ParentName = parentRecord.FatherName;
						model.ParentCode = parentRecord.ParentCode;
					}
					var studentRecord = await _iStudentManager.GetById(Convert.ToInt64(model.StudentId));
					if (studentRecord != null)
					{
						model.StudentName = studentRecord.StudentName;
						model.StudentCode = studentRecord.StudentCode;
					}

					var dropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
					var academicYear = dropdown.FirstOrDefault(x => x.Value == model.AcademicYear);
					if (academicYear != null)
					{
						model.AcademicYearName = academicYear.Text;
					}

					if (invInvoiceSummaryModel.InvoiceDetailList.Any(s => !string.IsNullOrEmpty(s.ParentId) && s.ParentId.Trim().Length > 0 && s.ParentId != model.ParentId))
					{
						return Json(new { result = -2 });
					}

					model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
					model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

					model.TaxableAmount = model.UnitPrice;
					model.TaxAmount = model.TaxableAmount * model.TaxRate / 100;
					model.ItemSubtotal = model.TaxableAmount.Value + model.TaxAmount.Value - model.Discount.Value;

					model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
					model.ItemSubtotal = Math.Round(model.ItemSubtotal, 0, MidpointRounding.AwayFromZero);
					model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

					if (InvoiceDetailModel == null)
					{
						invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
					}
					else if (InvoiceDetailModel != null)
					{
						invInvoiceSummaryModel.InvoiceDetailList.Remove(invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
						invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
					}
					HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

					return Json(new { result = 0 });
				}
			}
			catch (Exception ex)
			{
			}
			return Json(new { result = -1 });
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailTuitionFeeEditList(InvInvoiceDetailTuitionNewSaveFeeModel modelTuition)
		{
			InitDropdown();
			try
			{
				modelTuition.TuitionFeeList = modelTuition.TuitionFeeList.Where(s => s.ItemSubtotal > 0).ToList();

				foreach (var item in modelTuition.TuitionFeeList)
				{
					if (!item.Discount.HasValue)
					{
						item.Discount = 0;
					}
					if (!item.TaxRate.HasValue)
					{
						item.TaxRate = 0;
					}
					if (!item.TaxableAmount.HasValue)
					{
						item.TaxableAmount = 0;
					}
					if (!item.TaxAmount.HasValue)
					{
						item.TaxAmount = 0;
					}
				}

				string SessionKeyTime = GetSessionKey(modelTuition.InvoiceNo, modelTuition.InvoiceSessionKey);

				if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
				{
					var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
					foreach (var model in modelTuition.TuitionFeeList)
					{
						var newSessionKey = Guid.NewGuid().ToString();

						model.InvoiceNo = modelTuition.InvoiceNo;
						model.InvoiceSessionKey = modelTuition.InvoiceSessionKey;
						model.SessionKey = newSessionKey;

						var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
						.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

						var parentRecord = await _iParentManager.GetById(Convert.ToInt64(model.ParentId));
						if (parentRecord != null)
						{
							model.ParentName = parentRecord.FatherName;
							model.ParentCode = parentRecord.ParentCode;
						}
						var studentRecord = await _iStudentManager.GetById(Convert.ToInt64(model.StudentId));
						if (studentRecord != null)
						{
							model.StudentName = studentRecord.StudentName;
							model.StudentCode = studentRecord.StudentCode;
						}

						//var dropdown = await GetAppDropdown(AppDropdown.AcadmicYear, true);
						//var academicYear = dropdown.FirstOrDefault(x => x.Value == model.AcademicYear);
						//if (academicYear != null)
						//{
						//	model.AcademicYearName = academicYear.Text;
						//}

						if (invInvoiceSummaryModel.InvoiceDetailList.Any(s => !string.IsNullOrEmpty(s.ParentId) && s.ParentId.Trim().Length > 0 && s.ParentId != model.ParentId))
						{
							return Json(new { result = -2 });
						}

						model.UnitPrice = Math.Round(model.UnitPrice, 2, MidpointRounding.AwayFromZero);
						model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
						model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
						model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

						model.TaxableAmount = model.UnitPrice;
						model.TaxAmount = model.TaxableAmount * model.TaxRate / 100;
						//model.ItemSubtotal = model.TaxableAmount.Value + model.TaxAmount.Value - model.Discount.Value;
						model.ItemSubtotal = model.TaxableAmount.Value + model.TaxAmount.Value;

						model.TaxableAmount = Math.Round(model.TaxableAmount.Value, 2, MidpointRounding.AwayFromZero);
						model.TaxAmount = Math.Round(model.TaxAmount.Value, 2, MidpointRounding.AwayFromZero);
						model.ItemSubtotal = Math.Round(model.ItemSubtotal, 0, MidpointRounding.AwayFromZero);
						model.Discount = Math.Round(model.Discount.Value, 0, MidpointRounding.AwayFromZero);

						if (InvoiceDetailModel == null)
						{
							invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
						}
						else if (InvoiceDetailModel != null)
						{
							invInvoiceSummaryModel.InvoiceDetailList.Remove(invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
							invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(model));
						}
					}
					HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

					return Json(new { result = 0 });
				}

			}
			catch (Exception ex)
			{
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> ClearInvoiceLineItems(long invoiceNo, string invoiceSessionKey, string sessionKeyId)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				invInvoiceSummaryModel.InvoiceDetailList.Clear();

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return Json(new { result = 0 });
		}
		#endregion

		#endregion Invoice Action

		#region Invoice Refund
		public async Task InitializeRefundDropdown()
		{
			var lst = await _iPaymentMethodManager.GetList();

			List<SelectListItem> selectList = new List<SelectListItem>();

			if (lst != null && lst.Any())
			{
				selectList = lst.Select(s =>
				new SelectListItem()
				{
					Value = s.PaymentMethodName,
					Text = s.PaymentMethodName
				}
				).ToList();
			}

			ViewBag.PaymentMethodDropdownList = selectList;
		}
		public async Task<IActionResult> AddEditInvoiceRefund(long invoiceNo, long invoiceRefundRefNo)
		{
			await InitializeRefundDropdown();

			Guid sessionKeyId = Guid.NewGuid();
			string SessionKeyTime = GetSessionKey(invoiceNo, sessionKeyId.ToString());

			InvInvoiceSummaryRefundModel invInvoiceSummaryModel = new InvInvoiceSummaryRefundModel()
			{
				InvoiceSessionKey = SessionKeyTime,
				InvoiceRefNo = invoiceRefundRefNo,
				InvoiceDate = DateTime.Now,
				InvoiceNo = invoiceNo,
				InvoiceType = "Return",
			};

			//var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
			//if (invoiceNoSummaryRecord != null)
			//	invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				//HttpContext.Session.Set<DateTime>(SessionKeyTime, currentTime);
			}
			if (invoiceNo > 0)
			{
				var invoiceSummary = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
				invInvoiceSummaryModel = _mapper.Map<InvInvoiceSummaryRefundModel>(invoiceSummary);
			}
			if (invoiceRefundRefNo > 0)
			{
				var invoiceRefSummary = await _iInvSummaryManager.GetByInvoiceNo(invoiceRefundRefNo);
				var invoiceRefDetails = await _iInvInvoiceDetailManager.GetAllByInvoiceNo(invoiceRefundRefNo);
				var invoiceRefPayments = await _iInvInvoicePaymentManager.GetAllByInvoiceNo(invoiceRefundRefNo);

				var detailList = _mapper.Map<List<InvInvoiceDetailyRefundModel>>(invoiceRefDetails);
				var paymentList = _mapper.Map<List<InvInvoicePaymentyRefundModel>>(invoiceRefPayments);

				detailList.ForEach(s =>
				{
					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceRefNo = invoiceRefundRefNo;
					s.InvoiceNo = invoiceNo;

					s.InvoiceDetailRefId = s.InvoiceDetailId;

					s.RefundableDiscount = s.Discount;
					s.RefundableItemSubtotal = s.ItemSubtotal;
					s.RefundableQuantity = s.Quantity;
					s.RefundableTaxableAmount = s.TaxableAmount;
					s.RefundableTaxAmount = s.TaxAmount;
					s.RefundableTaxRate = s.TaxRate;
				});

				paymentList.ForEach(s =>
				{
					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceRefNo = invoiceRefundRefNo;
					s.InvoiceNo = invoiceNo;

					s.InvoicePaymentRefId = s.InvoicePaymentId;

					s.RefundablePaymentAmount = s.PaymentAmount;
					s.OriginalPaymentMethod = s.PaymentMethod;
				});

				#region Refunded records

				var invoiceRefundedDetails = await _iInvInvoiceDetailManager.GetAllByInvoiceRefNo(invoiceRefundRefNo, invoiceNo);
				var invoiceefundedPayments = await _iInvInvoicePaymentManager.GetAllByInvoiceRefNo(invoiceRefundRefNo, invoiceNo);

				detailList.ForEach(s =>
				{
					var refundedDetail = invoiceRefundedDetails.Where(k => k.InvoiceDetailRefId == s.InvoiceDetailId);

					s.RefundedDiscount = refundedDetail.Sum(k => k.Discount);
					s.RefundedItemSubtotal = refundedDetail.Sum(k => k.ItemSubtotal);
					s.RefundedQuantity = refundedDetail.Sum(k => k.Quantity);
					s.RefundedTaxableAmount = refundedDetail.Sum(k => k.TaxableAmount);
					s.RefundedTaxAmount = refundedDetail.Sum(k => k.TaxAmount);
					//s.RefundedTaxRate = invoiceRefundedDetails.Where(k => k.InvoiceNo != invoiceNo && !k.IsDeleted).Sum(k => k.TaxRate);
					s.RefundedTaxRate = s.TaxRate;
				});

				paymentList.ForEach(s =>
				{
					var refundedAmount = invoiceefundedPayments.Where(k => k.InvoicePaymentRefId == s.InvoicePaymentId).Sum(k => k.PaymentAmount);

					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceNo = invoiceRefundRefNo;

					s.RefundedPaymentAmount = refundedAmount;
				});
				#endregion Refunded records

				#region Current Invoice record
				//Set items record for invoice no in edit mode
				var invoiceCurrentDetails = invoiceNo > 0 ? await _iInvInvoiceDetailManager.GetAllByInvoiceNo(invoiceNo) : new List<InvInvoiceDetail>();
				var invoiceCurrentPayments = invoiceNo > 0 ? await _iInvInvoicePaymentManager.GetAllByInvoiceNo(invoiceNo) : new List<InvInvoicePayment>();

				detailList.ForEach(s =>
				{
					var currentDetail = invoiceCurrentDetails.Where(k => k.InvoiceNo == invoiceNo && k.InvoiceRefNo == s.InvoiceRefNo
					&& k.InvoiceDetailRefId == s.InvoiceDetailId && !k.IsDeleted);

					s.Discount = currentDetail.Sum(k => k.Discount);
					s.ItemSubtotal = currentDetail.Sum(k => k.ItemSubtotal);
					s.Quantity = currentDetail.Sum(k => k.Quantity);
					s.TaxableAmount = currentDetail.Sum(k => k.TaxableAmount);
					s.TaxAmount = currentDetail.Sum(k => k.TaxAmount);
				});

				paymentList.ForEach(s =>
				{
					var currectPayments = invoiceCurrentPayments.Where(k => k.InvoiceNo == invoiceNo && k.InvoiceRefNo == s.InvoiceRefNo
					&& k.InvoicePaymentRefId == s.InvoicePaymentId && !k.IsDeleted).ToList();

					var currectPaymentAmount = currectPayments.Sum(k => k.PaymentAmount);
					var currectPaymentMethod = currectPayments.FirstOrDefault()?.PaymentMethod;
					var currectPaymentReferenceNumber = currectPayments.FirstOrDefault()?.PaymentReferenceNumber;

					s.SessionKey = Guid.NewGuid().ToString();
					s.InvoiceSessionKey = invInvoiceSummaryModel.InvoiceSessionKey;
					s.InvoiceRefNo = invoiceRefundRefNo;
					s.InvoiceNo = invoiceNo;

					s.PaymentAmount = currectPaymentAmount;
					s.PaymentMethod = string.IsNullOrWhiteSpace(currectPaymentMethod) ? s.OriginalPaymentMethod : currectPaymentMethod;
					s.PaymentReferenceNumber = currectPaymentReferenceNumber;
				});

				#endregion Current Invoice record

				invInvoiceSummaryModel.RefundableItemSubtotal = invoiceRefSummary.ItemSubtotal;
				invInvoiceSummaryModel.RefundableTaxableAmount = invoiceRefSummary.ItemSubtotal;
				invInvoiceSummaryModel.RefundableTaxAmount = invoiceRefSummary.TaxAmount;
				invInvoiceSummaryModel.RefundableTotalPaid = paymentList.Sum(s => s.PaymentAmount);
				invInvoiceSummaryModel.RefundableTotalDiscount = detailList.Sum(s => s.Discount.HasValue ? s.Discount.Value : 0);

				invInvoiceSummaryModel.InvoiceDetailList = detailList;
				invInvoiceSummaryModel.InvoicePaymentList = paymentList;
			}

			HttpContext.Session.Set<InvInvoiceSummaryRefundModel>(SessionKeyTime, invInvoiceSummaryModel);

			return View(invInvoiceSummaryModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailRefundDataPartial(long invoiceNo, string invoiceSessionKey)
		{
			await InitializeRefundDropdown();

			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			List<InvInvoiceDetailyRefundModel> invoiceDetailList = new List<InvInvoiceDetailyRefundModel>();

			InvInvoiceSummaryRefundModel invInvoiceSummaryModel = new InvInvoiceSummaryRefundModel()
			{
				InvoiceSessionKey = SessionKeyTime,
				InvoiceDate = DateTime.Now,
				InvoiceNo = invoiceNo,
				InvoiceType = "Return"
			};
			var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
			if (invoiceNoSummaryRecord != null)
				invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
				invoiceDetailList = _mapper.Map<List<InvInvoiceDetailyRefundModel>>(invInvoiceSummaryModel.InvoiceDetailList);
			}

			return PartialView("_InvoiceDetailRefundDataPartial", invInvoiceSummaryModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoicePaymentRefundDataPartial(long invoiceNo, string invoiceSessionKey)
		{
			await InitializeRefundDropdown();

			string SessionKeyTime = GetSessionKey(invoiceNo, invoiceSessionKey);
			InvInvoiceSummaryRefundModel invInvoiceSummaryModel = new InvInvoiceSummaryRefundModel()
			{
				InvoiceSessionKey = SessionKeyTime,
				InvoiceDate = DateTime.Now,
				InvoiceNo = invoiceNo,
				InvoiceType = "Return",
				InvoicePaymentList = new List<InvInvoicePaymentyRefundModel>(),
				InvoiceDetailList = new List<InvInvoiceDetailyRefundModel>()
			};

			var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(invoiceNo);
			if (invoiceNoSummaryRecord != null)
				invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;

			List<InvInvoicePaymentyRefundModel> invoiceDetailList = new List<InvInvoicePaymentyRefundModel>();
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
				invoiceDetailList = invInvoiceSummaryModel.InvoicePaymentList;
			}

			if (invInvoiceSummaryModel.InvoicePaymentList == null)
			{
				invInvoiceSummaryModel.InvoicePaymentList = new List<InvInvoicePaymentyRefundModel>();
			}

				return PartialView("_InvoicePaymentRefundDataPartial", invInvoiceSummaryModel);
		}

		[HttpPost]
		public async Task<IActionResult> RefundQuantity(InvInvoiceDetailRefundModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel != null && InvoiceDetailModel.AvailableQuantity >= model.Quantity)
				{
					var recordData = invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey);

					recordData.Quantity = model.Quantity;

					if (model.Quantity > 0 && recordData.RefundableQuantity > 0)
					{
						recordData.ItemSubtotal = Math.Round((recordData.AvailableItemSubtotal * model.Quantity / recordData.RefundableQuantity), 2, MidpointRounding.AwayFromZero);
						recordData.Discount = Math.Round((recordData.AvailableDiscount.Value * model.Quantity / recordData.RefundableQuantity), 2, MidpointRounding.AwayFromZero);
						recordData.TaxableAmount = Math.Round((recordData.RefundableTaxableAmount.Value * model.Quantity / recordData.RefundableQuantity), 2, MidpointRounding.AwayFromZero);
						recordData.TaxAmount = Math.Round((recordData.RefundableTaxAmount.Value * model.Quantity / recordData.RefundableQuantity), 2, MidpointRounding.AwayFromZero);
					}
					HttpContext.Session.Set<InvInvoiceSummaryRefundModel>(SessionKeyTime, invInvoiceSummaryModel);
					return Json(new { result = 0, recordData });
				}
				else
				{
					return Json(new { result = -2 });
				}
			}
			return Json(new { result = -1 });
		}

		[HttpPost]
		public async Task<IActionResult> RefundAmount(InvInvoiceDetailRefundModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel != null)
				{
					if (InvoiceDetailModel.AvailableItemSubtotal >= model.Amount)
					{
						var invoiceDetailListRecord = invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey);
						invoiceDetailListRecord.ItemSubtotal = model.Amount;
						invoiceDetailListRecord.TaxableAmount = model.Amount;

						HttpContext.Session.Set<InvInvoiceSummaryRefundModel>(SessionKeyTime, invInvoiceSummaryModel);
						return Json(new { result = 0 });
					}
					else
					{
						return Json(new { result = -2 });
					}
				}
			}
			return Json(new { result = -1 });
		}

		[HttpPost]
		public async Task<IActionResult> RefundPayment(InvInvoiceDetailRefundModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoicePaymentList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel != null)
				{
					var totalRefundableItemSubtotal = invInvoiceSummaryModel.InvoiceDetailList.Sum(s => s.ItemSubtotal);
					var totalRefundablePaymentAmount = invInvoiceSummaryModel.InvoicePaymentList
						.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey != model.SessionKey).Sum(s => s.PaymentAmount);

					if ((totalRefundablePaymentAmount + model.Amount) > totalRefundableItemSubtotal)
					{
						return Json(new { result = -3 });
					}
					else if (InvoiceDetailModel.AvailablePaymentAmount >= model.Amount)
					{
						invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).PaymentAmount = model.Amount;
						invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).PaymentMethod = model.PaymentMethod;
						invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).PaymentReferenceNumber = model.PaymentReferenceNumber;

						HttpContext.Session.Set<InvInvoiceSummaryRefundModel>(SessionKeyTime, invInvoiceSummaryModel);
						return Json(new { result = 0 });
					}
					else
					{
						return Json(new { result = -2 });
					}
				}
			}
			return Json(new { result = -1 });
		}

		[HttpPost]
		public async Task<IActionResult> RefundInvoiceSave(InvInvoiceSaveRefundModel model)
		{
			return await SaveReturn(model, "Saved");
		}

		[HttpPost]
		public async Task<IActionResult> RefundInvoicePost(InvInvoiceSaveRefundModel model)
		{
            return await PostRefundZatca(model, "Posted");
           // return await SaveReturn(model, "Posted");
		}

		private async Task<IActionResult> SaveReturn(InvInvoiceSaveRefundModel model, string status = "Saved")
		{
			try
			{
				string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

				if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
				{
					var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryRefundModel>(SessionKeyTime);
					invInvoiceSummaryModel.InvoiceDetailList = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.ItemSubtotal > 0).ToList();
					invInvoiceSummaryModel.InvoicePaymentList = invInvoiceSummaryModel.InvoicePaymentList.Where(s => s.PaymentAmount > 0).ToList();

					if (model.InvoiceDate != DateTime.MinValue)
					{
						invInvoiceSummaryModel.InvoiceDate = model.InvoiceDate;
					}

					long latestInvoiceno = model.InvoiceNo;
					if (invInvoiceSummaryModel.InvoiceNo <= 0)
					{
						//latestInvoiceno = await _IInvoiceService.GetLatestInvoice();
						invInvoiceSummaryModel.InvoiceDate = (!model.InvoiceDate.HasValue && model.InvoiceDate != DateTime.MinValue) ? DateTime.Now : model.InvoiceDate;
					}
					else
					{
						var invoiceNoSummaryRecord = await _iInvSummaryManager.GetByInvoiceNo(model.InvoiceNo);
						//if (invoiceNoSummaryRecord != null )
						if (invoiceNoSummaryRecord != null && model.InvoiceDate == DateTime.MinValue)
							invInvoiceSummaryModel.InvoiceDate = invoiceNoSummaryRecord.InvoiceDate;
						else
							invInvoiceSummaryModel.InvoiceDate = (!model.InvoiceDate.HasValue && model.InvoiceDate != DateTime.MinValue) ? DateTime.Now : model.InvoiceDate;
					}

					invInvoiceSummaryModel.InvoiceNo = latestInvoiceno;

					invInvoiceSummaryModel.CreditNo = model.CreditNo;
					invInvoiceSummaryModel.CreditReason = model.CreditReason;
					invInvoiceSummaryModel.CustomerName = model.CustomerName;

					List<InvInvoiceDetail> invInvoiceDetails = _mapper.Map<List<InvInvoiceDetail>>(invInvoiceSummaryModel.InvoiceDetailList);
					List<InvInvoicePayment> invInvoicePayments = _mapper.Map<List<InvInvoicePayment>>(invInvoiceSummaryModel.InvoicePaymentList);

					if(invInvoicePayments.Any(s=>string.IsNullOrEmpty(s.PaymentReferenceNumber)))
					{
						return Json(new { result = -9 });
					}

					//Is Payment amount is not same as detail item sub totla then show error

					var totalPayableAmount = invInvoiceDetails.Sum(s => s.ItemSubtotal);
					var totalPaiAmount = invInvoicePayments.Sum(s => s.PaymentAmount);

					if (totalPayableAmount != totalPaiAmount)
					{
						return Json(new { result = -2 });
					}
					var invoiceSavePostedResponse = new InvoiceSavePostedResponse();
                    
                    foreach (var item in invInvoiceDetails)
					{
						if (item.Quantity <= 0)
						{
							item.Quantity = 1;
						}
						decimal unitprice = item.ItemSubtotal;

						if (item.TaxRate.HasValue)
							unitprice = item.ItemSubtotal / (1 + item.TaxRate.Value / 100);

						item.UnitPrice = Math.Round(unitprice, 2, MidpointRounding.AwayFromZero);
						item.TaxAmount = item.ItemSubtotal - item.UnitPrice;
						item.TaxableAmount = item.UnitPrice;

						item.UnitPrice = item.UnitPrice / item.Quantity;

						item.AcademicYear = string.IsNullOrEmpty(item.AcademicYear) ? string.Empty : item.AcademicYear;
						item.InvoiceNo = latestInvoiceno;
						item.UpdateDate = DateTime.Now.Date;
						item.UpdateBy = Convert.ToInt32(GetUserDataFromClaims("UserId"));
					}
					foreach (var item in invInvoicePayments)
					{
						item.InvoiceNo = latestInvoiceno;
						item.UpdateDate = DateTime.Now.Date;
						item.UpdateBy = Convert.ToInt32(GetUserDataFromClaims("UserId"));
					}

                    var detailrecord = invInvoiceDetails.Where(s => !string.IsNullOrEmpty(s.IqamaNumber)).FirstOrDefault();
                    if (detailrecord != null)
                    {
                        invInvoiceSummaryModel.IqamaNumber = detailrecord.IqamaNumber;
                        invInvoiceSummaryModel.CustomerName = detailrecord.ParentName;
                        invInvoiceSummaryModel.ParentId = detailrecord.ParentId;
                    }
					if (string.IsNullOrEmpty(invInvoiceSummaryModel.IqamaNumber))
					{
                        invInvoiceSummaryModel.IqamaNumber = invInvoiceSummaryModel.InvoiceDetailList.Where(s => !string.IsNullOrEmpty(s.IqamaNumber)).Select(s => s.IqamaNumber).FirstOrDefault();
                    }
                    if (string.IsNullOrEmpty(invInvoiceSummaryModel.ParentId))
                    {
                        invInvoiceSummaryModel.ParentId = invInvoiceSummaryModel.InvoiceDetailList.Where(s => !string.IsNullOrEmpty(s.ParentId)).Select(s => s.ParentId).FirstOrDefault();
                    }

                    //invInvoiceSummaryModel.IqamaNumber = string.IsNullOrEmpty(invInvoiceSummaryModel.IqamaNumber) ? string.Empty : invInvoiceSummaryModel.IqamaNumber;

					//invInvoiceSummaryModel.ParentId = invInvoiceSummaryModel.InvoiceDetailList.Where(s => !string.IsNullOrEmpty(s.ParentId)).Select(s => s.ParentId).FirstOrDefault();
					//invInvoiceSummaryModel.ParentId = string.IsNullOrEmpty(invInvoiceSummaryModel.ParentId) ? string.Empty : invInvoiceSummaryModel.ParentId;

					invInvoiceSummaryModel.Status = status;
					invInvoiceSummaryModel.PublishedBy = GetUserDataFromClaims("UserId");

					//Set these values
					//invInvoiceSummaryModel.TaxableAmount = invInvoiceSummaryModel.InvoiceDetailList.Sum(s => s.TaxableAmount);
					invInvoiceSummaryModel.TaxAmount = invInvoiceDetails.Sum(s => s.TaxAmount);
					invInvoiceSummaryModel.ItemSubtotal = invInvoiceDetails.Sum(s => s.ItemSubtotal);
					invInvoiceSummaryModel.TaxableAmount = invInvoiceSummaryModel.ItemSubtotal - invInvoiceSummaryModel.TaxAmount;

					invInvoiceSummaryModel.InvoiceType = "Return";
					invInvoiceSummaryModel.InvoiceRefNo = invInvoiceSummaryModel.InvoiceRefNo;

					InvInvoiceSummary invInvoiceSummary = _mapper.Map<InvInvoiceSummary>(invInvoiceSummaryModel);

					var totalPaymentReceived = invInvoicePayments.Sum(s => s.PaymentAmount);
					if (totalPaymentReceived <= 0)
					{
						return Json(new { result = -2 });
					}

					////sp_GetInvoiceNo
					//var saveInvoiceSummary = await _iInvSummaryManager.Save(invInvoiceSummary);
					//foreach (var item in invInvoiceDetails)
					//{
					//	item.InvoiceRefNo = invInvoiceSummary.InvoiceRefNo;
					//	item.InvoiceDetailRefId = item.InvoiceDetailId;
					//	item.InvoiceDetailId = 0;
					//}
					//foreach (var item in invInvoicePayments)
					//{
					//	item.InvoicePaymentRefId = item.InvoicePaymentId;
					//	item.InvoicePaymentId = 0;
					//	item.InvoiceRefNo = invInvoiceSummary.InvoiceRefNo;
					//}
					//await _iInvInvoiceDetailManager.SaveRange(invInvoiceDetails, invInvoiceSummary.InvoiceNo);

					//invInvoicePayments = invInvoicePayments.Where(s => s.PaymentAmount > 0).ToList();
					//await _iInvInvoicePaymentManager.SaveRange(invInvoicePayments, invInvoiceSummary.InvoiceNo);

					#region update return payment method id

					var lstPaymentMethod = await _iPaymentMethodManager.GetList();

					foreach (var item in invInvoicePayments)
					{
						var matchingRecord = lstPaymentMethod.FirstOrDefault(s => s.PaymentMethodName.Trim().ToLower() == item.PaymentMethod.Trim().ToLower());
						if (matchingRecord != null)
						{
							item.PaymentMethodId = matchingRecord.PaymentMethodId;
						}
					}

					#endregion update return payment method id

					var saveInvoiceSummary = await _iInvSummaryManager.SaveInvoice(status, invInvoiceSummary, invInvoiceDetails, invInvoicePayments);

					_logger.LogInformation($"Save ALS Live: saveInvoiceSummary:{JsonConvert.SerializeObject(saveInvoiceSummary)}");

					if (invInvoiceSummary.InvoiceNo <= 0)
					{
						return Json(new { result = -1 });
					}
					else
					{
						//Update session for invoice no, so that if save again then latest invoice number available
						invInvoiceSummaryModel.InvoiceNo = invInvoiceSummary.InvoiceNo;
						invInvoiceSummaryModel.InvoiceRefNo = invInvoiceSummary.InvoiceRefNo.HasValue ? invInvoiceSummary.InvoiceRefNo.Value : 0;

						HttpContext.Session.Set<InvInvoiceSummaryRefundModel>(SessionKeyTime, invInvoiceSummaryModel);
					}
					ProcessGPAndStatement(invInvoiceSummary.InvoiceNo, status);

					////Add record to zatca
					//if (status == "Posted")
					//{
					//	bool zatcaSaved = await UpdateZatcaProperty(invInvoiceSummary, invInvoiceDetails, invInvoicePayments);
					//	if (!zatcaSaved)
					//	{
					//		var invoiceRecord = await _iInvSummaryManager.GetById(invInvoiceSummary.InvoiceId);
					//		if (invoiceRecord != null)
					//		{
					//			invoiceRecord.Status = "Saved";
					//			await _iInvSummaryManager.Save(invoiceRecord);
					//			return Json(new { result = -3 });// No invoice record found
					//		}
					//	}
					//	else
					//	{
					//		try
					//		{
					//			//Call to process for invoice pdf
					//			using (var client = new HttpClient())
					//			{
					//				var jsonObject = new
					//				{
					//					invoiceNo = invInvoiceSummary.InvoiceNo
					//				};

					//				var invoicePostUrl = _ZatcaAppSettingConfig.Value.ZatcaPostInvoiceUrl;

					//				_logger.LogInformation($"Save Calling Zatca: URL:{invoicePostUrl},  jsonObject:{JsonConvert.SerializeObject(jsonObject)}");

					//				//var content = new StringContent(jsonObject.ToString(), Encoding.UTF8, "application/json");
					//				// Make the GET request to the API endpoint
					//				client.Timeout = TimeSpan.FromSeconds(200);
					//				var response = client.PostAsJsonAsync(invoicePostUrl, jsonObject).Result;

					//				// Read the response as a stream
					//				var responseStream = response.Content.ReadAsStreamAsync().Result;

					//				var stringRespont = StreamToString(responseStream);

					//				_logger.LogInformation($"Save Response from Zatca: URL:{invoicePostUrl},  response :{stringRespont}");

					//				if (response.StatusCode != HttpStatusCode.OK)
					//				{
					//					return Json(new { result = -4 });// Unable to process zatca
					//				}
					//				var zatcaResponse = JsonConvert.DeserializeObject<ZatcaResponseModel>(stringRespont);
					//				if (zatcaResponse != null && (!string.IsNullOrEmpty(zatcaResponse.QRImg) || !string.IsNullOrEmpty(zatcaResponse.PdfPath)))
					//				{
					//					var emailResult = await SendEmail(saveInvoiceSummary.InvoiceId, latestInvoiceno, zatcaResponse.PdfPath);
					//					if (!emailResult)
					//						return Json(new { result = -5 });// unable to send email
					//				}
					//				else
					//				{
					//					return Json(new { result = -6 });//Unbale to process zatca
					//				}
					//			}
					//		}
					//		catch (Exception ex)
					//		{
					//			_logger.LogError($"Exception Calling Zatca : Message :{JsonConvert.SerializeObject(ex)}");
					//			return Json(new { result = -7, message = ex.Message });// Exception in calling zatca
					//		}
					//	}
					//}

					HttpContext.Session.Remove(SessionKeyTime);
					return Json(new { result = 0 });
				}
				return Json(new { result = -1 });
			}
			catch (Exception ex)
			{
			}
			return Json(new { result = -1 });
		}

		#endregion  Invoice Refund

		#region Private function
		private string GetSessionKey(long invoiceNo, string invoiceSessionKey)
		{
			string SessionKeyTime = invoiceNo > 0 ? "Invoice_" + invoiceNo : invoiceSessionKey;
			return SessionKeyTime;
		}

		#region Update Info
		private BaseUserParentInfo GetParentInfoFromSession(string SessionKeyTime)
		{
			BaseUserParentInfo baseUserParentInfo = new BaseUserParentInfo();
			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var parentInfo = invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => !string.IsNullOrEmpty(s.ParentId)
			   && Convert.ToInt64(s.ParentId) > 0);

				if (parentInfo != null)
				{
					baseUserParentInfo = new BaseUserParentInfo();
					baseUserParentInfo.ParentId = parentInfo.ParentId;
					baseUserParentInfo.ParentCode = parentInfo.ParentCode;
					baseUserParentInfo.ParentName = parentInfo.ParentName;
					baseUserParentInfo.FatherMobile = parentInfo.FatherMobile;
					baseUserParentInfo.NationalityId = parentInfo.NationalityId;
					baseUserParentInfo.IsStaff = parentInfo.IsStaff;
					baseUserParentInfo.IqamaNumber = parentInfo.IqamaNumber;
					baseUserParentInfo.AcademicYear = parentInfo.AcademicYear;
				}

				if (parentInfo == null)
				{
					var parentInfoWithNoId = invInvoiceSummaryModel.InvoiceDetailList.FirstOrDefault(s => !string.IsNullOrEmpty(s.ParentName));
					if (parentInfoWithNoId != null)
					{
						baseUserParentInfo = new BaseUserParentInfo();
						baseUserParentInfo.ParentId = parentInfoWithNoId.ParentId;
						baseUserParentInfo.ParentCode = parentInfoWithNoId.ParentCode;
						baseUserParentInfo.ParentName = parentInfoWithNoId.ParentName;
						baseUserParentInfo.FatherMobile = parentInfoWithNoId.FatherMobile;
						baseUserParentInfo.NationalityId = parentInfoWithNoId.NationalityId;
						baseUserParentInfo.IsStaff = parentInfoWithNoId.IsStaff;
						baseUserParentInfo.IqamaNumber = parentInfoWithNoId.IqamaNumber;
                        baseUserParentInfo.AcademicYear = parentInfoWithNoId.AcademicYear;
                    }
				}

			}
			return baseUserParentInfo;
		}
		private void UpdateParentInfoForUniform(string SessionKeyTime, InvInvoiceDetailUniformFeeModel invInvoiceDetailEntranceFeeModel)
		{
			var parentInfo = GetParentInfoFromSession(SessionKeyTime);
			if (parentInfo != null)
			{
				invInvoiceDetailEntranceFeeModel.ParentId = parentInfo.ParentId;
				invInvoiceDetailEntranceFeeModel.ParentCode = parentInfo.ParentCode;
				invInvoiceDetailEntranceFeeModel.ParentName = parentInfo.ParentName;
				invInvoiceDetailEntranceFeeModel.FatherMobile = parentInfo.FatherMobile;
				invInvoiceDetailEntranceFeeModel.NationalityId = parentInfo.NationalityId;
				//invInvoiceDetailEntranceFeeModel.IsStaff = parentInfo.IsStaff;
				invInvoiceDetailEntranceFeeModel.IqamaNumber = parentInfo.IqamaNumber;
			}
		}
		private void UpdateParentInfoForEntrance(string SessionKeyTime, InvInvoiceDetailEntranceFeeModel invInvoiceDetailEntranceFeeModel)
		{
			var parentInfo = GetParentInfoFromSession(SessionKeyTime);
			if (parentInfo != null)
			{
				invInvoiceDetailEntranceFeeModel.ParentId = parentInfo.ParentId;
				invInvoiceDetailEntranceFeeModel.ParentCode = parentInfo.ParentCode;
				invInvoiceDetailEntranceFeeModel.ParentName = parentInfo.ParentName;
				invInvoiceDetailEntranceFeeModel.FatherMobile = parentInfo.FatherMobile;
				invInvoiceDetailEntranceFeeModel.NationalityId = parentInfo.NationalityId;
				invInvoiceDetailEntranceFeeModel.IsStaff = parentInfo.IsStaff;
				invInvoiceDetailEntranceFeeModel.IqamaNumber = parentInfo.IqamaNumber;
				invInvoiceDetailEntranceFeeModel.AcademicYear = parentInfo.AcademicYear;
			}
		}
		private void UpdateParentInfoForTuition(string SessionKeyTime, InvInvoiceDetailTuitionFeeModel invInvoiceDetailEntranceFeeModel)
		{
			var parentInfo = GetParentInfoFromSession(SessionKeyTime);
			if (parentInfo != null)
			{
				invInvoiceDetailEntranceFeeModel.ParentId = parentInfo.ParentId;
				invInvoiceDetailEntranceFeeModel.ParentCode = parentInfo.ParentCode;
				invInvoiceDetailEntranceFeeModel.ParentName = parentInfo.ParentName;
				invInvoiceDetailEntranceFeeModel.FatherMobile = parentInfo.FatherMobile;
				invInvoiceDetailEntranceFeeModel.NationalityId = parentInfo.NationalityId;
				//invInvoiceDetailEntranceFeeModel.IsStaff = parentInfo.IsStaff;
				invInvoiceDetailEntranceFeeModel.IqamaNumber = parentInfo.IqamaNumber;

				if (invInvoiceDetailEntranceFeeModel.ParentId != null)
				{
					invInvoiceDetailEntranceFeeModel.IsSameParent = true;
				}
			}
		}
		#endregion
		#endregion

		#region Payment Method
		public async Task<IActionResult> GetPaymentMethod()
		{
			var dataSet = await _IInvoiceService.GetPaymentMethod();

			var jsonResult = new List<Dictionary<string, object>>();

			foreach (DataTable table in dataSet.Tables)
			{
				foreach (DataRow row in table.Rows)
				{
					var record = new Dictionary<string, object>();
					foreach (DataColumn column in table.Columns)
					{
						record[column.ColumnName] = row[column];
					}
					jsonResult.Add(record);
				}
			}

			return Json(jsonResult);
		}

		#endregion Payment Method

		#region Parent Balance Amount
		public async Task<IActionResult> GetParentFeeBalance(long parentId)
		{
			_logger.LogInformation($"InvoiceSetupController: GetParentFeeBalance : parentId:{parentId}");

			var result = new
			{
				parentId = 0,
				totalFeeAmount = 0.00,
				totalPaidAmount = 0.00,
				totalBalance = 0.00
			};
			var ResultDS = await _IInvoiceService.GetParentFeeBalance(parentId);
			if (ResultDS.Tables.Count > 0)
			{
				_logger.LogInformation($"InvoiceSetupController: GetParentFeeBalance : parentId:{parentId}");
				var finalResult = new
				{
					parentId = Convert.ToInt64(ResultDS.Tables[0].Rows[0]["ParentId"]),
					totalFeeAmount = Convert.ToDecimal(ResultDS.Tables[0].Rows[0]["TotalFeeAmount"]).ToTwoDecimalString(),
					totalPaidAmount = Convert.ToDecimal(ResultDS.Tables[0].Rows[0]["TotalPaidAmount"]).ToTwoDecimalString(),
					totalBalance = Convert.ToDecimal(ResultDS.Tables[0].Rows[0]["TotalBalance"]).ToTwoDecimalString(),
					totalFeeAmountValue = Convert.ToDecimal(ResultDS.Tables[0].Rows[0]["TotalBalance"]),
				};
				return Json(finalResult);
			}

			return Json(result);
		}
		#endregion
	}

}