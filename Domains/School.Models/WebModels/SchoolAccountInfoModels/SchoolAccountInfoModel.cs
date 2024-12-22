namespace School.Models.WebModels.SchoolAccountInfoModels
{
	public class SchoolAccountInfoModel
    {
        public long SchoolAccountIId { get; set; }
        public long SchoolId { get; set; }
        public string ReceivableAccount { get; set; }
        public string AdvanceAccount { get; set; }
        public string CodeDescription { get; set; }
    }
}
