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
    
    public partial class vw_Invoices
    {
        public Nullable<long> RN { get; set; }
        public Nullable<long> InvoiceNo { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string ChequeNo { get; set; }
        public string ParentID { get; set; }
        public string PublishedBy { get; set; }
        public Nullable<System.DateTime> InvoiceDate { get; set; }
        public string CreditNo { get; set; }
        public string InvoiceType { get; set; }
        public string CreditReason { get; set; }
        public string CustomerName { get; set; }
        public string ParentName { get; set; }
        public string EmailID { get; set; }
        public string MobileNo { get; set; }
        public string Nationality { get; set; }
        public string Address { get; set; }
        public string GPVoucherNo { get; set; }
        public string VATNo { get; set; }
        public string EncodedInvoice { get; set; }
        public string InvoiceHash { get; set; }
        public string UUID { get; set; }
        public string ReportingStatus { get; set; }
        public string QRCodePath { get; set; }
        public string SignedXMLPath { get; set; }
        public Nullable<System.DateTime> UpdateDate { get; set; }
        public int UpdateBy { get; set; }
        public decimal TotalItemSubtotal { get; set; }
        public decimal TotalTaxableAmount { get; set; }
        public decimal TotalTaxAmount { get; set; }
        public string FatherIQAMA { get; set; }
    }
}