namespace School.Models.WebModels.SchoolModels
{
	public class SchoolModel
    {

        public SchoolModel()
        {
            IsActive = true;
        }
        public long SchoolId { get; set; }
        public string SchoolNameEnglish { get; set; }
        public string SchoolNameArabic { get; set; }
        public long BranchId { get; set; }
        public string BranchName { get; set; }
        public int CountryId { get; set; }
        public string CountryName { get; set; }
        public string City { get; set; }
        public string Address { get; set; }
        public string Telephone { get; set; }
        public string SchoolEmail { get; set; }
        public string WebsiteUrl { get; set; }
        public string VatNo { get; set; }
        public string Logo { get; set; }
        public bool IsActive { get; set; }
    }
}
