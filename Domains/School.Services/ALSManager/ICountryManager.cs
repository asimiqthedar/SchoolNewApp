using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface ICountryManager
    {
        Task<TblCountryMaster> GetById(long countryId);
    }
    public class CountryManager : ICountryManager
    {
        private readonly ALSContext _ALSContextDB;
        public CountryManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<TblCountryMaster> GetById(long countryId)
        {
            return await _ALSContextDB.TblCountryMasters.FirstOrDefaultAsync(s => s.CountryId == countryId);
        }
    }
}