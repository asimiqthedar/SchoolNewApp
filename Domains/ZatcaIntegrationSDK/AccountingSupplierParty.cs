using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("699D816D-EB97-4CF0-8621-BF49FA427E9F")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class AccountingSupplierParty
    {
        /// <summary>
        /// معرف أضافى بيانات البائع 
        /// 
        /// </summary>
        public PartyIdentification partyIdentification = new PartyIdentification();
        /// <summary>
        /// تفاصيل العنوان الوطنى بيانات البائع 
        /// 
        /// </summary>
        public PostalAddress postalAddress = new PostalAddress();
        /// <summary>
        /// أسم المؤسسة البائع 
        /// 
        /// </summary>
        public PartyLegalEntity partyLegalEntity = new PartyLegalEntity();
        /// <summary>
        /// بيانات رقم التسجيل الضريبيى البائع 
        /// 
        /// </summary>
        public PartyTaxScheme partyTaxScheme = new PartyTaxScheme();
    }
}
