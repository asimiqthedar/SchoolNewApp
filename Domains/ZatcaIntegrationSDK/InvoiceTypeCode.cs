using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("3F2C46B0-9CFE-4B45-A7D6-45ED8D7103F2")]
    [ClassInterface(ClassInterfaceType.AutoDual)]

    public class InvoiceTypeCode
    {
        /// <summary>
        /// كود نوع الملف (فاتورة - أشعار دائن - أشعار مدين)
        /// 
        /// الأنواع المتاحة:
        /// 
        /// - فاتورة ضريبية أو مبسطة: 388
        /// - إشعار مدين: 383
        /// - إشعار دائن: 381
        /// </summary>
        public int id { get; set; }

        /// <summary>
        /// الكود الممثل لنوع الفاتورة بناءً على التنسيق NNPNESB
        /// 
        /// NN:
        /// - 01 للفاتورة الضريبية
        /// - 02 للفاتورة الضريبية المبسطة
        ///
        /// P:
        /// - في حالة فاتورة لطرف ثالث نكتب 1، وفي الحالة الأخرى نكتب 0
        ///
        /// N:
        /// - في حالة فاتورة اسمية نكتب 1، وفي الحالة الأخرى نكتب 0
        ///
        /// E:
        /// - في حالة فاتورة للصادرات نكتب 1، وفي الحالة الأخرى نكتب 0
        ///
        /// S:
        /// - في حالة فاتورة ملخصة نكتب 1، وفي الحالة الأخرى نكتب 0
        ///
        /// B:
        /// - في حالة فاتورة ذاتية نكتب 1
        /// - إذا كانت الفاتورة صادرات = 1، لا يمكن أن تكون الفاتورة ذاتية = 1
        /// </summary>
        public string Name { get; set; }
    }


}
