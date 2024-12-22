using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class Price
    {
        /// <summary>
        /// سعر الصنف 
        /// </summary>
        public decimal PriceAmount { set; get; }
        /// <summary>
        ///  LineExtensionAmount=(PriceAmount/BaseQuantity)*InvoicedQuantity
        /// </summary>
        public decimal BaseQuantity { set; get; }
        /// <summary>
        /// سعر الصنف شامل الضريبة True
        /// 
        /// سعر الصنف قبل الضريبة False
        /// </summary>
        public bool EncludingVat { set; get; }
        
        public AllowanceCharge allowanceCharge = new AllowanceCharge();

    }
}
