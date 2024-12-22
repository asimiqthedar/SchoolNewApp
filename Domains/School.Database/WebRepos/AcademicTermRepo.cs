using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.SchoolTermAcademicModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class AcademicTermRepo
    {
        DbHelper _DbHelper;
        public AcademicTermRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Academic Term

        public async Task<DataSet> GetSchoolTermAcademic( int schoolTermAcademicId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            //ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = schoolTermAcademicId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSchoolTermAcademic", ls_p);
        }

        public async Task<int> SaveSchoolTermAcademic(int loginUserId, SchoolTermAcademicModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = model.SchoolTermAcademicId });
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = model.SchoolAcademicId });
            ls_p.Add(new SqlParameter("@TermName", SqlDbType.NVarChar) { Value = model.TermName });
            //ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = model.SchoolId });
            ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.StartDate).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.EndDate).ToString("yyyy-MMM-dd") });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSchoolTermAcademic", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteSchoolTermAcademic(int loginUserId, int schoolTermAcademicId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = schoolTermAcademicId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSchoolTermAcademic", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion
    }
}
