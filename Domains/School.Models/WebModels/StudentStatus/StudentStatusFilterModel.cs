namespace School.Models.WebModels.StudentStatus
{
	public class StudentStatusFilterModel
    {
        public StudentStatusFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
