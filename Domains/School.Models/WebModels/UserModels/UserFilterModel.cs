namespace School.Models.WebModels.UserModels
{
	public class UserFilterModel
    {
        public UserFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public int FilterRoleId { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
