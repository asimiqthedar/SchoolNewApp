namespace School.Models.WebModels.ConfigModel
{
	public class WhatsappConfigModel
    {
        public long WhatsAppConfigId { get; set; }
        public string AccountSid { get; set; }
        public string AuthToken { get; set; }
        public string PhoneNumber { get; set; }
        public bool SandboxMode { get; set; }
        public string StatusCallbackUrl { get; set; }
    }
}
