namespace School.Models.ZatcaModels
{
	public class ZatcaResponse
    {
        public ZatcaResponse()
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
        public string InvoiceNo { get; set; }
    }
}