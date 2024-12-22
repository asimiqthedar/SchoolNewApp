using System.Data;

namespace School.Models.WebModels.StudentModels
{
	public class StudentOtherDiscountDetail
	{
		public bool IsReadOnly { get; set; }
		public long StudentId { get; set; }
		public DataSet StudentOtherDiscountRecords { get; set; }
	}
}
