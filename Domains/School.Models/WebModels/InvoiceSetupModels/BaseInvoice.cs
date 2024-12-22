namespace School.Models.WebModels.InvoiceSetupModels
{
	public class BaseInvoice : BaseUserInfo
	{
		public long InvoiceNo { get; set; }
		public long InvoiceDetailId { get; set; }
		public decimal? Discount { get; set; }
		public decimal? TaxRate { get; set; }
		public decimal ItemSubtotal { get; set; }
		public decimal UnitPrice { get; set; }
		public decimal? TaxableAmount { get; set; }
		public decimal? TaxAmount { get; set; }
		public decimal UnitPriceAvailable { get; set; }
	}
}
