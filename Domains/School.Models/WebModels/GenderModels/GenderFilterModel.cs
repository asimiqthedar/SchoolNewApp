namespace School.Models.WebModels.GenderModels
{
	public class GenderFilterModel
    {
        public GenderFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
