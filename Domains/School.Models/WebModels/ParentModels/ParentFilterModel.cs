namespace School.Models.WebModels.ParentModels
{
	public class ParentFilterModel
    {
        public ParentFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public int FilterNationalityId { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
