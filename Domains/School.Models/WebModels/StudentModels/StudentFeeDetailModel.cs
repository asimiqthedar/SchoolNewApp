using System.Data;

namespace School.Models.WebModels.StudentModels
{
	public class StudentFeeDetail
    {
        public bool IsReadOnly { get; set; }
        public long StudentId { get; set; }
        public DataSet StudentFeeRecords { get; set; }
    }
}
