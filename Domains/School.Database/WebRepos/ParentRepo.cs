using Microsoft.Extensions.Options;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.ParentModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class ParentRepo
    {
        DbHelper _DbHelper;
        public ParentRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Parent
        public async Task<DataSet> GetParents(int parentId, ParentFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterNationalityId", SqlDbType.Int) { Value = filterModel.FilterNationalityId });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetParent", ls_p);
        }
        public async Task<int> SaveParent(int loginUserId, ParentModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = model.ParentId });
            ls_p.Add(new SqlParameter("@ParentCode", SqlDbType.NVarChar) { Value = model.ParentCode });
            if (!string.IsNullOrWhiteSpace(model.ParentImage) && model.ParentImage != "undefined" && model.ParentId == 0)
                ls_p.Add(new SqlParameter("@ParentImage", SqlDbType.NVarChar) { Value = model.ParentImage });
            ls_p.Add(new SqlParameter("@FatherName", SqlDbType.NVarChar) { Value = model.FatherName });
            ls_p.Add(new SqlParameter("@FatherArabicName", SqlDbType.NVarChar) { Value = model.FatherArabicName });
            ls_p.Add(new SqlParameter("@FatherNationalityId", SqlDbType.Int) { Value = model.FatherNationalityId });
            ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = model.FatherMobile });
            ls_p.Add(new SqlParameter("@FatherEmail", SqlDbType.NVarChar) { Value = model.FatherEmail });
            ls_p.Add(new SqlParameter("@FatherIqamaNo", SqlDbType.NVarChar) { Value = model.FatherIqamaNo });
            ls_p.Add(new SqlParameter("@IsFatherStaff", SqlDbType.Bit) { Value = model.IsFatherStaff });
            ls_p.Add(new SqlParameter("@MotherName", SqlDbType.NVarChar) { Value = model.MotherName });
            ls_p.Add(new SqlParameter("@MotherArabicName", SqlDbType.NVarChar) { Value = model.MotherArabicName });
            ls_p.Add(new SqlParameter("@MotherNationalityId", SqlDbType.Int) { Value = model.MotherNationalityId });
            ls_p.Add(new SqlParameter("@MotherMobile", SqlDbType.NVarChar) { Value = model.MotherMobile });
            ls_p.Add(new SqlParameter("@MotherEmail", SqlDbType.NVarChar) { Value = model.MotherEmail });
            ls_p.Add(new SqlParameter("@MotherIqamaNo", SqlDbType.NVarChar) { Value = model.MotherIqamaNo });
            ls_p.Add(new SqlParameter("@IsMotherStaff", SqlDbType.Bit) { Value = model.IsMotherStaff });
            if (model.ParentId == 0)
                ls_p.Add(new SqlParameter("@FPassword", SqlDbType.NVarChar) { Value = Utility.RandomString(10).Encrypt() });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveParent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                if (model.ParentId == 0 && ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                    result = Convert.ToInt32(ds.Tables[1].Rows[0]["Result"]);
                else
                    result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteParent(int loginUserId, int parentId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteParent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> UpdateParentImage(int loginUserId, int parentId, string imageUrl)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
            ls_p.Add(new SqlParameter("@ImageUrl", SqlDbType.VarChar) { Value = imageUrl });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateParentImage", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateAccount(int loginUserId, ParentAccountModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = model.ParentId });
            ls_p.Add(new SqlParameter("@ReceivableAccount", SqlDbType.NVarChar) { Value = model.ReceivableAccount });
            ls_p.Add(new SqlParameter("@AdvanceAccount", SqlDbType.NVarChar) { Value = model.AdvanceAccount });          
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveParentAccount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)              
                    result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<DataSet> GetStudentFeeStatement(int academicYearId, int parentId, int studentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYearId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_ReportStudentStatement", ls_p);
        }
        #endregion
    }
}
