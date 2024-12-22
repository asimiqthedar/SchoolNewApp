using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("3589718F-E887-4E06-9210-BBFA9380260A")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class AccountingCustomerParty
    {
        /// <summary>
        /// معرف أضافى بيانات للمشترى 
        /// 
        /// </summary>
        public PartyIdentification partyIdentification = new PartyIdentification();
        /// <summary>
        /// تفاصيل العنوان الوطنى بيانات المشترى 
        /// 
        /// </summary>
        public PostalAddress postalAddress = new PostalAddress();
        /// <summary>
        /// أسم المؤسسة المشترى 
        /// 
        /// </summary>
        public PartyLegalEntity partyLegalEntity = new PartyLegalEntity();
        /// <summary>
        /// بيانات رقم التسجيل الضريبيى المشترى 
        /// 
        /// </summary>
        public PartyTaxScheme partyTaxScheme = new PartyTaxScheme();
        /// <summary>
        /// بيانات أخرى للمشترى 
        /// 
        /// </summary>
        public Contact contact = new Contact();
    }
}
