using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ZatcaIntegrationSDK
{
    [Guid("862C833B-3A1E-4404-B18F-C662BB45CC82")]
    [ClassInterface(ClassInterfaceType.AutoDual)]
    
    public class PostalAddress
    {
        /// <summary>
        /// اسم الشارع (أجبارى) 
        /// 
        /// </summary>
        public string StreetName { get; set; }
        /// <summary>
        /// اسم شارع اضافى (اختيارى) 
        /// 
        /// </summary>
        public string AdditionalStreetName { get; set; }
        /// <summary>
        /// رقم المبنى أجبارى ولابد يكون 4 ارقام فقط 
        /// 
        /// </summary>
        public string BuildingNumber { get; set; }
        /// <summary>
        /// رقم القطعة أختيارى ولابد يكون 4 ارقام فقط أن وجد 
        /// 
        /// </summary>
        public string PlotIdentification { get; set; }
        /// <summary>
        /// أسم المدينة أجبارى 
        /// 
        /// </summary>
        public string CityName { get; set; }
        /// <summary>
        /// الرمز البريدى أجبارى ولابد يكون 5 ارقام فقط 
        /// 
        /// </summary>
        public string PostalZone { get; set; }
        /// <summary>
        /// أسم المحافظة أو القطاع أختيارى 
        /// 
        /// </summary>
        public string CountrySubentity { get; set; }
        /// <summary>
        /// اسم الحى اختيارى 
        /// 
        /// </summary>
        public string CitySubdivisionName { get; set; }
        /// <summary>
        /// الدولة أجبارى SA فى بيانات البائع 
        /// 
        /// </summary>

        public Country country = new Country();
       

    }
}
