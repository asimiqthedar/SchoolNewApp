using System.Collections.Generic;

namespace School.Models.ZatcaModels
{    
    public enum ZATCAPaymentMethods
    {
        CASH = 10,
        CREDIT = 30,
        BANK_ACCOUNT = 42,
        BANK_CARD = 48
    }
    public enum ZATCAInvoiceTypes
    {
        INVOICE = 388,
        DEBIT_NOTE = 383,
        CREDIT_NOTE = 381
    }

    public class ZATCASimplifiedInvoiceProps
    {
        public ZATCASimplifiedInvoiceProps()
        {
            egs_info = new EGSUnitInfo();
            line_items = new List<ZATCASimplifiedInvoiceLineItem>();
            cancelation = new ZATCASimplifiedInvoicCancelation();
        }
        public EGSUnitInfo egs_info { get; set; }
        public int invoice_counter_number { get; set; }
        public string invoice_serial_number { get; set; }
        public string issue_date { get; set; }
        public string issue_time { get; set; }
        public string previous_invoice_hash { get; set; }
        public List<ZATCASimplifiedInvoiceLineItem> line_items { get; set; }
        public ZATCASimplifiedInvoicCancelation cancelation { get; set; }
    }

    public class ZATCASimplifiedInvoiceLineItemDiscount
    {
        public decimal amount { get; set; }
        public string reason { get; set; }
    }

    public class ZATCASimplifiedInvoiceLineItemTax
    {
        public decimal percent_amount { get; set; }
    }

    public class ZATCASimplifiedInvoiceLineItem
    {
        public ZATCASimplifiedInvoiceLineItem()
        {
            other_taxes = new List<ZATCASimplifiedInvoiceLineItemTax>();
            discounts = new List<ZATCASimplifiedInvoiceLineItemDiscount>();
        }
        public string id { get; set; }
        public string name { get; set; }
        public decimal quantity { get; set; }
        public decimal tax_exclusive_price { get; set; }
        public List<ZATCASimplifiedInvoiceLineItemTax> other_taxes { get; set; }
        public List<ZATCASimplifiedInvoiceLineItemDiscount> discounts { get; set; }
        public decimal VAT_percent { get; set; }
    }

    public class ZATCASimplifiedInvoicCancelation
    {
        public ZATCASimplifiedInvoicCancelation()
        {
            payment_method = new ZATCAPaymentMethods();
            cancelation_type = new ZATCAInvoiceTypes();
        }
        public int canceled_invoice_number { get; set; }
        public ZATCAPaymentMethods payment_method { get; set; }
        public ZATCAInvoiceTypes cancelation_type { get; set; }
        public string reason { get; set; }
    }

    #region EGS
    public class EGSUnitLocation
    {
        public string city { get; set; }
        public string city_subdivision { get; set; }
        public string street { get; set; }
        public string plot_identification { get; set; }
        public string building { get; set; }
        public string postal_zone { get; set; }
    }

    public class EGSUnitInfo
    {
        public string uuid { get; set; }
        public string custom_id { get; set; }
        public string model { get; set; }
        public string CRN_number { get; set; }
        public string VAT_name { get; set; }
        public string VAT_number { get; set; }
        public string branch_name { get; set; }
        public string branch_industry { get; set; }
        public EGSUnitLocation location { get; set; }

        public string private_key { get; set; }
        public string csr { get; set; }
        public string compliance_certificate { get; set; }
        public string compliance_api_secret { get; set; }
        public string production_certificate { get; set; }
        public string production_api_secret { get; set; }
    }


    #endregion
}
