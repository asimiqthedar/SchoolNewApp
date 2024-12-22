using Microsoft.Extensions.Options;
using School.Common;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class DropdownRepo
    {
        DbHelper _DbHelper;
        public DropdownRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }
		public async Task<DataSet> GetAppDropdown(AppDropdown dropdownType, int referenceId = 0)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@DropdownType", SqlDbType.Int) { Value = Convert.ToInt32(dropdownType) });
            ls_p.Add(new SqlParameter("@ReferenceId", SqlDbType.Int) { Value = Convert.ToInt32(referenceId) });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetAppDropdown", ls_p);
        }
    }
}
