namespace School.Models.WebModels.VatModels
{
	public class InvoiceFeeDetailModel
	{
		public long FeeTypeDetailId { get; set; }
		public long FeeTypeId { get; set; }
		public long AcademicYearId { get; set; }
		public long GradeId { get; set; }
		public decimal TermFeeAmount { get; set; }
		public decimal StaffFeeAmount { get; set; }
		public decimal FinalFeeAmount { get; set; }
		public bool IsStaffMember { get; set; }
		public bool? IsAdvance { get; set; }
	}
}
