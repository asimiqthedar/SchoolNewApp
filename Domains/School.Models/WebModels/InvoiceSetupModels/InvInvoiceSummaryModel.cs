namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceSummaryModel
	{
		public InvInvoiceSummaryModel()
		{
			InvoiceDetailList = new List<InvInvoiceDetailModel>();
			InvoicePaymentList = new List<InvInvoicePaymentModel>();
			InvInvoicePaymentModel = new InvInvoicePaymentModel();
		}
		public string InvoiceSessionKey { get; set; }
		public long InvoiceId { get; set; }
		public long InvoiceNo { get; set; }
		public DateTime? InvoiceDate { get; set; }
		public string Status { get; set; }
		public string PublishedBy { get; set; }
		public string CreditNo { get; set; }
		public string CreditReason { get; set; }
		public string CustomerName { get; set; }
		public string ParentId { get; set; }
		public string IqamaNumber { get; set; }

		public decimal? TaxableAmount { get { return ItemSubtotal - TotalDiscount; } }

		public decimal? TaxAmount { get { return InvoiceDetailList.Sum(s => s.TaxAmount); } }
		public decimal ItemSubtotal { get { return InvoiceDetailList.Sum(s => s.ItemSubtotal); } }

		public decimal TotalPaid { get { return InvoicePaymentList.Sum(s => s.PaymentAmount); } }
		public decimal TotalDiscount { get { return InvoiceDetailList.Sum(s => s.Discount.Value); } }

		public int IsAdvanceAllowed { get; set; }
		public long InvoiceRefNo { get; set; }
		public string InvoiceType { get; set; }
		public List<InvInvoiceDetailModel> InvoiceDetailList { get; set; }
		public List<InvInvoicePaymentModel> InvoicePaymentList { get; set; }
		public InvInvoicePaymentModel InvInvoicePaymentModel { get; set; }

		public bool VATAccountExist { get; set; }
		public bool PaymentMethodAccountExist { get; set; }
	}
}
