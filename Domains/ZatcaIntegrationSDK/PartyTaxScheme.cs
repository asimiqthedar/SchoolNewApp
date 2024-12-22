using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("26F69FFE-4B04-4DAB-99BD-652649CBD4B8")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class PartyTaxScheme
    {
        /// <summary>
        /// الرقم الضريبيى ويجب ان يكون 15 رقم يبدأ برقم 3 وينتهى برقم 3 
        /// 
        /// </summary>
        public string CompanyID { get; set; }
        public TaxScheme taxScheme = new TaxScheme();
    }
}
