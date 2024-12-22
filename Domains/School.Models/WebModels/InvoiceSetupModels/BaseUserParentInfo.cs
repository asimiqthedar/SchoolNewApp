namespace School.Models.WebModels.InvoiceSetupModels
{
	public class BaseUserParentInfo
	{
		public string ParentId { get; set; }
		public string ParentCode { get; set; }
		public string ParentName { get; set; }
		public string FatherMobile { get; set; }
		public string? NationalityId { get; set; }
		public bool IsStaff { get; set; }
		public string IqamaNumber { get; set; }
		public string AcademicYear { get; set; } 
	}
}
