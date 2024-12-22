using Microsoft.Extensions.Options;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class GPIntegrationRepo
	{
		DbHelper _DbHelper;
		public GPIntegrationRepo(IOptions<AppSettingConfig> appSettingConfig)
		{
			_DbHelper = new DbHelper(appSettingConfig);
		}

		public async Task<DataSet> GPIntegrationProcess(string GPType, string GpTypIds)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@GPType", SqlDbType.NVarChar) { Value = GPType });
			ls_p.Add(new SqlParameter("@GPTypeIds", SqlDbType.NVarChar) { Value = GpTypIds });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GPIntegrationProcess", ls_p);
		}
	}
}
