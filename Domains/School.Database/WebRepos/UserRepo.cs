using Microsoft.Extensions.Options;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class UserRepo
    {
        DbHelper _DbHelper;
        public UserRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region User
        public async Task<DataSet> GetUsers(int userId, UserFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterRoleId", SqlDbType.Int) { Value = filterModel.FilterRoleId });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetUsers", ls_p);
        }
        public async Task<int> SaveUser(int loginUserId, UserModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = model.UserId });
            ls_p.Add(new SqlParameter("@UserName", SqlDbType.NVarChar) { Value = model.UserName });
            ls_p.Add(new SqlParameter("@UserArabicName", SqlDbType.NVarChar) { Value = model.UserArabicName });
            ls_p.Add(new SqlParameter("@UserEmail", SqlDbType.NVarChar) { Value = model.UserEmail });
            ls_p.Add(new SqlParameter("@UserPhone", SqlDbType.NVarChar) { Value = model.UserPhone });
            ls_p.Add(new SqlParameter("@UserPass", SqlDbType.NVarChar) { Value = model.UserPass.Encrypt() });
            ls_p.Add(new SqlParameter("@RoleId", SqlDbType.Int) { Value = model.RoleId });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            ls_p.Add(new SqlParameter("@IsApprover", SqlDbType.Bit) { Value = model.IsApprover });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveUser", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteUser(int loginUserId, int userId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteUser", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> SaveUserImage(int loginUserId, int userId, string imgPath)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
            ls_p.Add(new SqlParameter("@ImgPath", SqlDbType.NVarChar) { Value = imgPath });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveUserImage", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion
    }
}
