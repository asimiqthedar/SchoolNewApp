namespace School.Models.WebModels.CostCenterModels
{
	public class CostCenterModel
    {
        public CostCenterModel()
        {
            IsActive = true;
        }
        public int CostCenterId { get; set; }
        public string CostCenterName { get; set; }
        public string Remarks { get; set; }     
        public bool IsActive { get; set; }
        public string DebitAccount { get; set; }
        public string CreditAccount { get; set; }
    }
}
