namespace School.Models.WebModels.SchoolModels
{
	public class SchoolFilterModel
    {
        public SchoolFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
