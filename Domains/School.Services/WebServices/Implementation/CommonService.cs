using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class CommonService : ICommonService
    {
        HomeRepo _HomeRepo;
        private readonly ILogger<CommonService> _logger;
        public CommonService(IOptions<AppSettingConfig> appSettingConfig, ILogger<CommonService> logger)
        {
            _HomeRepo = new HomeRepo(appSettingConfig);
            _logger = logger;
        }
      
        public async Task<int> ApproveNotification(int userId, string NotificationIds)
        {
            try
            {
                int result = await _HomeRepo.ApproveNotification(userId, NotificationIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:CommonService:ApproveNotification : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetNotificationList(int userId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationList(userId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:CommonService:GetNotificationList : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
    }
}