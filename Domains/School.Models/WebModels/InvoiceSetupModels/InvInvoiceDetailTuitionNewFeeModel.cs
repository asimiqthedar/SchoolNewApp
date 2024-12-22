namespace School.Models.WebModels.InvoiceSetupModels
{
	[Serializable]
	public class InvInvoiceDetailTuitionNewFeeModel : BaseInvoice
	{
		public string AcademicYear { get; set; }
		public string AcademicYearName { get; set; }
		public bool IsAdvance { get; set; }
	}
}
