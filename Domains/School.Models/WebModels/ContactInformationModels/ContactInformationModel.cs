namespace School.Models.WebModels.ContactInformationModels
{
	public class ContactInformationModel
    {
        public ContactInformationModel()
        {
            IsActive = true;
        }
        public int ContactId { get; set; }
        public long SchoolId { get; set; }
        public string ContactPerson { get; set; }
        public string ContactPosition { get; set; }
        public string ContactTelephone { get; set; }
        public string ContactEmail { get; set; }
        public bool IsActive { get; set; }
    }
}
