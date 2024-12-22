namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoicePaymentyRefundModel
	{
		public long InvoiceRefNo { get; set; }
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
		public long InvoicePaymentId { get; set; }
		public long InvoiceNo { get; set; }
		public string PaymentMethod { get; set; }
		public string PaymentReferenceNumber { get; set; }
		public decimal PaymentAmount { get; set; }

		public decimal RefundablePaymentAmount { get; set; }

		public decimal RefundedPaymentAmount { get; set; }

		public decimal AvailablePaymentAmount { get { return RefundablePaymentAmount - RefundedPaymentAmount; } }
		public long? PaymentMethodId { get; set; }

		public string OriginalPaymentMethod { get; set; }
	
		public long? InvoicePaymentRefId { get; set; }
	}

}
