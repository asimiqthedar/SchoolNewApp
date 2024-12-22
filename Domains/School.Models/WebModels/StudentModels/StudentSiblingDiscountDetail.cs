using System.Data;

namespace School.Models.WebModels.StudentModels
{
	public class StudentSiblingDiscountDetail
	{
		public bool IsReadOnly { get; set; }
		public long StudentId { get; set; }
		public DataSet StudentSiblingDiscountRecords { get; set; }
	}

}
