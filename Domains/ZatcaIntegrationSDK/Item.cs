using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    public class Item
    {
        /// <summary>
        /// أسم الصنف 
        /// </summary>
        public string Name { set; get; }
        /// <summary>
        /// الضريبة الخاضع لها الصنف 
        /// </summary>
        public ClassifiedTaxCategory classifiedTaxCategory = new ClassifiedTaxCategory();
        /// <summary>
        /// كود الصنف بالنسبة للمشترى 
        /// </summary>
        public string BuyersItemIdentificationID { set; get; }
        /// <summary>
        /// كود الصنف بالنسبة للبائع 
        /// </summary>
        public string SellersItemIdentificationID { set; get; }
        /// <summary>
        /// الكود الخاص بالصنف  
        /// </summary>
        public string StandardItemIdentificationID { set; get; }

    }
}
