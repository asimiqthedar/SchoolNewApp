namespace School.Models.WebModels
{
	public class EmailConfiguration
    {
        #region Comment 
        //public string From { get; set; }
        //public string SmtpServer { get; set; }
        //public int Port { get; set; }
        //public string UseridPasswordRequired { get; set; }
        //public string UserName { get; set; }
        //public string Password { get; set; }
        //public string To { get; set; } 
        #endregion
        //EmailConfigId,Host,[Port],Username,[Password],EnableSSL,FromEmail
        public int EmailConfigId { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public bool EnableSSL { get; set; }
        public string FromEmail { get; set; }
        public string To { get; set; }
    }
}
