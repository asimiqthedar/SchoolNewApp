namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceDetailRefundModel
	{
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
		public long InvoiceNo { get; set; }
		public int Quantity { get; set; }
		public decimal Amount { get; set; }
		public long InvoiceRefNo { get; set; }
		public string PaymentMethod { get; set; }
		public string PaymentReferenceNumber { get; set; }
	}
}
