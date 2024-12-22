using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class TaxSubtotal
    {
        /// <summary>
        /// المبلغ الخاضع للضريبة
        /// 
        /// </summary>
        public decimal TaxableAmount { set; get; }
        /// <summary>
        /// مبلغ الضريبة
        /// 
        /// </summary>
        public decimal TaxAmount { set; get; }
        /// <summary>
        /// فئة الضريبة 
        /// 
        /// </summary>
        public TaxCategory taxCategory = new TaxCategory();
    }
}
