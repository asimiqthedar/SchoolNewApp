using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("1B5D929C-F65F-4C56-9A97-C67DBCEFF983")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class InvoiceLine
    {
        /// <summary>
        /// رقم السطر فى الفاتورة 
        /// </summary>
        public string ID { set; get; }
        /// <summary>
        /// الكمية 
        /// </summary>
        public decimal InvoiceQuantity { set; get; }
        /// <summary>
        /// مبلغ سطر الفاتورة قبل الضريبة 
        /// </summary>
        public decimal LineExtensionAmount { set; get; }

        //public AllowanceCharge allowanceCharge = new AllowanceCharge();
        /// <summary>
        /// بيانات الخصومات أو الرسوم على مستوى سطر الفاتورة 
        /// </summary>
        public AllowanceChargeCollection allowanceCharges = new AllowanceChargeCollection();
        /// <summary>
        /// بيانات الضريبة على مستوى سطر الفاتورة 
        /// </summary>
        public TaxTotal taxTotal = new TaxTotal();
        /// <summary>
        /// بيانات الصنف 
        /// </summary>
        public Item item = new Item();
        /// <summary>
        /// بيانات السعر 
        /// </summary>
        public Price price = new Price();
        /// <summary>
        /// بيانات الدفعات المقدمة ان وجدت 
        /// </summary>
        public DocumentReferenceCollection documentReferences = new DocumentReferenceCollection();
    }
}
