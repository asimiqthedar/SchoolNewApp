namespace School.Models.WebModels.GenderModels
{
	public class OpenApplyModel
    {
        public OpenApplyModel()
        {
            IsActive = true;
        }
        public int OpenApplyId { get; set; }
       
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
        public string Audience { get; set; }
        public string GrantType { get; set; }
        public string OpenApplyJobPath { get; set; }
        public bool IsActive { get; set; }
    }
}
