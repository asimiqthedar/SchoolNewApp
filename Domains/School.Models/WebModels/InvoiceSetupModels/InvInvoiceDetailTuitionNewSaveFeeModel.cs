namespace School.Models.WebModels.InvoiceSetupModels
{
	[Serializable]
	public class InvInvoiceDetailTuitionNewSaveFeeModel //: BaseInvoice
	{
		public InvInvoiceDetailTuitionNewSaveFeeModel()
		{
			TuitionFeeList = new List<InvInvoiceDetailTuitionNewFeeModel>();
		}
		public List<InvInvoiceDetailTuitionNewFeeModel> TuitionFeeList { get; set; }

		public string InvoiceSessionKey { get; set; }
		public long InvoiceNo { get; set; }

	}
}
