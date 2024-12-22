namespace School.Models.WebModels.GenderModels
{
	public class GenderModel
    {
        public GenderModel()
        {
            IsActive = true;
        }
        public int GenderTypeId { get; set; }
        public string GenderTypeName { get; set; }

        public string DebitAccount { get; set; }
        public string CreditAccount { get; set; }
        public bool IsActive { get; set; }
    }
}
