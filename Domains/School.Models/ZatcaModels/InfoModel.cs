using System.Collections.Generic;
using System.ComponentModel;

namespace School.Models.ZatcaModels
{
    public enum InvoiceStatus
    {
        [Description("Reported")]
        Reported,
        [Description("Not Reported")]
        NotReported,
        [Description("Accepted with Warnings")]
        AcceptedWithWarnings
    }
    public class InfoModel
    {
        public string message { get; set; }
    }

    public class ErrorModel
    {
        public string category { get; set; }
        public string code { get; set; }
        public string message { get; set; }
    }

    public class WarningModel
    {
        public string category { get; set; }
        public string code { get; set; }
        public string message { get; set; }
    }

    public class InvoiceResultModel
    {
        public string invoiceHash { get; set; }
        public InvoiceStatus status { get; set; }
        public List<WarningModel> warnings { get; set; }
        public List<ErrorModel> erros { get; set; }
    }

    public class ClearedInvoiceResultModel
    {
        public string invoiceHash { get; set; }
        public string clearedInvoice { get; set; }
        public InvoiceStatus status { get; set; }
        public List<WarningModel> warnings { get; set; }
        public List<ErrorModel> erros { get; set; }
    }

    public class InvoiceRequest
    {
        public string invoiceHash { get; set; }
        public string invoice { get; set; }
    }
    public class CSRRequest
    {
        public string csr { get; set; }
    }

    public class CertificatesErrorsResponse
    {
        public List<ErrorModel> erros { get; set; }
    }
}
