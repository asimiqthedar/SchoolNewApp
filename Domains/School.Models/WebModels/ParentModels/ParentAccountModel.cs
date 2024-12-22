namespace School.Models.WebModels.ParentModels
{
	public class ParentAccountModel
    {
        public int ParentAccountId { get; set; }
        public int ParentId { get; set; }
        public string ReceivableAccount { get; set; }
        public string AdvanceAccount { get; set; }
    }
}
