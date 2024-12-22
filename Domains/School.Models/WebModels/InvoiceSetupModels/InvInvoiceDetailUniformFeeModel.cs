namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceDetailUniformFeeModel : BaseInvoice
	{
		public string ItemCode { get; set; }
		public string Description { get; set; }
		public decimal Quantity { get; set; }
		public decimal AvailableQuantity { get; set; }
		public bool IsEditMode { get; set; }

	}
}
