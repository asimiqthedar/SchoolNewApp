namespace School.Models.WebModels.VatModels
{
	public class InvoiceFeeDetailParentStudentModel : InvoiceFeeDetailModel
	{
		public long StudentId { get; set; }
		public string StudentName { get; set; }
		public string StudentArabicName { get; set; }
		public string GradeName { get; set; }
		public decimal VatPercent { get; set; }

		public long ParentId { get; set; }
		public string FatherName { get; set; }
		public string ParentCode { get; set; }
		public string FatherMobile { get; set; }
		public string StudentCode { get; set; }
	}
}
