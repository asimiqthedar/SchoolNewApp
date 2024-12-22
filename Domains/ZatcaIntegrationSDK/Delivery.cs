using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class Delivery
    {
        /// <summary>
        /// بداية تاريخ التوريد
        /// 
        /// </summary>
        public string ActualDeliveryDate { get; set; }
        /// <summary>
        /// آخر تاريخ التوريد
        /// 
        /// </summary>
        public string LatestDeliveryDate { get; set; }
    }
}
