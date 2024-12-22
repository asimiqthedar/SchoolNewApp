namespace School.Models.WebModels.FeetypeModels
{
	public class FeeTypeModel
    {
        public FeeTypeModel()
        {
            IsTermPlan = false;
            IsPaymentPlan = false;
            IsPrimary = false;
        }
        public long FeeTypeId { get; set; }
        public string FeeTypeName { get; set; }
        public bool IsPrimary { get; set; }
        public bool IsGradeWise { get; set; }
        public bool IsTermPlan { get; set; }
        public bool IsPaymentPlan { get; set; }
        public string DebitAccount { get; set; }
        public string CreditAccount { get; set; }
    }
}
