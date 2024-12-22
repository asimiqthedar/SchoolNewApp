namespace School.Models.ZatcaModels
{
	public class InvoiceGridListModel
    {
        public bool IsSelected { get; set; }
        public long ID { get; set; }
        public int InvoiceNo { get; set; }
        public string ParentID { get; set; }
        public string ParentName { get; set; }
        public string Nationality { get; set; }
        public string TotalItemSubtotal { get; set; }
        public string PaymentMethod { get; set; }

        public string InvoiceDate { get; set; }
        public string InvoiceType { get; set; }
        public string ReportingStatus { get; set; }
        public string FatherIQAMA { get; set; }
    }
}