namespace School.Models.WebModels.StudentModels
{
	public class StudentFeeMasterModel
	{
		public long StudentFeeDetailId { get; set; }
		public long StudentId { get; set; }
		public long AcademicYearId { get; set; }
		public long GradeId { get; set; }
		public long FeeTypeId { get; set; }
		public decimal FeeAmount { get; set; }
	}
}
