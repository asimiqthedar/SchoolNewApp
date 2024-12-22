namespace School.Models.ZatcaModels
{
	public class InvoicePaymentEmailInfo
	{
        public long PaymentMethodCategoryId { get; set; }
		public long PaymentMethodId { get; set; }
        public string PaymentMethodName { get; set; }
		public string CategoryName { get; set; }
		public decimal PaymentAmount { get; set; }
		public string PaymentReferenceNumber { get; set; }
	}
}