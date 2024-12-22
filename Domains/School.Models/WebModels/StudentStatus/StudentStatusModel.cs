namespace School.Models.WebModels.StudentStatus
{
	public class StudentStatusModel
    {
        public StudentStatusModel()
        {
            IsActive = true;
        }
        public int StudentStatusId { get; set; }
        public string StatusName { get; set; }
        public bool IsActive { get; set; }
    }
}
