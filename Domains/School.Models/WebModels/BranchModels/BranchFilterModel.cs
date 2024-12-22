namespace School.Models.WebModels.BranchModels
{
	public class BranchFilterModel
    {
        public BranchFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
