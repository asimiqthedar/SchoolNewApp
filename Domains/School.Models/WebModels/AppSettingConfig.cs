namespace School.Models.WebModels
{
	public class AppSettingConfig
    {
        public string ConnectionString { get; set; }
        public int SessionTime { get; set; }
        public string VertualDirectoryPath { get; set; }
        public string To { get; set; }
        public string UniformDB { get; set; }
        public string IsAllowEmail { get; set; }
        public string IsAllowInvoicePostClearance { get; set; }
		public string EnablePDFGenerateOnSave { get; set; }
        public string InvoiceProcessMode { get; set; }
        public string InvoicePdfPath { get; set; }
       
	}
}
