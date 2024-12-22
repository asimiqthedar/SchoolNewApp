namespace School.Models.WebModels.SectionModels
{
	public class SectionModel
    {
        public SectionModel()
        {
            IsActive = true;
        }
        public int SectionId { get; set; }
        public string SectionName { get; set; }      
        public bool IsActive { get; set; }
    }
}
