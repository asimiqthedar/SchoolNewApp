using Microsoft.Extensions.Options;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class AuthRepo
    {
        DbHelper _DbHelper;
        public AuthRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }
        public async Task<DataSet> GetUserDetail(UserModel userModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@UserEmail", SqlDbType.NVarChar) { Value = userModel.UserEmail });
            ls_p.Add(new SqlParameter("@UserPass", SqlDbType.NVarChar) { Value = Utility.Encrypt(userModel.UserPass, false) });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetAuthDetail", ls_p);
        }
    }
}
