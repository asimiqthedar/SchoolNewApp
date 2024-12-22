namespace School.Models.WebModels.PaymentPlanModels
{
	public class PaymentPlanDetailModel
	{
		public string AcademicYear { get; set; }
		public string FeeType { get; set; }
		public decimal Fee { get; set; }
		public string Grade { get; set; }
		public long FeeTypeDetailId { get; set; }
	}
}
