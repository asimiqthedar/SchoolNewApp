using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.SchoolAcademicModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class AcademicYearRepo
    {
        DbHelper _DbHelper;
        public AcademicYearRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Academic Year

        public async Task<DataSet> GetSchoolAcademic(int schoolAcademicId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = schoolAcademicId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSchoolAcademic", ls_p);
        }

        public async Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = model.SchoolAcademicId });
            ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.NVarChar) { Value = model.AcademicYear });
            ls_p.Add(new SqlParameter("@PeriodFrom", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.PeriodFrom).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@PeriodTo", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.PeriodTo).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            ls_p.Add(new SqlParameter("@IsCurrentYear", SqlDbType.Bit) { Value = model.IsCurrentYear });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSchoolAcademic", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = schoolAcademicId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSchoolAcademic", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion 
    }
}
