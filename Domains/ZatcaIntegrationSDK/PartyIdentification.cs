using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("FB892F0B-43FC-429D-A163-FB752E4898E9")]
    [ClassInterface(ClassInterfaceType.AutoDual)]

    public class PartyIdentification
    {
        /// <summary>
        /// رقم المعرف الخاص بالطرف.
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// عند إدخال الرقم التعريفي، يجب إدخال الرمز الخاص به.
        /// 
        /// الأنواع المتاحة:
        /// - CRN: رقم التسجيل التجاري
        /// - MOM: وزارة الشؤون البلدية والقروية والإسكان
        /// - MLS: وزارة العمل والتنمية الاجتماعية
        /// - SAG: التراخيص الاستثمارية
        /// - OTH: أي شيء آخر
        /// </summary>
        public string schemeID { get; set; }
    }

}
