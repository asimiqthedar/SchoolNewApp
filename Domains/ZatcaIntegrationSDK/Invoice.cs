using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("16AB957F-2B2F-4575-96C6-D7CE759B2638")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class Invoice
    {
        public Invoice()
        {
        }
        /// <summary>
        /// must be reporting:1.0 
        /// 
        /// </summary>
        public string ProfileID { get; set; } // must be reporting:1.0
        /// <summary>
        /// رقم الفاتورة الداخلى فى النظام 
        /// 
        /// </summary>
        public string ID { get; set; } //  IRN
        /// <summary>
        /// GUID معرف عالمى فريد
        /// 
        /// </summary>
        public string UUID { get; set; }
        /// <summary>
        /// تاريخ الفاتورة بصيغة "yyyy-MM-dd"
        /// 
        /// </summary>
        public string IssueDate { get; set; }
        /// <summary>
        /// وقت الفاتورة بصيغة "HH-mm-ss"
        /// 
        /// </summary>
        public string IssueTime { get; set; }
        public InvoiceTypeCode invoiceTypeCode = new InvoiceTypeCode();
        /// <summary>
        ///ملاحظات اختيارى
        /// 
        /// </summary>
        public string Note { get; set; } // optional
        /// <summary>
        /// كود العملة للفاتورة 
        /// 
        /// </summary>
        public string DocumentCurrencyCode { get; set; } //SAR او اى عملة اخرى
        /// <summary>
        /// كود العملة للضريبة ودائما تكون SAR 
        /// 
        /// </summary>
        public string TaxCurrencyCode { get; set; } //SAR لابد تكون
        /// <summary>
        /// عدد اسطر الفاتورة 
        /// 
        /// </summary>
        public int LineCountNumeric { get; set; }
        /// <summary>
        /// بيانات الطلب أختيارى 
        /// 
        /// </summary>
        public OrderReference orderReference = new OrderReference();
        /// <summary>
        /// بيانات الفاتورة المرتبط بها الأشعار
        ///
        /// فى حالة اشعار دائن او مدين فقط
        /// </summary>
        public BillingReference billingReference = new BillingReference(); 
        /// <summary>
        /// بيانات العقود أن وجدت 
        /// 
        /// </summary>
        public ContractDocumentReference contractDocumentReference = new ContractDocumentReference(); //رقم العقد اختيارى
        /// <summary>
        /// بيانات عداد الفاتورة بالنسبة لل CSID
        /// 
        /// </summary>
        public AdditionalDocumentReference AdditionalDocumentReferenceICV = new AdditionalDocumentReference(); // Invoice counter value
        /// <summary>
        /// بيانات الهاش من الفاتورة السابقة  
        /// 
        /// </summary>
        public AdditionalDocumentReference AdditionalDocumentReferencePIH = new AdditionalDocumentReference(); //
        /// <summary>
        /// بيانات الكيو آر 
        /// 
        /// </summary>
        public AdditionalDocumentReference AdditionalDocumentReferenceQR = new AdditionalDocumentReference();
        /// <summary>
        /// بيانات البائع 
        /// 
        /// </summary>
        public AccountingSupplierParty SupplierParty = new AccountingSupplierParty();
        /// <summary>
        /// بيانات المشترى 
        /// 
        /// </summary>
        public AccountingCustomerParty CustomerParty = new AccountingCustomerParty();
        /// <summary>
        /// بيانات تاريخ التوريد 
        /// 
        /// أجبارى فى حالة فاتورة مبسطة وفاتورة ملخصة
        /// </summary>
        public Delivery delivery = new Delivery(); //
        /// <summary>
        /// طرق الدفع
        /// 
        /// </summary>
        public PaymentMeansCollection paymentmeans = new PaymentMeansCollection();
        /// <summary>
        /// الضريبة
        /// 
        /// </summary>
        public TaxTotal TaxTotal = new TaxTotal();
        /// <summary>
        /// الخصومات أو الرسوم 
        /// 
        /// </summary>
        public AllowanceChargeCollection allowanceCharges = new AllowanceChargeCollection();
        /// <summary>
        /// أجماليات الفاتورة
        /// 
        /// </summary>
        public LegalMonetaryTotal legalMonetaryTotal = new LegalMonetaryTotal();
        /// <summary>
        /// أسطر الفاتورة 
        /// 
        /// </summary>
        public InvoiceLineCollection InvoiceLines = new InvoiceLineCollection();
        /// <summary>
        /// بيانات التوقيع CSID 
        /// 
        /// </summary>
        public CSIDInfo cSIDInfo = new CSIDInfo();
        /// <summary>
        /// معدل تحويل العملة بالنسبة للريال السعودى
        /// 
        /// </summary>
        public decimal CurrencyRate { get; set; }
        
    }
}
