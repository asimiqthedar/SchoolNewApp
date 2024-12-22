using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.SchoolAcademicModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class AcademicYearService : IAcademicYearService
    {
        AcademicYearRepo _AcademicYearRepo;
        private readonly ILogger<AcademicYearService> _logger;
        public AcademicYearService(IOptions<AppSettingConfig> appSettingConfig, ILogger<AcademicYearService> logger)
        {
            _AcademicYearRepo = new AcademicYearRepo(appSettingConfig);
        }

        #region Academic Year
        public async Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId)
        {
            try
            {
                int result = await _AcademicYearRepo.DeleteSchoolAcademic(loginUserId, schoolAcademicId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicYearService:DeleteSchoolAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<SchoolAcademicModel> GetSchoolAcademicById( int schoolAcademicId)
        {
            try
            {
                SchoolAcademicModel model = new SchoolAcademicModel();
                DataSet ds = await _AcademicYearRepo.GetSchoolAcademic(schoolAcademicId);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.SchoolAcademicId = Convert.ToInt32(ds.Tables[0].Rows[0]["SchoolAcademicId"]);
                    model.AcademicYear = Convert.ToString(ds.Tables[0].Rows[0]["AcademicYear"]);
                    model.PeriodFrom = Convert.ToString(ds.Tables[0].Rows[0]["PeriodFrom"]);
                    model.PeriodTo = Convert.ToString(ds.Tables[0].Rows[0]["PeriodTo"]);
                    model.DebitAccount = Convert.ToString(ds.Tables[0].Rows[0]["DebitAccount"]);
                    model.CreditAccount = Convert.ToString(ds.Tables[0].Rows[0]["CreditAccount"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicYearService:GetSchoolAcademicById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetSchoolAcademic(int schoolAcademicId)
        {
            try
            {
                DataSet ds = await _AcademicYearRepo.GetSchoolAcademic(0);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicYearService:GetSchoolAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model)
        {
            try
            {
                int result = await _AcademicYearRepo.SaveSchoolAcademic(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AcademicYearService:SaveSchoolAcademic : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion
    }
}
