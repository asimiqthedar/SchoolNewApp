namespace School.Models.WebModels.SchoolTermAcademicModels
{
	public class SchoolTermAcademicModel
    {
       
        public int SchoolTermAcademicId { get; set; }
        public int SchoolAcademicId { get; set; }
        public string AcademicYear { get; set; }
       // public int TermId { get; set; }
        public string TermName { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
    }
}
