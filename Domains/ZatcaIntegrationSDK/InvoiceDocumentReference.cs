using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class InvoiceDocumentReference
    {
        /// <summary>
        ///رقم الفاتورة المرتبط بها الأشعار IRN
        ///
        /// فى حالة اشعار دائن او مدين فقط
        /// </summary>
        public string ID { get; set; }
    }
}
