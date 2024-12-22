using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface ISellerMasterManager
    {
        Task<SellerMaster> GetByRegistrationName(string registrationName);
        Task<SellerMaster> Get(long sellerId);
        Task<List<SellerMaster>> GetAll();
        Task<SellerMaster> Save(SellerMaster sellerMaster);
    }
    public class SellerMasterManager : ISellerMasterManager
    {
        private readonly ALSContext _ALSContextDB;
        public SellerMasterManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
           
        }

        public async Task<SellerMaster> Get(long sellerId)
        {
            var sellerMaster = _ALSContextDB.SellerMasters.FirstOrDefault(s => s.SellerId == sellerId);

            return sellerMaster;
        }

        public async Task<List<SellerMaster>> GetAll()
        {
            var sellerMaster = _ALSContextDB.SellerMasters.ToList();

            return sellerMaster;
        }

        public async Task<SellerMaster> GetByRegistrationName(string registrationName)
        {
            var sellerMaster = _ALSContextDB.SellerMasters.FirstOrDefault(s => s.OrganizationIdentifier == registrationName);

            return sellerMaster;
        }

        public async Task<SellerMaster> Save(SellerMaster sellerMaster)
        {
            if (sellerMaster.SellerId > 0)
            {
                var record = _ALSContextDB.SellerMasters.Where(s => s.SellerId == sellerMaster.SellerId).FirstOrDefault();
                if (record != null)
                {
                    record.SellerId = sellerMaster.SellerId;
                    record.CommonName = sellerMaster.CommonName;
                    record.OrganizationName = sellerMaster.OrganizationName;
                    record.OrganizationIdentifier = sellerMaster.OrganizationIdentifier;
                    record.OrganizationUnitName = sellerMaster.OrganizationUnitName;
                    record.Location = sellerMaster.Location;
                    record.Industry = sellerMaster.Industry;
                    record.SchemeType = sellerMaster.SchemeType;
                    record.SchemaNo = sellerMaster.SchemaNo;
                    record.CountryName = sellerMaster.CountryName;
                    record.CountyIdentificationCode = sellerMaster.CountyIdentificationCode;
                    record.DocumentCurrencyCode = sellerMaster.DocumentCurrencyCode;
                    record.TaxCurrencyCode = sellerMaster.TaxCurrencyCode;
                    record.CityName = sellerMaster.CityName;
                    record.StreetName = sellerMaster.StreetName;
                    record.BuildingNumber = sellerMaster.BuildingNumber;
                    record.CitySubdivisionName = sellerMaster.CitySubdivisionName;
                    record.PostalZone = sellerMaster.PostalZone;
                    record.UpdateBy = 1;
                    record.UpdateOn = DateTime.Now;
                }
            }
            else
            {
                sellerMaster.IsDeleted = false;
                sellerMaster.UpdateBy = 1;
                sellerMaster.UpdateOn = DateTime.Now;
                _ALSContextDB.SellerMasters.Add(sellerMaster);
            }         
            await _ALSContextDB.SaveChangesAsync();
            return sellerMaster;
        }
    }
}
