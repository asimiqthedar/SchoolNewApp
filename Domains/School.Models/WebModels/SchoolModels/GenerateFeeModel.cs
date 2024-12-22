namespace School.Models.WebModels.SchoolModels
{
	public class GenerateFeeModel
    {
        public int FeeGenerateId { get; set; }
        public long SchoolAcademicId { get; set; }
        public long FeeTypeId { get; set; }
        public long GradeId { get; set; }
        public int ActionId { get; set; }
    }
}
