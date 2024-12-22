namespace School.Models.WebModels.StudentModels
{
	public class OtherDiscountDetailModel
	{
		public OtherDiscountDetailModel()
		{
			DiscountAmount = 0.00M;
		}
		public long StudentId { get; set; }
		public long StudentOtherDiscountDetailId { get; set; }
		public decimal AcademicYearId { get; set; }
		public string DiscountName { get; set; }
		public decimal DiscountAmount { get; set; }

	}
	
}
