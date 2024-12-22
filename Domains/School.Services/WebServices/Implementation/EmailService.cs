using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common;
using School.Common.Utility;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class EmailService : IEmailService
	{
		private readonly IOptions<AppSettingConfig> _AppSettingConfig;
		private readonly ILogger<EmailService> _logger;
		IEmailHelper _emailHelper;
		//public EmailService(IOptions<AppSettingConfig> appSettingConfig)
		//{
		//	_AppSettingConfig = appSettingConfig;            
		//      }
		public EmailService(IOptions<AppSettingConfig> appSettingConfig, ILogger<EmailService> logger, IEmailHelper emailHelper)
		{
			_AppSettingConfig = appSettingConfig;
			_logger = logger;
			_emailHelper = emailHelper;
		}
		public async Task<bool> SendInvoiceEmail(long invoiceId)
		{
			_logger.LogInformation("Start: SendInvoiceEmailService");
			try
			{
				if (_AppSettingConfig.Value.IsAllowEmail.ToLower().Equals("false"))
				{
					return true;
				}
				string employeeEmail = _AppSettingConfig.Value.To;
				//EmailHelper _emailHelper = new EmailHelper(_AppSettingConfig);
				DataSet ds = await new EmailRepo(_AppSettingConfig).GetInvoice(invoiceId);
				if (ds != null && ds.Tables.Count > 0)
				{
					if (ds.Tables[0].Rows.Count > 0)
					{
						Dictionary<string, string> mailData = new Dictionary<string, string>();
						mailData.Add("InvoiceNo", Convert.ToString(ds.Tables[0].Rows[0]["InvoiceNo"]));

						string mailSubject = PdfUtility.GetTemplateSubject(ConfigTemplate.InvoiceEmail);
						string mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.InvoiceEmail);
						mailSubject = PdfUtility.ProcessTemplate(mailSubject, mailData);
						mailBody = PdfUtility.ProcessTemplate(mailBody, mailData);
						return await _emailHelper.SendEmail(employeeEmail, mailSubject, mailBody);						
					}
				}
			}
			catch (Exception ex)
			{
                _logger.LogError($"Exception:EmailService:SendInvoiceEmail : Message :{JsonConvert.SerializeObject(ex)}");
                return false;
			}
			return false;
		}

		public async Task<bool> SendInvoiceEmailWithInvoiceAttachment(long invoiceId, string filePath, string emailTo)
		{
			_logger.LogInformation("Start: SendInvoiceEmailService");
			try
			{
                string employeeEmail = _AppSettingConfig.Value.To;
				if (_AppSettingConfig.Value.IsAllowEmail.ToLower().Equals("true"))
				{
					if (!string.IsNullOrEmpty(emailTo))
					{
						employeeEmail = string.Join(",", employeeEmail, emailTo);
					}
				}

				//EmailHelper _emailHelper = new EmailHelper(_AppSettingConfig);
				DataSet ds = await new EmailRepo(_AppSettingConfig).GetInvoice(invoiceId);
				if (ds != null && ds.Tables.Count > 0)
				{
					if (ds.Tables[0].Rows.Count > 0)
					{
						Dictionary<string, string> mailData = new Dictionary<string, string>();
						mailData.Add("InvoiceNo", Convert.ToString(ds.Tables[0].Rows[0]["InvoiceNo"]));

						string mailSubject = PdfUtility.GetTemplateSubject(ConfigTemplate.InvoiceEmail);
						string mailBody = PdfUtility.GetTemplateBody(ConfigTemplate.InvoiceEmail);
						mailSubject = PdfUtility.ProcessTemplate(mailSubject, mailData);
						mailBody = PdfUtility.ProcessTemplate(mailBody, mailData);
						return await _emailHelper.SendEmail(employeeEmail, mailSubject, mailBody, filePath);
					}
				}

			}
			catch (Exception ex)
			{
                _logger.LogError($"Exception:EmailService:SendInvoiceEmailWithoutInvoiceAttachment : Message :{JsonConvert.SerializeObject(ex)}");
                return false;
			}
			return false;
		}
		
	}
}
