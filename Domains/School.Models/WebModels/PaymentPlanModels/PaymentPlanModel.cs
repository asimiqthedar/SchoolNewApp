namespace School.Models.WebModels.PaymentPlanModels
{
	public class PaymentPlanModel
    {
        public long FeePaymentPlanId { get; set; }
        public long FeeTypeDetailId { get; set; }
        public decimal PaymentPlanAmount { get; set; }
        public DateTime DueDate { get; set; }
    }
    
}
