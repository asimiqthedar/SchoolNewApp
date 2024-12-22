namespace School.Models.WebModels.FeetypeModels
{
	public class FeeTermDetailSaveModel
	{
		public long FeeTypeId { get; set; }
		public string FeeTypeName { get; set; }
		public bool IsTermPlan { get; set; }
		public bool IsPaymentPlan { get; set; }

		public long FeeTypeDetailId { get; set; }
		public long AcademicYearId { get; set; }

		public decimal TermFeeAmount { get; set; }

		public decimal StaffFeeAmount { get; set; }
		public long GradeId { get; set; }
		public string GradeName { get; set; }
		public bool IsActive { get; set; }
		public string AcademicYear { get; set; }
		public int TotalTerm { get; set; }
		public string GradeRules { get; set; }
	}
}
