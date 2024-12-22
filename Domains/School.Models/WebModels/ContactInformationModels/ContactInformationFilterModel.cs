namespace School.Models.WebModels.ContactInformationModels
{
	public class ContactInformationFilterModel
    {
        public ContactInformationFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
