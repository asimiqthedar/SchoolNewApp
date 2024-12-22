using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;

namespace School.Services.WebServices.Implementation
{
	public class EmailHelper : IEmailHelper
	{
		IOptions<AppSettingConfig> _AppSettingConfig;
		private readonly ILogger<EmailHelper> _logger;

		public EmailHelper(IOptions<AppSettingConfig> appSettingConfig)
		{
			_AppSettingConfig = appSettingConfig;

		}
		//public EmailHelper(IOptions<AppSettingConfig> appSettingConfig, ILogger<EmailHelper> logger)
		//{
		//	_AppSettingConfig = appSettingConfig;
		//	_logger = logger;

		//}
		public async Task<bool> SendEmail(string mailTo, string mailSubject, string mailBody)
		{
			try
			{
				//Task.Run(() =>
				//{
				//	EmailSend(mailTo, mailSubject, mailBody);
				//});
				return await EmailSend(mailTo, mailSubject, mailBody);

			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:EmailHelper:SendEmail : Message :{JsonConvert.SerializeObject(ex)}");
				////_logger.LogError($"Start: SendEmail- {ex.Message}");
				//throw ex;
				return false;
			}
		}

		public async Task<bool> SendEmailResetPassword(string mailTo, string mailSubject, string mailBody)
		{
			try
			{
				//Task.Run(() =>
				//{
				//	EmailSend(mailTo, mailSubject, mailBody);
				//});
				return await EmailSend(mailTo, mailSubject, mailBody);

			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:EmailHelper:SendEmail : Message :{JsonConvert.SerializeObject(ex)}");
				////_logger.LogError($"Start: SendEmail- {ex.Message}");
				//throw ex;
				return false;
			}
		}
		private async Task<bool> EmailSend(string mailTo, string mailSubject, string mailBody)
		{
			try
			{
				EmailConfiguration emailConfiguration = new EmailConfiguration();
				DataSet ds = await new EmailRepo(_AppSettingConfig).GetEmailConfig();
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					//EmailConfigId,Host,[Port],Username,[Password],EnableSSL,FromEmail
					emailConfiguration.EmailConfigId = Convert.ToInt32(ds.Tables[0].Rows[0]["EmailConfigId"]);
					emailConfiguration.Host = Convert.ToString(ds.Tables[0].Rows[0]["Host"]);
					emailConfiguration.Port = Convert.ToInt32(ds.Tables[0].Rows[0]["Port"]);
					emailConfiguration.Username = Convert.ToString(ds.Tables[0].Rows[0]["Username"]);
					emailConfiguration.Password = Convert.ToString(ds.Tables[0].Rows[0]["Password"]);
					emailConfiguration.EnableSSL = Convert.ToBoolean(ds.Tables[0].Rows[0]["EnableSSL"]);
					emailConfiguration.FromEmail = Convert.ToString(ds.Tables[0].Rows[0]["FromEmail"]);
				}
				if (string.IsNullOrEmpty(emailConfiguration.Host))
					return false;
				using (MailMessage ObjMail = new MailMessage())
				{
					ObjMail.From = new MailAddress(emailConfiguration.FromEmail);
					if (!string.IsNullOrEmpty(mailTo))
						foreach (var item in mailTo.Split(','))
							ObjMail.To.Add(item);
					if (ObjMail.To.Count == 0)
					{
						if (!string.IsNullOrEmpty(emailConfiguration.To))
							foreach (var item in emailConfiguration.To.Split(','))
								ObjMail.To.Add(item);
					}
					else
					{
						if (!string.IsNullOrEmpty(emailConfiguration.To))
							foreach (var item in emailConfiguration.To.Split(','))
								ObjMail.Bcc.Add(item);
					}
					if (ObjMail.To.Count > 0)
					{
						ObjMail.IsBodyHtml = true;
						ObjMail.Body = mailBody;
						ObjMail.Subject = mailSubject;
						using (SmtpClient sptpClient = new SmtpClient(emailConfiguration.Host, emailConfiguration.Port))
						{
							sptpClient.Credentials = new NetworkCredential(emailConfiguration.Username, emailConfiguration.Password);
							sptpClient.EnableSsl = emailConfiguration.EnableSSL;
							sptpClient.Send(ObjMail);
							return true;
						}
					}
				}
			}
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:EmailHelper:EmailSend : Message :{JsonConvert.SerializeObject(ex.Message)}");
				return false;
			}
			return false;
		}

		public async Task<bool> SendEmail(string mailTo, string mailSubject, string mailBody, string filePath)
		{
			try
			{
				//Task.Run(() =>
				//{
				//	EmailSend(mailTo, mailSubject, mailBody, filePath);
				//});
				return await EmailSend(mailTo, mailSubject, mailBody, filePath);
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:EmailHelper:SendEmail : Message :{JsonConvert.SerializeObject(ex)}");
				////_logger.LogError($"Start: EmailSend -mailTo: {mailTo}, mailSubject:{mailSubject}, mailBody: {mailBody}, filePath :{filePath}, Error: {ex.Message}");
				return false;
			}
		}
		private async Task<bool> EmailSend(string mailTo, string mailSubject, string mailBody, string filePath)
		{
			try
			{
				EmailConfiguration emailConfiguration = new EmailConfiguration();
				DataSet ds = await new EmailRepo(_AppSettingConfig).GetEmailConfig();
				if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				{
					//EmailConfigId,Host,[Port],Username,[Password],EnableSSL,FromEmail
					emailConfiguration.EmailConfigId = Convert.ToInt32(ds.Tables[0].Rows[0]["EmailConfigId"]);
					emailConfiguration.Host = Convert.ToString(ds.Tables[0].Rows[0]["Host"]);
					emailConfiguration.Port = Convert.ToInt32(ds.Tables[0].Rows[0]["Port"]);
					emailConfiguration.Username = Convert.ToString(ds.Tables[0].Rows[0]["Username"]);
					emailConfiguration.Password = Convert.ToString(ds.Tables[0].Rows[0]["Password"]);
					emailConfiguration.EnableSSL = Convert.ToBoolean(ds.Tables[0].Rows[0]["EnableSSL"]);
					//emailConfiguration.FromEmail = Convert.ToString(ds.Tables[0].Rows[0]["FromEmail"]);
					emailConfiguration.FromEmail = emailConfiguration.Username;
				}
				if (string.IsNullOrEmpty(emailConfiguration.Host))
					return false;
				using (MailMessage ObjMail = new MailMessage())
				{
					ObjMail.From = new MailAddress(emailConfiguration.FromEmail);
					if (!string.IsNullOrEmpty(mailTo))
					{
						foreach (var item in mailTo.Split(','))
						{
							var item1 = item.Replace(",", "");
							if (!string.IsNullOrEmpty(item1))
							{								
								ObjMail.To.Add(item1);
							}
						}
					}
					if (ObjMail.To.Count == 0)
					{
						if (!string.IsNullOrEmpty(emailConfiguration.To))
							foreach (var item in emailConfiguration.To.Split(','))
								ObjMail.To.Add(item);
					}
					else
					{
						if (!string.IsNullOrEmpty(emailConfiguration.To))
							foreach (var item in emailConfiguration.To.Split(','))
								ObjMail.Bcc.Add(item);
					}
					if (ObjMail.To.Count > 0)
					{
						if (!string.IsNullOrEmpty(filePath))
						{
							var filename = Path.GetFileName(filePath);
							filename = filename.Replace("_A3", "");
							var fileBytes = getFileByte(filePath);
							ObjMail.Attachments.Add(new Attachment(fileBytes, filename, MediaTypeNames.Application.Pdf));
						}

						ObjMail.IsBodyHtml = true;
						ObjMail.Body = mailBody;
						ObjMail.Subject = mailSubject;
						using (SmtpClient sptpClient = new SmtpClient(emailConfiguration.Host, emailConfiguration.Port))
						{
							sptpClient.Credentials = new NetworkCredential(emailConfiguration.Username, emailConfiguration.Password);
							sptpClient.EnableSsl = emailConfiguration.EnableSSL;
							sptpClient.UseDefaultCredentials = false;
							sptpClient.Send(ObjMail);
							return true;
						}
					}
				}
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:EmailHelper:EmailSend : Message :{JsonConvert.SerializeObject(ex)}");
				return false;
				////_logger.LogError($"Start: EmailSend -mailTo: {mailTo}, mailSubject:{mailSubject}, mailBody: {mailBody}, filePath :{filePath}, Error: {ex.Message}");
			}
			return false;
		}

		private Stream getFileByte(string pdfFilePath)
		{
			try
			{
				var byteArray = System.IO.File.ReadAllBytes(pdfFilePath);
				Stream stream = new MemoryStream(byteArray);
				return stream;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:EmailHelper:getFileByte : Message :{JsonConvert.SerializeObject(ex)}");
				////_logger.LogError($"Start: getFileByte - Error: {ex.Message}");
				throw ex;
			}
		}
	}
}
