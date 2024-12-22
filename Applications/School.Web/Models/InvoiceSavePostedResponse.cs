namespace School.Web.Models
{
	public class InvoiceSavePostedResponse
	{
		public int result { get; set; }
		public string message { get; set; }
		public bool isPrintNotRequired { get; set; }
		public long invoiceNo { get; set; }
	}
}
