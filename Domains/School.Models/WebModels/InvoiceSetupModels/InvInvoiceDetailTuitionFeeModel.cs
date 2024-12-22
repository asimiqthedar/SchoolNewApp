namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceDetailTuitionFeeModel : BaseInvoice
	{
		public string AcademicYear { get; set; }
		public string AcademicYearName { get; set; }
		public bool IsAdvance { get; set; }
		public bool IsSameParent { get; set; } = false;
	}
}
