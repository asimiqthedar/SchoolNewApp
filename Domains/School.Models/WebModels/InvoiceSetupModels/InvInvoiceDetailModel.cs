namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceDetailModel
	{
		public string IqamaNumber { get; set; }
		public string InvoiceSessionKey { get; set; }
		public string SessionKey { get; set; }
		public long InvoiceDetailId { get; set; }
		public long InvoiceNo { get; set; }
		public string AcademicYear { get; set; }

		public string AcademicYearName { get; set; }
		public string InvoiceType { get; set; }
		public string Description { get; set; }
		public string ItemCode { get; set; }
		public string StudentId { get; set; }
		public decimal? Discount { get; set; }
		public decimal Quantity { get; set; }
		public decimal UnitPrice { get; set; }
		public decimal? TaxableAmount { get; set; }
		public decimal? TaxRate { get; set; }
		public decimal? TaxAmount { get; set; }
		public decimal ItemSubtotal { get; set; }


		public int? GradeId { get; set; }
		public string? NationalityId { get; set; }

		public string ParentId { get; set; }
		public string ParentCode { get; set; }
		public string ParentName { get; set; }
		public string FatherMobile { get; set; }
		public string StudentCode { get; set; }

		public string StudentName { get; set; }
		public bool IsStaff { get; set; }
		public bool? IsAdvance { get; set; }

		public bool? IsEditRestricted { get; set; }
	}
}
