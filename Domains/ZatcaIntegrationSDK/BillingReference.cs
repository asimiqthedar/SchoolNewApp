using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class BillingReference
    {
        /// <summary>
        /// قائمة ببيانات الفواتير المرتبط بها الأشعار
        ///
        /// فى حالة اشعار دائن او مدين فقط
        /// </summary>
        public InvoiceDocumentReferenceCollection invoiceDocumentReferences = new InvoiceDocumentReferenceCollection();
    }
}
