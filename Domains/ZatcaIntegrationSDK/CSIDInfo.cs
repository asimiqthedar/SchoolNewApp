using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace ZatcaIntegrationSDK
{
    [Guid("E49AB26B-B281-409B-898C-DF9B77335833")]
    [ClassInterface(ClassInterfaceType.AutoDual)]

    public class CSIDInfo
    {
        /// <summary>
        /// المفتاح العام publickey  - CSID
        /// </summary>
        public string CertPem { get; set; }
        /// <summary>
        /// طلب انشاء المفتاح العام 
        /// </summary>
        public string CSR { get; set; }
        /// <summary>
        /// المفتاح الخاص
        /// </summary>
        public string PrivateKey { get; set; }
        /// <summary>
        /// الباسورد 
        /// </summary>
        public string Secret { get; set; }
    }
}
