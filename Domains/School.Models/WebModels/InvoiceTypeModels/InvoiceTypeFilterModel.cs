namespace School.Models.WebModels.InvoiceTypeModels
{
	public class InvoiceTypeFilterModel
    {
        public InvoiceTypeFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
