using Microsoft.Extensions.Options;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class EmailRepo
    {
        DbHelper _DbHelper;
        public EmailRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }
        public async Task<DataSet> GetInvoice(long invoiceId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@InvoiceId", SqlDbType.Int) { Value = invoiceId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetInvoice", ls_p);
        }
        public async Task<DataSet> GetEmailConfig()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetEmailConfig", ls_p);
        }
    }
}
