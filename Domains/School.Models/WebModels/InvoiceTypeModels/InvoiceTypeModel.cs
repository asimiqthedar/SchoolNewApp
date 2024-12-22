namespace School.Models.WebModels.InvoiceTypeModels
{
	public class InvoiceTypeModel
    {
        public InvoiceTypeModel()
        {
            IsActive = true;
        }
        public int InvoiceTypeId { get; set; }
        public string InvoiceTypeName { get; set; }
        public string ReceivableAccount { get; set; }
        public string AdvanceAccount { get; set; }
        public string ReceivableAccountRemarks { get; set; }
        public string AdvanceAccountRemarks { get; set; }
        public bool IsActive { get; set; }
    }
}
