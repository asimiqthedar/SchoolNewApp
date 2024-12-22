namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoicePaymentModel
	{
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
		public long InvoicePaymentId { get; set; }
		public long InvoiceNo { get; set; }
		public string PaymentMethod { get; set; }
		public string PaymentReferenceNumber { get; set; }
		public decimal PaymentAmount { get; set; }
		public long? PaymentMethodId { get; set; }
		public bool? IsEditRestricted { get; set; }
	}
}
