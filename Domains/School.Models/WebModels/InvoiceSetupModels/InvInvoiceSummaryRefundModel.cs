namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceSummaryRefundModel
	{
		public InvInvoiceSummaryRefundModel()
		{
			InvoiceDetailList = new List<InvInvoiceDetailyRefundModel>();
			InvoicePaymentList = new List<InvInvoicePaymentyRefundModel>();
			Status = "new";
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

		//public decimal? TaxableAmount { get { return ItemSubtotal - TotalDiscount; } }

		//public decimal? TaxAmount { get { return InvoiceDetailList.Sum(s => s.TaxAmount); } }
		//public decimal ItemSubtotal { get { return InvoiceDetailList.Sum(s => s.ItemSubtotal); } }

		//public decimal TotalPaid { get { return InvoicePaymentList.Sum(s => s.PaymentAmount); } }
		//public decimal TotalDiscount { get { return InvoiceDetailList.Sum(s => s.Discount.Value); } }

		public decimal? TaxableAmount { get; set; }
		public decimal? TaxAmount { get; set; }
		public decimal ItemSubtotal { get; set; }
		public decimal TotalPaid { get; set; }
		public decimal TotalDiscount { get; set; }

		public decimal? RefundableTaxableAmount { get; set; }
		public decimal? RefundableTaxAmount { get; set; }
		public decimal RefundableItemSubtotal { get; set; }
		public decimal RefundableTotalPaid { get; set; }
		public decimal RefundableTotalDiscount { get; set; }


		public decimal? RefundedTaxableAmount { get; set; }
		public decimal? RefundedTaxAmount { get; set; }
		public decimal RefundedItemSubtotal { get; set; }
		public decimal RefundedTotalPaid { get; set; }
		public decimal RefundedTotalDiscount { get; set; }

		public long InvoiceRefNo { get; set; }
		public string InvoiceType { get; set; }
		public List<InvInvoiceDetailyRefundModel> InvoiceDetailList { get; set; }
		public List<InvInvoicePaymentyRefundModel> InvoicePaymentList { get; set; }
	}
}
