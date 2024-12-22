using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.SchoolTermAcademicModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class AcademicTermService : IAcademicTermService
    {
        AcademicTermRepo __AcademicTermRepo;
        private readonly ILogger<AcademicTermService> _logger;
        public AcademicTermService(IOptions<AppSettingConfig> appSettingConfig, ILogger<AcademicTermService> logger)
        {
            __AcademicTermRepo = new AcademicTermRepo(appSettingConfig);
            _logger = logger;
        }
        #region Academic Term
        public async Task<int> DeleteTermAcademic(int loginUserId, int schoolTermAcademicId)
        {
            try
            {
                int result = await __AcademicTermRepo.DeleteSchoolTermAcademic(loginUserId, schoolTermAcademicId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicTermService:DeleteTermAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<SchoolTermAcademicModel> GetTermAcademicById( int schoolTermAcademicId)
        {
            try
            {
                SchoolTermAcademicModel model = new SchoolTermAcademicModel();
                DataSet ds = await __AcademicTermRepo.GetSchoolTermAcademic(schoolTermAcademicId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SchoolTermAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolTermAcademicId"]);
                    model.SchoolAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolAcademicId"]);
                    model.TermName = Convert.ToString(ds.Tables[0].Rows[0]["TermName"]);
                    //model.SchoolId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolId"]);
                    model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
                    model.TermName = Convert.ToString(ds.Tables[0].Rows[0]["TermName"]);
                    model.StartDate = Convert.ToString(ds.Tables[0].Rows[0]["StartDate"]);
                    model.EndDate = Convert.ToString(ds.Tables[0].Rows[0]["EndDate"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicTermService:GetTermAcademicById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetTermAcademic(int academicTermId)
        {
            try
            {
                DataSet ds = await __AcademicTermRepo.GetSchoolTermAcademic(academicTermId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicTermService:GetTermAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveTermAcademic(int loginUserId, SchoolTermAcademicModel model)
        {
            try
            {
                int result = await __AcademicTermRepo.SaveSchoolTermAcademic(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicTermService:SaveTermAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion
    }
}
