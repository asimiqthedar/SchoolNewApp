namespace School.Models.WebModels.BranchModels
{
	public class BranchModel
    {
        public BranchModel()
        {
            IsActive = true;
        }
        public int BranchId { get; set; }
        public string BranchName { get; set; }     
        public bool IsActive { get; set; }
    }
}
