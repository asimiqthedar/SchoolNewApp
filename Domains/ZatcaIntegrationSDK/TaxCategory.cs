using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class TaxCategory
    {
        /// <summary>
        /// S means standard rated ضريبة القيمة المضافة
        /// Z means Zero rated ضريبة صفرية
        /// E means Exempt from vat معفى من الضريبة
        /// O means Not Subject to VAT غير خاضع للضريبة
        /// </summary>
        public string ID { set; get; }
        /// <summary>
        /// نسبة الضريبة
        /// 
        /// </summary>
        public decimal Percent { set; get; }
        /// <summary>
        ///  سبب الأعفاء
        /// 
        /// </summary>
        public string TaxExemptionReason { set; get; }
        /// <summary>
        /// كود سبب الاعفاء
        /// 
        /// </summary>
        public string TaxExemptionReasonCode { set; get; }

        
        public TaxScheme taxScheme = new TaxScheme();
    }
}
