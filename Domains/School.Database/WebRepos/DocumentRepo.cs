using Microsoft.Extensions.Options;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class DocumentRepo
    {
        DbHelper _DbHelper;
        public DocumentRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }
        public async Task<int> SaveDocuments(int loginUserId, long UploadedDocId, int DocFor, int DocType, long DocForId, string DocNo, string DocPath, bool IsActive)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
               ls_p.Add(new SqlParameter("@UploadedDocId", SqlDbType.BigInt) { Value = UploadedDocId });
            ls_p.Add(new SqlParameter("@DocFor", SqlDbType.Int) { Value = DocFor });
            ls_p.Add(new SqlParameter("@DocType", SqlDbType.Int) { Value = DocType });
            ls_p.Add(new SqlParameter("@DocForId", SqlDbType.BigInt) { Value = DocForId });
            ls_p.Add(new SqlParameter("@DocNo", SqlDbType.VarChar) { Value = DocNo });
            ls_p.Add(new SqlParameter("@DocPath", SqlDbType.VarChar) { Value = DocPath });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveUploadDocument", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<DataSet> GetAttachments(long docForId, int docFor)
        {
            List<SqlParameter> ls_p = new()
            {
                new SqlParameter("@DocForId", SqlDbType.BigInt) { Value = docForId },
                new SqlParameter("@DocFor", SqlDbType.Int) { Value = docFor },
            };
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetAttachmentByDocForId", ls_p);
        }

        public async Task<int> DeleteAttachment(int uploadedDocId, int loginUserId)
        {

            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@UploadedDocId", SqlDbType.BigInt) { Value = uploadedDocId });
          
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteAttachements", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
    }
}
