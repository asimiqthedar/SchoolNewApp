//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace School.Services.Entities
{
    using System;
    using System.Collections.Generic;
    
    public partial class SellerMaster
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
    }
}
