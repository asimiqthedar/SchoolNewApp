namespace School.Models.WebModels.PaymentMethod
{
	public class PaymentMethodModel
	{
		public long PaymentMethodId { get; set; }
		public long PaymentMethodCategoryId { get; set; }
		public string PaymentMethodName { get; set; }
		public string DebitAccount { get; set; }
		public string CreditAccount { get; set; }
		public bool IsActive { get; set; }

	}
}
