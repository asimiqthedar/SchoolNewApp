using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.VatModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class InvoiceService : IInvoiceService
	{
		InvoiceRepo _InvoiceRepo;
		IOptions<AppSettingConfig> _AppSettingConfig;
        private readonly ILogger<InvoiceService> _logger;
		IEmailService _EmailService;
        public InvoiceService(IOptions<AppSettingConfig> appSettingConfig, ILogger<InvoiceService> logger, IEmailService emailService)
		{
			_InvoiceRepo = new InvoiceRepo(appSettingConfig);
			_AppSettingConfig = appSettingConfig;
            _logger = logger;
			_EmailService = emailService;
        }

		public async Task<DataSet> GetInvoice(InvoiceFilterModel filterModel)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetInvoice(0, filterModel);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetInvoice : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}

		public async Task<DataSet> GetReturnInvoices()
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetReturnInvoices();
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetReturnInvoices : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}

		public async Task<long> GetLatestInvoice()
		{
			try
			{
				long result = await _InvoiceRepo.GetLatestInvoice();
				return result;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetLatestInvoice : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}

		public async Task<int> DeleteInvoice(int loginUserId, long invoiceId)
		{
			try
			{
				int result = await _InvoiceRepo.DeleteInvoice(loginUserId, invoiceId);
				return result;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:DeleteInvoice : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		public async Task<bool> SendInvoice(int invoiceId)
		{
			try
			{
				//EmailService _EmailService = new EmailService(_AppSettingConfig);
				return await _EmailService.SendInvoiceEmail(invoiceId);
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:SendInvoice : Message :{JsonConvert.SerializeObject(ex)}");
                return false;
				//throw ex;
			}
		}

		public async Task<bool> SendInvoiceEmailWithInvoiceAttachment(long invoiceId, string filePath, string emailTo)
		{
			try
			{
				//EmailService _EmailService = new EmailService(_AppSettingConfig);
				if (string.IsNullOrEmpty(filePath))
					return await _EmailService.SendInvoiceEmail(invoiceId);
				return await _EmailService.SendInvoiceEmailWithInvoiceAttachment(invoiceId, filePath, emailTo);
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:SendInvoiceEmailWithInvoiceAttachment : Message :{JsonConvert.SerializeObject(ex)}");
                //return false;
                //throw ex;
            }
			return false;
		}

        public long ProcessInvoiceStatement(long invoiceNo)
        {
            try
            {
                long result =  _InvoiceRepo.ProcessInvoiceStatement(invoiceNo);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:InvoiceService:ProcessInvoiceStatement : Message :{JsonConvert.SerializeObject(ex)}");
				//throw ex;
				return -1;
            }
        }

		public long ProcessGP(long invoiceNo)
		{
			try
			{
				long result = _InvoiceRepo.ProcessGP(invoiceNo);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:InvoiceService:ProcessGP : Message :{JsonConvert.SerializeObject(ex)}");
				//throw ex;
				return -1;
			}
		}


		#region Uniform Invoice
		public async Task<DataSet> GetItemCodeRecords()
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetItemCodeRecords();
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetItemCodeRecords : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}

		public async Task<DataSet> GetUniformByItemCode(string itemCode, int nationalId = 0)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetUniformByItemCode(itemCode, nationalId);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetUniformByItemCode : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		#endregion

		#region tuitionFee
		public async Task<DataSet> GetStudentByParentId(long parentId)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetStudentByParentId(parentId);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetStudentByParentId : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		public async Task<DataSet> GetStudentById(long studentId)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetStudentById(studentId);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetStudentById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		public async Task<DataSet> GetParentById(long parentId)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetParentById(parentId);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetParentById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		public async Task<VatDetailModel> GetVATDetail(string invoiceTypeName, int nationalId)
		{
			try
			{
				VatDetailModel ds = await _InvoiceRepo.GetVATDetail(invoiceTypeName, nationalId);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetVATDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}
		public async Task<InvoiceFeeDetailModel> GetFeeAmount(long academicYearId, long studentId, string InvoiceTypeName)
		{
			try
			{
				InvoiceFeeDetailModel ds = await _InvoiceRepo.GetFeeAmount(academicYearId, studentId, InvoiceTypeName);
				return ds;
			}
			catch (Exception ex)
			{
                //_logger.LogError($"Exception:InvoiceService:GetFeeAmount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
			}
		}

		public async Task<List<InvoiceFeeDetailParentStudentModel>> GetFeeAmountParentStudent(long academicYearId, long parentid, string InvoiceTypeName)
		{
			try
			{
				List<InvoiceFeeDetailParentStudentModel> ds = await _InvoiceRepo.GetFeeAmountParentStudent(academicYearId, parentid, InvoiceTypeName);
				return ds;
			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:InvoiceService:GetFeeAmount : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		#endregion


		#region GP integration
		public async Task<DataSet> ProcessGPUniformInvoice(int invoiceno)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.ProcessGPUniformInvoice(invoiceno);
				return ds;
			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:InvoiceService:GetParentById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}

		}
        #endregion

        #region Payment Method
        public async Task<DataSet> GetPaymentMethod()
        {
            try
            {
                DataSet ds = await _InvoiceRepo.GetPaymentMethod();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:InvoiceService:GetPaymentMethod : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
		#endregion

		#region Parent Balance Amount
		public async Task<DataSet> GetParentFeeBalance(long parentId)
		{
			try
			{
				DataSet ds = await _InvoiceRepo.GetParentFeeBalance(parentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:InvoiceService:GetParentFeeBalance : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion
	}
}