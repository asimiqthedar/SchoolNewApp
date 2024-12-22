using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("A77FBE1C-D268-4E6D-AEF4-56A8F59012CE")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class Country
    {
        /// <summary>
        /// كود الدولة  
        /// 
        /// </summary>
        public string IdentificationCode { get; set; }
       
    }
}
