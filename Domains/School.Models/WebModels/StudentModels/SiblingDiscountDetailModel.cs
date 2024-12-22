namespace School.Models.WebModels.StudentModels
{
	public class SiblingDiscountDetailModel
    {
        public SiblingDiscountDetailModel()
        {
            DiscountPercent = 0.00M;
			DiscountAmount = 0.00M;
		}
        public long StudentId { get; set; }
        public long StudentSiblingDiscountDetailId { get; set; }
        public decimal AcademicYearId { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal DiscountAmount { get; set; }
    }
}
