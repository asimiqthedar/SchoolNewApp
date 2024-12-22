using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using School.Services.Entities;
namespace School.Services.ALSManager
{
	public interface IDeviceZatcaDetailManager
    {
        Task<DeviceZatcaDetail> Get(long deviceZatcaDetailId);
        Task<DeviceZatcaDetail> GetByDeviceCOnfiguration(long sellerDeviceConfigurationId);
        Task<List<DeviceZatcaDetail>> GetAll();
        Task<DeviceZatcaDetail> Save(DeviceZatcaDetail deviceZatcaDetail);
    }
    public class DeviceZatcaDetailManager : IDeviceZatcaDetailManager
    {
        private readonly ALSContext _ALSContextDB;
        public DeviceZatcaDetailManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;

        }
       
        public async Task<DeviceZatcaDetail> Get(long deviceZatcaDetailId)
        {
            var deviceZatcaDetail = _ALSContextDB.DeviceZatcaDetails.FirstOrDefault(s => s.DeviceZatcaDetailId == deviceZatcaDetailId);

            return deviceZatcaDetail;
        }

        public async Task<DeviceZatcaDetail> GetByDeviceCOnfiguration(long sellerDeviceConfigurationId)
        {
            var deviceZatcaDetail = _ALSContextDB.DeviceZatcaDetails.FirstOrDefault(s => s.SellerDeviceConfigurationId == sellerDeviceConfigurationId);

            return deviceZatcaDetail;
        }


        public async Task<List<DeviceZatcaDetail>> GetAll()
        {
            var deviceZatcaDetail = _ALSContextDB.DeviceZatcaDetails.ToList();

            return deviceZatcaDetail;
        }

        public async Task<DeviceZatcaDetail> Save(DeviceZatcaDetail deviceZatcaDetail)
        {
            deviceZatcaDetail.IsDeleted = false;
            deviceZatcaDetail.UpdateBy = 1;
            deviceZatcaDetail.UpdateOn = DateTime.Now;
            _ALSContextDB.DeviceZatcaDetails.Add(deviceZatcaDetail);
            await _ALSContextDB.SaveChangesAsync();
            return deviceZatcaDetail;
        }
    }
}
