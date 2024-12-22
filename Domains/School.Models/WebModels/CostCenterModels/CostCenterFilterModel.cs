namespace School.Models.WebModels.CostCenterModels
{
	public class CostCenterFilterModel
    {
        public CostCenterFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
