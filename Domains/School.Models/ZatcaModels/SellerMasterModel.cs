using System.Collections.Generic;


namespace School.Models.ZatcaModels
{
    public class SellerMasterModel
    {
        public long SellerId { get; set; }
        public string CommonName { get; set; }
        public string OrganizationName { get; set; }
        public string OrganizationIdentifier { get; set; }
        public string OrganizationUnitName { get; set; }
        public string Location { get; set; }
        public string Industry { get; set; }
        public string SchemeType { get; set; }
        public string SchemaNo { get; set; }
        public string CountryName { get; set; }
        public string CountyIdentificationCode { get; set; }
        public string DocumentCurrencyCode { get; set; }
        public string TaxCurrencyCode { get; set; }
        public string CityName { get; set; }
        public string StreetName { get; set; }
        public string BuildingNumber { get; set; }
        public string CitySubdivisionName { get; set; }
        public string PostalZone { get; set; }
        public bool IsDeleted { get; set; }
        public System.DateTime UpdateOn { get; set; }
        public long UpdateBy { get; set; }

       // public List<SelectListItem> InvoiceTypeList { get; set; }
        public string InvoiceType { get; set; }
    }

    public class SellerDeviceConfigurationModel
    {
        public long SellerId { get; set; }
        public string UserName { get; set; }
        public string DeviceManufacturer { get; set; }
        public string DeviceName { get; set; }
        public string DeviceId { get; set; }
        public string SerialNumber { get; set; }
        public bool IsDeleted { get; set; }
        public System.DateTime UpdateOn { get; set; }
        public long UpdateBy { get; set; }

        public long SellerDeviceConfigurationId { get; set; }
       
    }

    public partial class DeviceZatcaDetailModel
    {        
        public long DeviceZatcaDetailId { get; set; }
        public long SellerDeviceConfigurationId { get; set; }
        public string Mode { get; set; }
        public string CSR { get; set; }
        public string PrivateKey { get; set; }
        public string PubickKey { get; set; }
        public string SecretKey { get; set; }
        public bool IsDeleted { get; set; }
        public System.DateTime UpdateOn { get; set; }
        public long UpdateBy { get; set; }

        public string OTP { get; set; }
        public string InvoiceType { get; set; }
        public string ProcessMode { get; set; }
        //public List<SelectListItem> InvoiceTypeList { get; set; }
    }


    //public class SellerCsrModel
    //{
    //    public long SellerCsrid { get; set; }

    //    public long SellerId { get; set; }

    //    public string Csr { get; set; }

    //    public string PrivateKey { get; set; }

    //    public string Csrhash { get; set; }

    //    public string PrivateKeyHash { get; set; }

    //    public string Mode { get; set; }

    //    public string Otp { get; set; }

    //    public string InvoiceType { get; set; }
    //}

    //public class SellerCSIDModel
    //{
    //    public long SellerId { get; set; }

    //    public string UserName { get; set; }

    //    public string Password { get; set; }

    //    public string OTP { get; set; }
    //}

    //public class SellerCsidResponse
    //{
    //    public long requestID { get; set; }

    //    public string dispositionMessage { get; set; }

    //    public string binarySecurityToken { get; set; }

    //    public string secret { get; set; }
    //    public string errors { get; set; }
    //}
}
