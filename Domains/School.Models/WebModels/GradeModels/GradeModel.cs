namespace School.Models.WebModels.GradeModels
{
	public class GradeModel
    {
        public GradeModel()
        {
            IsActive = true;
        }
        public int GradeId { get; set; }
        public string GradeName { get; set; }
        public int SequenceNo { get; set; }
        public int MaxSequenceNo { get; set; }
        public int CostCenterId { get; set; }
        public string CostCenterName { get; set; }
        public int GenderTypeId { get; set; }
        public string GenderTypeName { get; set; }
        public bool IsActive { get; set; }
        public string DebitAccount { get; set; }
        public string CreditAccount { get; set; }
    }   
}
