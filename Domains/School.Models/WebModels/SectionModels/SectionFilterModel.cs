namespace School.Models.WebModels.SectionModels
{
	public class SectionFilterModel
    {
        public SectionFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
