using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class GPIntegrationService : IGPIntegrationService
	{
		GPIntegrationRepo _GPIntegrationRepo;
		private readonly ILogger<GPIntegrationService> _logger;

		public GPIntegrationService(IOptions<AppSettingConfig> appSettingConfig, ILogger<GPIntegrationService> logger)
		{
			_GPIntegrationRepo = new GPIntegrationRepo(appSettingConfig);
			_logger = logger;
		}

		public async Task<DataSet> GetGPIntegrationProcess(string GPType, string GpTypIds)
		{
			{
				try
				{
					DataSet ds = await _GPIntegrationRepo.GPIntegrationProcess(GPType, GpTypIds);
					return ds;
				}
				catch (Exception ex)
				{
					_logger.LogError($"Exception:GPIntegrationService:GetGPIntegrationProcess : Message :{JsonConvert.SerializeObject(ex)}");
					throw ex;
				}
			}
		}
	}
}
