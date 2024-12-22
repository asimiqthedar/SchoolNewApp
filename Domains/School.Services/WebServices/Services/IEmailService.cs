namespace School.Services.WebServices.Services
{
	public interface IEmailService
	{
		public Task<bool> SendInvoiceEmail(long invoiceId);
		public  Task<bool> SendInvoiceEmailWithInvoiceAttachment(long invoiceId, string filePath, string emailTo);
	}
}
