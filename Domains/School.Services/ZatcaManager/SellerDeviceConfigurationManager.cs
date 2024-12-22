using Microsoft.EntityFrameworkCore;
using School.Services.Entities;
namespace School.Services.ALSManager
{
	public interface ISellerDeviceConfigurationManager
    {
        //Task<SellerDeviceConfiguration> GetByRegistrationName(string registrationName);
        Task<School.Services.Entities.SellerDeviceConfiguration> Get(long sellerDeviceConfigurationId);
        Task<School.Services.Entities.SellerDeviceConfiguration> Get(long sellerId, long sellerDeviceConfigurationId);
        Task<School.Services.Entities.SellerDeviceConfiguration> GetByMachineName(string machineName);
        Task<List<School.Services.Entities.SellerDeviceConfiguration>> GetAll(long sellerId);
        Task<School.Services.Entities.SellerDeviceConfiguration> Save(School.Services.Entities.SellerDeviceConfiguration SellerDeviceConfiguration);
    }
    public class SellerDeviceConfigurationManager : ISellerDeviceConfigurationManager
    {
        private readonly ALSContext _ALSContextDB;
        public SellerDeviceConfigurationManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
           
        }

        public async Task<School.Services.Entities.SellerDeviceConfiguration> Get(long sellerId, long sellerDeviceConfigurationId)
        {
            var result = await _ALSContextDB.SellerDeviceConfigurations.FirstOrDefaultAsync(s => s.SellerId == sellerId && s.SellerDeviceConfigurationId == sellerDeviceConfigurationId);

            return result;
        }

        public async Task<School.Services.Entities.SellerDeviceConfiguration> Get(long sellerDeviceConfigurationId)
        {
            var result = await _ALSContextDB.SellerDeviceConfigurations.FirstOrDefaultAsync(s => s.SellerDeviceConfigurationId == sellerDeviceConfigurationId);

            return result;
        }

        public async Task<School.Services.Entities.SellerDeviceConfiguration> GetByMachineName(string machineName)
        {
            //var result = await _ALSContextDB.SellerDeviceConfigurations.FirstOrDefaultAsync(s => s.DeviceName == machineName);
            var result = await _ALSContextDB.SellerDeviceConfigurations.FirstOrDefaultAsync();

            return result;
        }

        public async Task<List<School.Services.Entities.SellerDeviceConfiguration>> GetAll(long sellerId)
        {
            var SellerDeviceConfiguration = _ALSContextDB.SellerDeviceConfigurations.Where(s => s.SellerId == sellerId).ToList();

            return SellerDeviceConfiguration;
        }

        //public async Task<SellerDeviceConfiguration> GetByRegistrationName(string registrationName)
        //{
        //    var SellerDeviceConfiguration = _ALSContextDB.SellerDeviceConfigurations.FirstOrDefault(s => s.OrganizationIdentifier == registrationName);

        //    return SellerDeviceConfiguration;
        //}

        public async Task<School.Services.Entities.SellerDeviceConfiguration> Save(School.Services.Entities.SellerDeviceConfiguration SellerDeviceConfiguration)
        {
            var result = await _ALSContextDB.SellerDeviceConfigurations.FirstOrDefaultAsync(s => s.SellerDeviceConfigurationId == SellerDeviceConfiguration.SellerDeviceConfigurationId);
            if (result != null)
            {
                result.UserName = SellerDeviceConfiguration.UserName;
                result.DeviceManufacturer = SellerDeviceConfiguration.DeviceManufacturer;
                result.DeviceName = SellerDeviceConfiguration.DeviceName;
                result.DeviceId = SellerDeviceConfiguration.DeviceId;
                result.SerialNumber = SellerDeviceConfiguration.SerialNumber;

                result.IsDeleted = false;
                result.UpdateBy = 1;
                result.UpdateOn = DateTime.Now;
            }
            else
            {
                SellerDeviceConfiguration.IsDeleted = false;
                SellerDeviceConfiguration.UpdateBy = 1;
                SellerDeviceConfiguration.UpdateOn = DateTime.Now;
                _ALSContextDB.SellerDeviceConfigurations.Add(SellerDeviceConfiguration);
            }

            await _ALSContextDB.SaveChangesAsync();
            return SellerDeviceConfiguration;
        }
    }
}
