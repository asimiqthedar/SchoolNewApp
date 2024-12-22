using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class AttachementService : IAttachements
    {
        DocumentRepo _DocumentRepo;
        private readonly ILogger<AttachementService> _logger;
        public AttachementService(IOptions<AppSettingConfig> appSettingConfig, ILogger<AttachementService> logger)
        {
            _DocumentRepo = new DocumentRepo(appSettingConfig);
            _logger = logger;

        }

        public async Task<int> DeleteAttachment(int uploadedDocId, int loginUserId)
        {
            try
            {
                int result = await _DocumentRepo.DeleteAttachment(uploadedDocId, loginUserId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AttachementService:DeleteAttachment : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetAttachments(long docForId, int docFor)
        {
            try
            {
                DataSet ds = await _DocumentRepo.GetAttachments(docForId, docFor);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AttachementService:GetAttachments : Message :{JsonConvert.SerializeObject(ex)}");
                throw;
            }

        }

        public async Task<int> SaveAttachements(int DocFor, int DocType, long DocForId, string DocNo, string DocPath, int loginUserId)
        {
            try
            {
                int result = await _DocumentRepo.SaveDocuments(loginUserId, 0, DocFor, DocType, DocForId, DocNo, DocPath, true);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AttachementService:SaveAttachments : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
    }
}
