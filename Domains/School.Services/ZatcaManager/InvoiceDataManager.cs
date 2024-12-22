using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using School.Services.Entities;
using School.Models.ZatcaModels;
using School.Services.ZatcaEntities;
using School.Models.WebModels.InvoiceSetupModels;

namespace School.Services.ALSManager
{
    public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            CreateMap<InvoiceSummaryModel, InvInvoiceSummary>().ReverseMap();
            CreateMap<InvoiceDetailModel, InvInvoiceDetail>().ReverseMap();
			CreateMap<InvoicePaymentModel, InvInvoicePayment>().ReverseMap();
            CreateMap<UniformDetailModel, UniformDetail>().ReverseMap();
            CreateMap<VWInvoiceModel, vw_Invoices>().ReverseMap();
            
        }
    }
    public interface IInvoiceDataManager
	{
		Task<InvoiceModel> Get(long invoiceNo);
		Task<InvoiceModel> GetPreviousInvoice(InvoiceSummaryModel invoiceNo);
		Task<List<InvoiceModel>> GetByList(List<long> invoiceNos);
		Task<List<VWInvoiceModel>> GetInvoiceList();
		Task<bool> SaveZatcaResponse(long invoiceNo, string encodedInvoice, string invoiceHash, string uuid,
			string reportingStatus, string qrCodePath, string SingedXMLFileNameFullPath,string ClearedInvoice,
            string errormessage, string WarningMessage,bool is_sent,int statuscode,string status);
		Task<int> ProcessSyncInvoices();
		Task<List<VWInvoiceModel>> GetInvoices(List<long> invoiceList);
		Task<InvoiceSummaryModel> GetFirstZatcaInvoice();
		InvoiceSummaryModel GetLastZatcaInvoice();
		Task<List<InvoiceNonReportingModel>> GetNonReportingInvoice();

		Task<bool> SaveInvoicePath(long invoiceNo, string invoicepdfPath);
	}
	public class InvoiceDataManager : IInvoiceDataManager
	{
        private readonly ALSContext _ALSContextDB;
        private readonly IMapper _mapper;
        public InvoiceDataManager(ALSContext aLSContextDB, IMapper mapper)
        {
            _ALSContextDB = aLSContextDB;
			//_mapper = mapper;
            var configuration = new MapperConfiguration(cfg => cfg.AddProfile<AutoMapperProfile>());
             _mapper = configuration.CreateMapper();

        }

		public async Task<List<VWInvoiceModel>> GetInvoiceList()
		{
			try
			{
				//List<InvoiceModel> invModelLst = new List<InvoiceModel>();
				var invSummary = _ALSContextDB.vw_Invoices.OrderByDescending(s => s.InvoiceNo).ToList();
				var InvSummaryModelLst = _mapper.Map<List<VWInvoiceModel>>(invSummary);
				//foreach (var item in InvSummaryModelLst)
				//{
				//    InvoiceModel invModel = new InvoiceModel();
				//    invModel.InvSmryModel = item;
				//    invModelLst.Add(invModel);
				//}
				return InvSummaryModelLst;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public async Task<List<VWInvoiceModel>> GetInvoices(List<long> invoiceList)
		{
			try
			{
				//List<InvoiceModel> invModelLst = new List<InvoiceModel>();
				var invSummary = _ALSContextDB.vw_Invoices.Where(s => invoiceList.Contains(s.InvoiceNo.Value)).ToList();
				var InvSummaryModelLst = _mapper.Map<List<VWInvoiceModel>>(invSummary);
				//foreach (var item in InvSummaryModelLst)
				//{
				//    InvoiceModel invModel = new InvoiceModel();
				//    invModel.InvSmryModel = item;
				//    invModelLst.Add(invModel);
				//}
				return InvSummaryModelLst;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
        public async Task<VWInvoiceModel> GetInvoice(long invoiceno)
        {
            try
            {
                //List<InvoiceModel> invModelLst = new List<InvoiceModel>();
                var invSummary = _ALSContextDB.vw_Invoices.Where(s =>s.InvoiceNo==invoiceno).FirstOrDefault();
                var InvSummaryModelLst = _mapper.Map<VWInvoiceModel>(invSummary);
                //foreach (var item in InvSummaryModelLst)
                //{
                //    InvoiceModel invModel = new InvoiceModel();
                //    invModel.InvSmryModel = item;
                //    invModelLst.Add(invModel);
                //}
                return InvSummaryModelLst;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<InvoiceModel> Get(long invoiceNo)
		{
            try
            {
                InvoiceModel invModel = new InvoiceModel();

                var invSummary = _ALSContextDB.InvInvoiceSummaries.Where(s=>s.InvoiceNo== invoiceNo).FirstOrDefault();
               
                var invDetailList = _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo==invoiceNo).ToList();
                //var invUniformDetailList = _ALSContextDB.UniformDetails.Where(s => s.InvoiceNo==invoiceNo).ToList();


                //var paymenList = _ALSContextDB.InvoicePayments.Where(s => finalInvoiceNos.Contains(s.InvoiceNo.ToString())).ToList();
                var paymenList = _ALSContextDB.InvInvoicePayments.Where(s => s.InvoiceNo==invoiceNo).ToList();

                


                invModel.InvoiceSummaryModel = _mapper.Map<InvoiceSummaryModel>(invSummary);

                    // invDetailList.ForEach()
                    invModel.InvoiceDetailModelLst = _mapper.Map<List<InvoiceDetailModel>>(invDetailList);

                    // invDetailList.ForEach()
                   // invModel.UniformDetailModelLst = _mapper.Map<List<UniformDetailModel>>(invUniformDetailList);

                    // invDetailList.ForEach()
                    invModel.InvoicePaymentModelLst = _mapper.Map<List<InvoicePaymentModel>>(paymenList);

                    if (string.IsNullOrEmpty(invModel.InvoiceSummaryModel.PaymentMethod))
                    {
                        if (invModel.InvoicePaymentModelLst.Any())
                            invModel.InvoiceSummaryModel.PaymentMethod = invModel.InvoicePaymentModelLst.OrderByDescending(s => s.PaymentAmount).FirstOrDefault().PaymentMethod;
                        else
                            invModel.InvoiceSummaryModel.PaymentMethod = "cash"; // set default cash
                    }
					else
                    invModel.InvoiceSummaryModel.PaymentMethod = "cash";
                
                return invModel;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

		public async Task<InvoiceModel> GetPreviousInvoice(InvoiceSummaryModel invoiceSummaryModel)
		{
			try
			{
				InvoiceModel invModel = new InvoiceModel();
				var invSummary = _ALSContextDB.InvInvoiceSummaries.Where(s => s.IsSentToZatca == true)
					.OrderByDescending(s => s.InvoiceId).FirstOrDefault();
				if (invSummary != null)
				{
					invModel.InvoiceSummaryModel.InvoiceNo = invSummary.InvoiceNo;
					invModel.InvoiceSummaryModel.UUID = invSummary.UUID;
					invModel.InvoiceSummaryModel.EncodedInvoice = invSummary.EncodedInvoice;
					invModel.InvoiceSummaryModel.InvoiceHash = invSummary.InvoiceHash;
				}
				return invModel;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
		public async Task<List<InvoiceModel>> GetByList(List<long> invoiceNos)
		{
			try
			{
				List<InvoiceModel> invModelList = new List<InvoiceModel>();
               
                var invSummaryList = _ALSContextDB.InvInvoiceSummaries.Where(s => s.ReportingStatus != "REPORTED" && invoiceNos.Contains(s.InvoiceNo))
					.OrderBy(s => s.InvoiceId)
					.ToList();
				var finalInvoiceNos = invSummaryList.Select(s => s.InvoiceNo);
				var invDetailList = _ALSContextDB.InvInvoiceDetails.Where(s => finalInvoiceNos.Contains(s.InvoiceNo)).ToList();
				var invUniformDetailList = _ALSContextDB.UniformDetails.Where(s => finalInvoiceNos.Contains(s.InvoiceNo)).ToList();


				//var paymenList = _ALSContextDB.InvoicePayments.Where(s => finalInvoiceNos.Contains(s.InvoiceNo.ToString())).ToList();
				var paymenList = _ALSContextDB.InvInvoicePayments.Where(s => finalInvoiceNos.Contains(s.InvoiceNo)).ToList();

				invSummaryList.ForEach
				(invSummary =>
					{
						InvoiceModel invModel = new InvoiceModel();
						invModel.InvoiceSummaryModel = _mapper.Map<InvoiceSummaryModel>(invSummary);

						// invDetailList.ForEach()
						invModel.InvoiceDetailModelLst = _mapper.Map<List<InvoiceDetailModel>>(invDetailList.Where(s => s.InvoiceNo == invModel.InvoiceSummaryModel.InvoiceNo).ToList());

						// invDetailList.ForEach()
						invModel.UniformDetailModelLst = _mapper.Map<List<UniformDetailModel>>(invUniformDetailList.Where(s => s.InvoiceNo == invModel.InvoiceSummaryModel.InvoiceNo).ToList());

						// invDetailList.ForEach()
						invModel.InvoicePaymentModelLst = _mapper.Map<List<InvoicePaymentModel>>(paymenList.Where(s => s.InvoiceNo == invModel.InvoiceSummaryModel.InvoiceNo).ToList());

						if (string.IsNullOrEmpty(invModel.InvoiceSummaryModel.PaymentMethod))
						{
							if (invModel.InvoicePaymentModelLst.Any())
								invModel.InvoiceSummaryModel.PaymentMethod = invModel.InvoicePaymentModelLst.OrderByDescending(s => s.PaymentAmount).FirstOrDefault().PaymentMethod;
							else
								invModel.InvoiceSummaryModel.PaymentMethod = "cash"; // set default cash
						}

						if (invModel.InvoicePaymentModelLst.Any())
							invModel.InvoiceSummaryModel.PaymentMethod = invModel.InvoicePaymentModelLst.OrderByDescending(s => s.PaymentAmount).FirstOrDefault().PaymentMethod;
						else
							invModel.InvoiceSummaryModel.PaymentMethod = "cash"; // set default cash

						invModelList.Add(invModel);
					}
				);

				return invModelList;
			}
			catch (Exception ex)
			{
				throw ex;
			}

		}

		public async Task<bool> SaveZatcaResponse(long invoiceNo, string encodedInvoice, string invoiceHash,
			string uuid, string reportingStatus, string qrCodePath, string SingedXMLFileNameFullPath
			, string ClearedInvoice,string errormessage, string WarningMessage,bool IsSentToZatca,int statuscode, string Status)
		{
			try
			{
				var invSummary = _ALSContextDB.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
				invSummary.EncodedInvoice = encodedInvoice;
				invSummary.InvoiceHash = invoiceHash;
				invSummary.UUID = uuid;
				invSummary.ReportingStatus = reportingStatus;
				invSummary.QRCodePath = qrCodePath;
				invSummary.SignedXMLPath = SingedXMLFileNameFullPath;
                invSummary.ClearedInvoice = ClearedInvoice;
                invSummary.WarningMessage = WarningMessage;
                invSummary.ErrorMessage = errormessage;
                invSummary.IsSentToZatca = IsSentToZatca;
                invSummary.Status = Status;
				invSummary.StatusCode = statuscode;
                await _ALSContextDB.SaveChangesAsync();
				return true;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public async Task<int> ProcessSyncInvoices()
		{
			try
			{
				//var response = _ALSContextDB.SyncInvoices();
				return 0;
			}
			catch (Exception ex)
			{

				throw ex;
			}
		}

		public async Task<InvoiceSummaryModel> GetFirstZatcaInvoice()
		{
			var invSummarytList = _ALSContextDB.InvInvoiceSummaries.Where(s => s.ReportingStatus == "REPORTED").ToList();
			var invSummaryFirst = invSummarytList.OrderBy(s => Convert.ToInt32(s.InvoiceNo)).FirstOrDefault();
			if (invSummaryFirst != null)
				return _mapper.Map<InvoiceSummaryModel>(invSummaryFirst);
			return null;
		}

		public InvoiceSummaryModel GetLastZatcaInvoice()
		{
			InvoiceModel invModel = new InvoiceModel();
			var invSummarytList = _ALSContextDB.InvInvoiceSummaries.Where(s => s.ReportingStatus == "REPORTED").ToList();
			var invSummaryFirst = invSummarytList.OrderByDescending(s => s.InvoiceId).FirstOrDefault();
			if (invSummaryFirst != null)
				return _mapper.Map<InvoiceSummaryModel>(invSummaryFirst);
			return null;
		}

		public async Task<List<InvoiceNonReportingModel>> GetNonReportingInvoice()
		{
			try
			{
				return _ALSContextDB.InvInvoiceSummaries.Where(s => s.Status == "Posted" && s.ReportingStatus == "Not Reported")
					.Select(s => new InvoiceNonReportingModel
					{
						InvoiceNo = s.InvoiceNo,
						Status = s.Status,
						ReportingStatus = s.ReportingStatus,
						InvoiceType = s.InvoiceType,
						SignedXMLPath = s.SignedXMLPath,
						InvoicePdfPath = s.InvoicePdfPath,
						QRCodePath = s.QRCodePath,
					})
					.ToList();
			}
			catch (Exception ex)
			{
				throw ex;
			}

		}

		public async Task<bool> SaveInvoicePath(long invoiceNo, string invoicepdfPath)
		{
			try
			{
				var invSummary = _ALSContextDB.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
				invSummary.InvoicePdfPath = invoicepdfPath;

				await _ALSContextDB.SaveChangesAsync();
				return true;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}
	}
}