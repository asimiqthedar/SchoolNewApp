using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class OrderReference
    {
        /// <summary>
        /// معرف أمر الشراء المرتبط.
        /// 
        /// يمثل رقم أمر الشراء الخاص بالطلب، وهو حقل اختياري.
        /// </summary>
        public string ID { get; set; } // أمر الشراء (اختياري)
    }
}
