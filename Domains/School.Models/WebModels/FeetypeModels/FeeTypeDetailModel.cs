namespace School.Models.WebModels.FeetypeModels
{
	public class FeeTypeDetailModel
    {
        public FeeTypeDetailModel()
        {
            Grades = new List<long>();
        }
        public long FeeTypeId { get; set; }
        public long FeeTypeDetailId { get; set; }
        public long TermAcademicId { get; set; }

        public decimal TermFeeAmount { get; set; }

        public decimal StaffFeeAmount { get; set; }
        public List<long> Grades { get; set; }
    }
}