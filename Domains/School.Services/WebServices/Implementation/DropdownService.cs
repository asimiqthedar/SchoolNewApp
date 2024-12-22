using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class DropdownService : IDropdownService
    {
        DropdownRepo _DropdownRepo;
        private readonly ILogger<DropdownService> _logger;
        public DropdownService(IOptions<AppSettingConfig> appSettingConfig, ILogger<DropdownService> logger)
        {
            _DropdownRepo = new DropdownRepo(appSettingConfig);
            _logger = logger;
        }
        public async Task<DataSet> GetAppDropdown(AppDropdown dropdownType, int referenceId = 0)
        {
            try
            {
                DataSet ds = await _DropdownRepo.GetAppDropdown(dropdownType, referenceId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:DropdownService:GetAppDropdown : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
    }
}
