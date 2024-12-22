namespace School.Models.ZatcaModels
{
    public class CertificateRequestModel
    {
        public string ErrorMessage { get; set; }
        public bool IsSuccess { get; set; }
        public string CSR { get; set; }
        public string PrivateKey { get; set; }
        public string CSID { get; set; }
        public string SecretKey { get; set; }
    }
}
