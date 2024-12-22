using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class DocumentReference
    {
        /// <summary>
        /// رقم فاتورة الدفعة المقدمة 
        /// </summary>
        public string ID { get; set; }
        /// <summary>
        /// UUID الخاص بفاتورة الدفعة المقدمة
        /// </summary>
        public string UUID { get; set; }
        /// <summary>
        /// تاريخ فاتورة الدفعة المقدمة 
        /// </summary>
        public string IssueDate { get; set; }
        /// <summary>
        /// وقت فاتورة الدفعة المقدمة 
        /// </summary>
        public string IssueTime { get; set; }
        /// <summary>
        /// 386 كود الدفعة المقدمة 
        /// </summary>
        public int DocumentTypeCode { get; set; }
    }
}
