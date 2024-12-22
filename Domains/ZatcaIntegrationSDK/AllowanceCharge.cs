using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class AllowanceCharge
    {
        public string ID { get; set; }
        /// <summary>
        /// المعامل الذى يحدد اذا كان خصم او رسوم
        /// 
        /// فى حالة الخصم False
        /// 
        /// فى حالة الرسوم True
        /// 
        /// </summary>
        public bool ChargeIndicator { get; set; } = false; // 
        /// <summary>
        /// نسبة الخصم أو الرسوم 
        /// 
        /// عند كتابة النسبة اكبر من صفر يجب كتابة BaseAmount
        /// 
        /// </summary>
        public decimal MultiplierFactorNumeric { get; set; } // من صفر لحد 100 ورقمين بعد العلامة
        /// <summary>
        /// مبلغ الخصم أو الرسوم 
        /// </summary>
        public decimal Amount { get; set; }
        /// <summary>
        /// سبب الخصم أو الرسوم 
        /// </summary>
        public string AllowanceChargeReason { get; set; }
        /// <summary>
        /// كود الخصم او الرسوم 
        /// </summary>
        public string AllowanceChargeReasonCode { get; set; }
        public decimal BaseAmount { get; set; }
        /// <summary>
        /// تحديد كود الضريبة التى سوف يتم عمل الخصم او الرسوم عليها   
        /// </summary>

        public TaxCategory taxCategory = new TaxCategory();


    }
}
