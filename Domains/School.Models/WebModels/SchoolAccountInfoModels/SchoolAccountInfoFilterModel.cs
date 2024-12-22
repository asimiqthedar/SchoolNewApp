namespace School.Models.WebModels.SchoolAccountInfoModels
{
	public class SchoolAccountInfoFilterModel
    {
        public SchoolAccountInfoFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
