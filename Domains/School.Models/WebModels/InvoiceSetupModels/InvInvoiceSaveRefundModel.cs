namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceSaveRefundModel
	{
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
		public long InvoiceNo { get; set; }

		public string CreditNo { get; set; }
		public string CreditReason { get; set; }
		public string CustomerName { get; set; }

		public DateTime? InvoiceDate { get; set; }

	}
}
