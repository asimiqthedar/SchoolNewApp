using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class LegalMonetaryTotal
    {
        /// <summary>
        /// أجمالى الاصناف فى الفاتورة 
        /// </summary>
        public decimal LineExtensionAmount { set; get; } // sum of invoice line net amount
        /// <summary>
        /// أجمالى الفاتورة قبل الضريبة 
        /// </summary>
        public decimal TaxExclusiveAmount { set; get; } // total amount of invoice without vat
        /// <summary>
        /// أجمالى الفاتورة شامل الضريبة 
        /// </summary>
        public decimal TaxInclusiveAmount { set; get; }
        /// <summary>
        /// مبلغ الخصم على مستوى الفاتورة 
        /// </summary>
        public decimal AllowanceTotalAmount { set; get; } // invoice total amount - net amount
        /// <summary>
        /// مبلغ الرسوم على مستوى الفاتورة 
        /// </summary>
        public decimal ChargeTotalAmount { set; get; }
        /// <summary>
        /// المبلغ المدفوع 
        /// </summary>
        public decimal PayableAmount { set; get; }
        /// <summary>
        /// مبلغ الدفعات المدفوعة مقدما 
        /// </summary>
        public decimal PrepaidAmount { set; get; }
        /// <summary>
        /// التقريب  
        /// </summary>
        public decimal PayableRoundingAmount { set; get; }


    }
}
