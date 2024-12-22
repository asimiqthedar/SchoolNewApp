namespace School.Models.WebModels.StudentModels
{
	public class StudentFilterModel
    {
        public StudentFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public int FilterNationalityId { get; set; }
        public int FilterStatusId { get; set; }
        public int FilterGenderId { get; set; }
        public int FilterGradeId { get; set; }
        public int FilterCostCenterId { get; set; }
        public string FilterEmail { get; set; }
        public string FilterMobileNumber { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
