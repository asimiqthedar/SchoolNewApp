using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.VatModels;
using School.Services.ALSManager;
using School.Services.Entities;
using School.Services.WebServices.Services;
using School.Web.Helpers;
using System.Data;

namespace School.Web.Controllers
{
	[Authorize]
	public class InvoiceReturnController : BaseController
	{
		private readonly ILogger<StudentController> _logger;
		private readonly ICommonService _ICommonService;

		private readonly IInvoiceService _IInvoiceService;
		private readonly IOptions<AppSettingConfig> _AppSettingConfig;
		private readonly IHttpContextAccessor _IHttpContextAccessor;
		private readonly IWebHostEnvironment _IWebHostEnvironment;
		private readonly IInvSummaryManager _iInvSummaryManager;
		private readonly IInvInvoiceDetailManager _iInvInvoiceDetailManager;
		private readonly IInvInvoicePaymentManager _iInvInvoicePaymentManager;
		private readonly IMapper _mapper;
		public InvoiceReturnController(ILogger<StudentController> logger, IOptions<AppSettingConfig> appSettingConfig,
			IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService, IInvoiceService iInvoiceService,
			IWebHostEnvironment iWebHostEnvironment,
			  ICommonService iCommonService,
			  IMapper mapper,

			  IInvSummaryManager iInvSummaryManager,
			  IInvInvoiceDetailManager iInvInvoiceDetailManager,
			  IInvInvoicePaymentManager iInvInvoicePaymentManager

			) : base(iHttpContextAccessor, iDropdownService)
		{
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

		public IActionResult Invoice()
		{
			return View();
		}

		public async Task<IActionResult> InvoiceDataPartial()
		{
			DataSet ds = await _IInvoiceService.GetReturnInvoices();
			return PartialView("_InvoiceDataPartial", ds);
		}

		public async Task<IActionResult> Return(long invoiceNo)
		{
			Guid sessionKeyId = Guid.NewGuid();
			string SessionKeyTime = GetSessionKey(invoiceNo, sessionKeyId.ToString());
			InvInvoiceSummaryModel invInvoiceSummaryModel = new InvInvoiceSummaryModel() { InvoiceSessionKey = sessionKeyId.ToString(), InvoiceNo = invoiceNo };
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
				invInvoiceSummaryModel.InvoiceRefNo = invoiceNo;

				var detailList = _mapper.Map<List<InvInvoiceDetailModel>>(invoiceDetails);
				var paymentList = _mapper.Map<List<InvInvoicePaymentModel>>(invoicePayments);

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
			}

			return PartialView("_InvoicePaymentDataPartial", invoiceDetailList);
		}

		[HttpPost]
		public async Task<IActionResult> InvoicePaymentAddEdit(InvInvoicePaymentModel model)
		{
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			model.SessionKey = string.IsNullOrEmpty(model.SessionKey) ? Guid.NewGuid().ToString() : model.SessionKey;

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{

				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoicePaymentList.Where(s => s.SessionKey == model.SessionKey).FirstOrDefault();

				if (InvoiceDetailModel == null)
				{
					invInvoiceSummaryModel.InvoicePaymentList.Add(_mapper.Map<InvInvoicePaymentModel>(model));
				}
				else if (InvoiceDetailModel != null)
				{
					invInvoiceSummaryModel.InvoicePaymentList.Remove(invInvoiceSummaryModel.InvoicePaymentList.FirstOrDefault(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey));
					invInvoiceSummaryModel.InvoicePaymentList.Add(_mapper.Map<InvInvoicePaymentModel>(model));
				}
				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);

				return Json(new { result = 0 });
			}
			return Json(new { result = -1 });
		}

