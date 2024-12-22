namespace School.Models.WebModels.SchoolAcademicModels
{
	public class SchoolAcademicModel
    {
        public SchoolAcademicModel()
        {
            IsActive = true;
        }
        public int SchoolAcademicId { get; set; }
        public string AcademicYear { get; set; }
        public string PeriodFrom { get; set; }
        public string PeriodTo { get; set; }
        public string DebitAccount { get; set; }
        public string CreditAccount { get; set; }
        public bool IsActive { get; set; }
        public bool IsCurrentYear { get; set; }
    }
}
