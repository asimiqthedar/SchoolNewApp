namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvoiceFilterModel
    {
        public string InvoiceNo { get; set; }
        public string InvoiceType { get; set; }
        public string Status { get; set; }
        public string ParentCode { get; set; }
        public string ParentName { get; set; }
		public string FatherMobile { get; set; }
		public string InvoiceDateStart { get; set; }
        public string InvoiceDateEnd { get; set; }
		public string FatherIqama { get; set; }
	}
}
