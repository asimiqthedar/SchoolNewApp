namespace School.Models.WebModels.DocumentTypeModels
{
	public class DocumentTypeFilterModel
    {
        public DocumentTypeFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