		public async Task<IActionResult> InvoiceSave(InvInvoiceSummaryModel model)
		{
			try
			{
				string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

				if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
				{
					var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

					var latestInvoiceno = await _IInvoiceService.GetLatestInvoice();

					invInvoiceSummaryModel.InvoiceNo = latestInvoiceno;
					invInvoiceSummaryModel.InvoiceDate = (!model.InvoiceDate.HasValue && model.InvoiceDate != DateTime.MinValue) ? DateTime.Now : model.InvoiceDate;


					List<InvInvoiceDetail> invInvoiceDetails = _mapper.Map<List<InvInvoiceDetail>>(invInvoiceSummaryModel.InvoiceDetailList);
					List<InvInvoicePayment> invInvoicePayments = _mapper.Map<List<InvInvoicePayment>>(invInvoiceSummaryModel.InvoicePaymentList);

					foreach (var item in invInvoiceDetails)
					{
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

					invInvoiceSummaryModel.IqamaNumber = invInvoiceSummaryModel.InvoiceDetailList.Where(s => !string.IsNullOrEmpty(s.IqamaNumber)).Select(s => s.IqamaNumber).FirstOrDefault();
					invInvoiceSummaryModel.IqamaNumber = string.IsNullOrEmpty(invInvoiceSummaryModel.IqamaNumber) ? string.Empty : invInvoiceSummaryModel.IqamaNumber;

					invInvoiceSummaryModel.ParentId = invInvoiceSummaryModel.InvoiceDetailList.Where(s => !string.IsNullOrEmpty(s.ParentId)).Select(s => s.ParentId).FirstOrDefault();
					invInvoiceSummaryModel.ParentId = string.IsNullOrEmpty(invInvoiceSummaryModel.ParentId) ? string.Empty : invInvoiceSummaryModel.ParentId;

					invInvoiceSummaryModel.Status = invInvoiceSummaryModel.InvoiceNo > 0 ? "New" : invInvoiceSummaryModel.Status;
					invInvoiceSummaryModel.PublishedBy = GetUserDataFromClaims("UserId");


					//invInvoiceSummaryModel.TaxableAmount = invInvoiceSummaryModel.InvoiceDetailList.Sum(s => s.TaxableAmount);
					//invInvoiceSummaryModel.TaxAmount = invInvoiceSummaryModel.InvoiceDetailList.Sum(s => s.TaxAmount);
					//invInvoiceSummaryModel.ItemSubtotal = invInvoiceSummaryModel.InvoiceDetailList.Sum(s => s.ItemSubtotal);

					invInvoiceSummaryModel.InvoiceType = "Return";

					InvInvoiceSummary invInvoiceSummary = _mapper.Map<InvInvoiceSummary>(invInvoiceSummaryModel);
					//sp_GetInvoiceNo
					var saveInvoiceSummary = await _iInvSummaryManager.Save(invInvoiceSummary);

					await _iInvInvoiceDetailManager.SaveRange(invInvoiceDetails, invInvoiceSummary.InvoiceNo);

					await _iInvInvoicePaymentManager.SaveRange(invInvoicePayments, invInvoiceSummary.InvoiceNo);

					return Json(new { result = 0 });
				}
				return Json(new { result = -1 });
			}
			catch (Exception ex)
			{
			}
			return Json(new { result = -1 });
		}

		private string GetSessionKey(long invoiceNo, string invoiceSessionKey)
		{
			string SessionKeyTime = invoiceNo > 0 ? "InvoiceReturn_" + invoiceNo : invoiceSessionKey;
			return SessionKeyTime;
		}

		public async Task<IActionResult> DeleteInvoice(long invoiceId)
		{
			return Json(new { result = await _IInvoiceService.DeleteInvoice(Convert.ToInt32(GetUserDataFromClaims("UserId")), invoiceId) });
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
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId
			};

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailEntranceFeeModel>(model);
				//else
				//{
				//    invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(invInvoiceDetailEntranceFeeModel));
				//}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return PartialView("_InvoiceDetailEntranceFeeEdit", invInvoiceDetailEntranceFeeModel);
		}
		[HttpPost]
		public async Task<IActionResult> InvoiceDetailEntranceFeeEditPartial(InvInvoiceDetailEntranceFeeModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

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

			InvInvoiceDetailUniformFeeModel invInvoiceDetailEntranceFeeModel = new InvInvoiceDetailUniformFeeModel()
			{
				InvoiceNo = invoiceNo,
				InvoiceSessionKey = invoiceSessionKey,
				SessionKey = string.IsNullOrEmpty(sessionKeyId) ? Guid.NewGuid().ToString() : sessionKeyId
			};

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailUniformFeeModel>(model);
				//else
				//{
				//    invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(invInvoiceDetailEntranceFeeModel));
				//}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return PartialView("_InvoiceDetailUniformFeeEdit", invInvoiceDetailEntranceFeeModel);
		}
		[HttpPost]
		public async Task<IActionResult> InvoiceDetailUniformFeeEditPartial(InvInvoiceDetailUniformFeeModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

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
			return Json(new { result = -1 });
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

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);

				var model = invInvoiceSummaryModel.InvoiceDetailList.Where(s => s.SessionKey == invInvoiceDetailEntranceFeeModel.SessionKey
				  && s.InvoiceSessionKey == invInvoiceDetailEntranceFeeModel.InvoiceSessionKey).FirstOrDefault();
				if (model != null)
					invInvoiceDetailEntranceFeeModel = _mapper.Map<InvInvoiceDetailTuitionFeeModel>(model);
				//else
				//{
				//    invInvoiceSummaryModel.InvoiceDetailList.Add(_mapper.Map<InvInvoiceDetailModel>(invInvoiceDetailEntranceFeeModel));
				//}

				HttpContext.Session.Set<InvInvoiceSummaryModel>(SessionKeyTime, invInvoiceSummaryModel);
			}

			return PartialView("_InvoiceDetailTuitionFeeEdit", invInvoiceDetailEntranceFeeModel);
		}

		[HttpPost]
		public async Task<IActionResult> InvoiceDetailTuitionFeeEditPartial(InvInvoiceDetailTuitionFeeModel model)
		{
			InitDropdown();
			string SessionKeyTime = GetSessionKey(model.InvoiceNo, model.InvoiceSessionKey);

			if (HttpContext.Session.Keys.Any(s => s.Equals(SessionKeyTime)))
			{
				var invInvoiceSummaryModel = HttpContext.Session.Get<InvInvoiceSummaryModel>(SessionKeyTime);
				var InvoiceDetailModel = invInvoiceSummaryModel.InvoiceDetailList
					.Where(s => s.InvoiceSessionKey == model.InvoiceSessionKey && s.SessionKey == model.SessionKey).FirstOrDefault();

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
			return Json(new { result = -1 });
		}

		#endregion

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

		public async Task<IActionResult> GetUniformByItemCode(string itemCode)
		{
			var dataSet = await _IInvoiceService.GetUniformByItemCode(itemCode, 0);

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

		#endregion

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

		#endregion
	}
}
