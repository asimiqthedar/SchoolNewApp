namespace School.Models.WebModels.InvoiceSetupModels
{
	public class BaseUserStudentInfo : BaseUserParentInfo
	{
		public string StudentId { get; set; }
		public string StudentName { get; set; }
		public string StudentCode { get; set; }
		public int? GradeId { get; set; }
	}
}
