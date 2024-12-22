namespace School.Models.WebModels.VatModels
{
	public class VatDetailModel
	{
		public long VatId { get; set; }
		public long FeeTypeId { get; set; }
		public string FeeTypeName { get; set; }
		public decimal VatTaxPercent { get; set; }
		public string DebitAccount { get; set; }
		public string CreditAccount { get; set; }
	}
}
