using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.FeeModels;
using School.Models.WebModels.FeetypeModels;
using School.Models.WebModels.PaymentPlanModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class FeeRepo
    {
        DbHelper _DbHelper;
        public FeeRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Fee type
        public async Task<DataSet> GetFeeType(long feeTypeId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = feeTypeId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeeType", ls_p);
        }
        public async Task<int> SaveFeeType(int loginUserId, FeeTypeModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@FeeTypeName", SqlDbType.NVarChar) { Value = model.FeeTypeName });
            ls_p.Add(new SqlParameter("@IsPrimary", SqlDbType.Bit) { Value = model.IsPrimary });
            ls_p.Add(new SqlParameter("@IsGradeWise", SqlDbType.Bit) { Value = model.IsGradeWise });
            ls_p.Add(new SqlParameter("@IsTermPlan", SqlDbType.Bit) { Value = model.IsTermPlan });
            ls_p.Add(new SqlParameter("@IsPaymentPlan", SqlDbType.Bit) { Value = model.IsPaymentPlan });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveFeeType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteFeeType(int loginUserId, long feeTypeId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.Int) { Value = feeTypeId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteFeeType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Fee type detail
        public async Task<DataSet> GetFeeTypeDetails(long feeTypeId, long feeTypeDetailId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = feeTypeId });
            ls_p.Add(new SqlParameter("@FeeTypeDetailId", SqlDbType.BigInt) { Value = feeTypeDetailId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeeTypeDetail", ls_p);
        }

        public async Task<int> SaveFeeTypeDetail(int loginUserId, FeeTermDetailSaveModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@FeeTypeDetailId", SqlDbType.BigInt) { Value = model.FeeTypeDetailId });
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = model.AcademicYearId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.BigInt) { Value = model.GradeId });
            ls_p.Add(new SqlParameter("@TermFeeAmount", SqlDbType.Decimal) { Value = model.TermFeeAmount });
            ls_p.Add(new SqlParameter("@StaffFeeAmount", SqlDbType.Decimal) { Value = model.StaffFeeAmount });
            ls_p.Add(new SqlParameter("@GradeRules", SqlDbType.NVarChar) { Value = model.GradeRules });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveFeeTypeDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;

            //int result = -1;
            //List<SqlParameter> ls_p = new List<SqlParameter>();
            //ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            //ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            //ls_p.Add(new SqlParameter("@FeeTypeName", SqlDbType.NVarChar) { Value = model.FeeTypeName });
            //ls_p.Add(new SqlParameter("@IsTermPlan", SqlDbType.Bit) { Value = model.IsTermPlan });
            //ls_p.Add(new SqlParameter("@IsPaymentPlan", SqlDbType.Bit) { Value = model.IsPaymentPlan });
            //DataSet ds = await _DbHelper.ExecuteDataProcedure("sp_SaveFeeType", ls_p);
            //if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            //    result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            //return result;

        }

        public async Task<int> DeleteFeeTypeDetail(int loginUserId ,long feeTypeDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            //ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.Int) { Value = feeTypeId });
            ls_p.Add(new SqlParameter("@FeeTypeDetailId", SqlDbType.Int) { Value = feeTypeDetailId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteFeeTypeDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        #endregion

        #region Fee Plan
        public async Task<DataSet> GetFeePlanWithoutGradewise(long feeTypeId, long feeStructureId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = feeTypeId });
            ls_p.Add(new SqlParameter("@FeeStructureId", SqlDbType.BigInt) { Value = feeStructureId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeePlanWithoutGradewise", ls_p);
        }
        public async Task<int> SaveFeePlanWithoutGradewise(int loginUserId, FeePlanModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeStructureId", SqlDbType.BigInt) { Value = model.FeeStructureId });
            ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.NVarChar) { Value = model.AcademicYear });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@IsGradeWise", SqlDbType.Bit) { Value = model.IsGradeWise });
            ls_p.Add(new SqlParameter("@FeeAmount", SqlDbType.Decimal) { Value = model.FeeAmount });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveFeePlanWithoutGradewise", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteFeePlanWithoutGradewise(int loginUserId, long feeStructureId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeStructureId", SqlDbType.Int) { Value = feeStructureId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteFeePlanWithoutGradewise", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<DataSet> GetFeePlanWithGradewise(long feeTypeId, string academicYear)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = feeTypeId });
            ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.NVarChar) { Value = academicYear });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeePlanWithGradewise", ls_p);
        }
        public async Task<int> SaveFeePlanWithoutGradewise(int loginUserId, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList)
        {
            int result = -1;
            foreach (var gradeWiseFeeStructure in gradeWiseFeeStructureModelList)
            {
                result = await SaveGradeWiseFeeStructure(loginUserId, gradeWiseFeeStructure);
            }

            return result;
        }
        #endregion

        #region Fee Structure
        public async Task<DataSet> GetFeeStructure(string academicYear)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.NVarChar) { Value = academicYear });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeeStructure", ls_p);
        }
        public async Task<int> SaveFeeStructure(int loginUserId, List<FeeStructureModel> feeStructureModelList, List<GradeWiseFeeStructureModel> gradeWiseFeeStructureModelList)
        {
            int result = -1;
            foreach (var feeStructure in feeStructureModelList)
            {
                result = await SaveFeeStructure(loginUserId, feeStructure);
            }
            foreach (var gradeWiseFeeStructure in gradeWiseFeeStructureModelList)
            {
                result = await SaveGradeWiseFeeStructure(loginUserId, gradeWiseFeeStructure);
            }

            return result;
        }
        public async Task<int> SaveFeeStructure(int loginUserId, FeeStructureModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeStructureId", SqlDbType.BigInt) { Value = Convert.ToInt64(model.FeeStructureId) });
            if (!string.IsNullOrEmpty(model.FeeAmount))
                ls_p.Add(new SqlParameter("@FeeAmount", SqlDbType.Decimal) { Value = Convert.ToDecimal(model.FeeAmount) });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveFeeStructure", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> SaveGradeWiseFeeStructure(int loginUserId, GradeWiseFeeStructureModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeGradewiseId", SqlDbType.Int) { Value = Convert.ToInt64(model.FeeGradewiseId) });
            if (!string.IsNullOrEmpty(model.FirstAmount))
                ls_p.Add(new SqlParameter("@FirstAmount", SqlDbType.Decimal) { Value = Convert.ToDecimal(model.FirstAmount) });
            if (!string.IsNullOrEmpty(model.FirstDueDate))
                ls_p.Add(new SqlParameter("@FirstDueDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.FirstDueDate).ToString("yyyy-MMM-dd") });
            if (!string.IsNullOrEmpty(model.SecondAmount))
                ls_p.Add(new SqlParameter("@SecondAmount", SqlDbType.Decimal) { Value = Convert.ToDecimal(model.SecondAmount) });
            if (!string.IsNullOrEmpty(model.SecondDueDate))
                ls_p.Add(new SqlParameter("@SecondDueDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.SecondDueDate).ToString("yyyy-MMM-dd") });
            if (!string.IsNullOrEmpty(model.ThirdAmount))
                ls_p.Add(new SqlParameter("@ThirdAmount", SqlDbType.Decimal) { Value = Convert.ToDecimal(model.ThirdAmount) });
            if (!string.IsNullOrEmpty(model.ThirdDueDate))
                ls_p.Add(new SqlParameter("@ThirdDueDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.ThirdDueDate).ToString("yyyy-MMM-dd") });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveGradeWiseFeeStructure", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Payment Plan
        public async Task<DataSet> GetFeePaymentPlan(long feeTypeDetailId, long feePaymentPlanId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeTypeDetailId", SqlDbType.BigInt) { Value = feeTypeDetailId });
            ls_p.Add(new SqlParameter("@FeePaymentPlanId", SqlDbType.BigInt) { Value = feePaymentPlanId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetFeePaymentPlan", ls_p);
        }
        public async Task<int> SaveFeePaymentPlan(int loginUserId, PaymentPlanModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeePaymentPlanId", SqlDbType.BigInt) { Value = model.FeePaymentPlanId });
            ls_p.Add(new SqlParameter("@FeeTypeDetailId", SqlDbType.BigInt) { Value = model.FeeTypeDetailId });
            ls_p.Add(new SqlParameter("@PaymentPlanAmount", SqlDbType.Decimal) { Value = model.PaymentPlanAmount });
            ls_p.Add(new SqlParameter("@DueDate", SqlDbType.DateTime) { Value = model.DueDate.ToString("dd-MMM-yyyy") });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveFeePaymentPlan", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteFeePaymentPlan(int loginUserId, long feePaymentPlanId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeePaymentPlanId", SqlDbType.Int) { Value = feePaymentPlanId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteFeePaymentPlan", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion
    }
}
