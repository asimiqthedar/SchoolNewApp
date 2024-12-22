namespace School.Models.WebModels.ConfigModel
{
	public class EmailConfigModel
    {
       public long EmailConfigId { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public bool EnableSSL { get; set; }
        public string FromEmail { get; set; }
    }
}
