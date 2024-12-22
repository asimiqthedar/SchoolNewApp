namespace School.Models.WebModels.DocumentTypeModels
{
	public class DocumentTypeModel
    {
        public DocumentTypeModel()
        {
            IsActive = true;
        }
        public int DocumentTypeId { get; set; }
        public string DocumentTypeName { get; set; }
        public string Remarks { get; set; }
        public bool IsActive { get; set; }
    }
}
