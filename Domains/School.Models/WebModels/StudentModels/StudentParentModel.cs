namespace School.Models.WebModels.StudentModels
{
	public class StudentParentModel
	{
		public int ParentId { get; set; }
		public string ParentCode { get; set; }
		public string ParentImage { get; set; }
		public string FatherName { get; set; }
		public string FatherArabicName { get; set; }
		public string FatherMobile { get; set; }
		public string FatherEmail { get; set; }
		public bool IsFatherStaff { get; set; }
		public string MotherName { get; set; }
		public string MotherArabicName { get; set; }
		public string MotherMobile { get; set; }
		public string MotherEmail { get; set; }
		public bool IsMotherStaff { get; set; }
	}
}
