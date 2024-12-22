namespace School.Web.Models
{
	public class ZatcaResponseModel
	{
		public ZatcaResponseModel()
		{
			QRImg = "";
			IsSuccess = false;
			Result = -1;
			ErrorMessage = "";
			InvoiceHTML = "";
			WarningMessage = "";
			PdfPath = "";
			XMLFilePath = "";
		}
		public bool IsSuccess { get; set; }
		public int Result { get; set; }
		public string QRImg { get; set; }
		public string PdfPath { get; set; }
		public string XMLFilePath { get; set; }
		public string InvoiceHTML { get; set; }
		public string ReportingStatus { get; set; }
		public string ErrorMessage { get; set; }
		public string WarningMessage { get; set; }
		public long InvoiceNo { get; set; }
        public int StatusCode { get; set; }

    }
}
