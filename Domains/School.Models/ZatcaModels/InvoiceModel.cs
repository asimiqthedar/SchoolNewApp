using System;
using System.Collections.Generic;

namespace School.Models.ZatcaModels
{
    public class InvoiceModel
    {
        //ctor
        public InvoiceModel()
        {
            InvoiceSummaryModel = new InvoiceSummaryModel();
            InvoiceDetailModelLst = new List<InvoiceDetailModel>();
            UniformDetailModelLst = new List<UniformDetailModel>();
            InvoicePaymentModelLst = new List<InvoicePaymentModel>();
        }

        //public bool isFirstZatcaInvoice { get; set; }
        public InvoiceSummaryModel InvoiceSummaryModel { get; set; }

        public VWInvoiceModel VWInvoiceModel { get; set; }
        public List<InvoiceDetailModel> InvoiceDetailModelLst { get; set; }
        public List<UniformDetailModel> UniformDetailModelLst { get; set; }
        public List<InvoicePaymentModel> InvoicePaymentModelLst { get; set; }
    }

    public partial class UniformDetailModel
    {
        public int UniformDetailID { get; set; }
        public int ID { get; set; }
        public string InvoiceNo { get; set; }
        public string Description { get; set; }
        public string Grade { get; set; }
        public string Color { get; set; }
        public string Size { get; set; }
        public string Quantity { get; set; }
        public string UnitPrice { get; set; }
        public string TaxableAmount { get; set; }
        public string Discount { get; set; }
        public string TaxRate { get; set; }
        public string TaxAmount { get; set; }
        public string ItemSubtotal { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }
    }
    [Serializable]
    public class InvoiceSummaryModel
    {
        public long InvoiceId { get; set; }
        public long InvoiceNo { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string ChequeNo { get; set; }
        public string ParentID { get; set; }
        public string PublishedBy { get; set; }
        public DateTime InvoiceDate { get; set; }
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
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public string SignedXMLPath { get; set; }
		public string IqamaNumber { get; set; }
        
       
        public string InvoicePdfPath { get; set; }
        
        public bool? IsSentToZatca { get; set; }
        public string ClearedInvoice { get; set; }
        public string WarningMessage { get; set; }
        public int? StatusCode { get; set; }
        public string ParentId { get; set; }

        public decimal? TaxableAmount { get; set; }

        public decimal? TaxAmount { get; set; }

        public decimal ItemSubtotal { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime UpdateDate { get; set; }

        public int UpdateBy { get; set; }


        public long? InvoiceRefNo { get; set; }

    }
    [Serializable]
    public class InvoiceDetailModel
    {
        public long ID { get; set; }
        public string InvoiceNo { get; set; }
        public string InvoiceType { get; set; }

        public string Description { get; set; }
        public decimal Discount { get; set; }
        public decimal TaxableAmount { get; set; }
        public decimal TaxRate { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal ItemSubtotal { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public decimal Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        

    }
    [Serializable]

    public partial class InvoicePaymentModel
    {
        public long InvoicePaymentId { get; set; }
        public long InvoiceNo { get; set; }
        public string PaymentMethod { get; set; }
        public string PaymentReferenceNumber { get; set; }
        public decimal PaymentAmount { get; set; }
        public bool IsDeleted { get; set; }
        public System.DateTime UpdateDate { get; set; }
        public int UpdateBy { get; set; }
        public Nullable<long> InvoiceRefNo { get; set; }
        public Nullable<long> InvoicePaymentRefId { get; set; }	
		public Nullable<long> PaymentMethodId { get; set; }
	}
    public class VWInvoiceModel
    {
        public long ID { get; set; }
        public long RefID { get; set; }
        public Nullable<long> InvoiceNo { get; set; }
        //public string InvoiceNo { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string ChequeNo { get; set; }
        public string ParentID { get; set; }
        public string PublishedBy { get; set; }
        public DateTime InvoiceDate { get; set; }
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
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public decimal TotalItemSubtotal { get; set; }
        public decimal TotalTaxableAmount { get; set; }
        public decimal TotalTaxAmount { get; set; }
        public Nullable<long> RN { get; set; }
        public string FatherIQAMA { get; set; }
        public Nullable<System.DateTime> UpdateDate { get; set; }
        public int UpdateBy { get; set; }

    }

	[Serializable]
	public class InvoiceNonReportingModel
	{
		public long ID { get; set; }
		public long InvoiceNo { get; set; }
		public string Status { get; set; }
		public string InvoiceType { get; set; }
		public string ReportingStatus { get; set; }

		public string SignedXMLPath { get; set; }
		public string InvoicePdfPath { get; set; }
		public string QRCodePath { get; set; }
	}
}