namespace School.Services.WebServices.Services
{
	public interface IEmailHelper
	{
		public  Task<bool> SendEmail(string mailTo, string mailSubject, string mailBody);
        public Task<bool> SendEmailResetPassword(string mailTo, string mailSubject, string mailBody);
        public Task<bool> SendEmail(string mailTo, string mailSubject, string mailBody, string filePath);
	}
}
