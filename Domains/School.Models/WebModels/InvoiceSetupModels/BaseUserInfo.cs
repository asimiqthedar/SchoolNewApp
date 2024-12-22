namespace School.Models.WebModels.InvoiceSetupModels
{
	public class BaseUserInfo : BaseUserStudentInfo
	{
		public string InvoiceType { get; set; }
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
	}
}
