using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class ClassifiedTaxCategory
    {
        /// <summary>
      /// كود الضريبة  
      /// </summary>
        public string ID {set; get;}
        /// <summary>
        /// نسبة الضريبة مثال 15 
        /// </summary>
        public decimal Percent { set; get; }

        public TaxScheme taxScheme = new TaxScheme();
    }
}
