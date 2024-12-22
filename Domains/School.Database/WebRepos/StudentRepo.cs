using Microsoft.Extensions.Options;
using School.Common;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.StudentModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class StudentRepo
    {
        DbHelper _DbHelper;
        public StudentRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Student
        public async Task<DataSet> GetStudents(int studentId, StudentFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            ls_p.Add(new SqlParameter("@FilterStatusId", SqlDbType.Int) { Value = filterModel.FilterStatusId });
            ls_p.Add(new SqlParameter("@FilterNationalityId", SqlDbType.Int) { Value = filterModel.FilterNationalityId });
            ls_p.Add(new SqlParameter("@FilterGenderId", SqlDbType.Int) { Value = filterModel.FilterGenderId });
            ls_p.Add(new SqlParameter("@FilterGradeId", SqlDbType.Int) { Value = filterModel.FilterGradeId });
            ls_p.Add(new SqlParameter("@FilterCostCenterId", SqlDbType.Int) { Value = filterModel.FilterCostCenterId });
            ls_p.Add(new SqlParameter("@FilterEmail", SqlDbType.NVarChar) { Value = filterModel.FilterEmail });
            ls_p.Add(new SqlParameter("@FilterMobileNumber", SqlDbType.NVarChar) { Value = filterModel.FilterMobileNumber });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudent", ls_p);
        }
        public async Task<int> SaveStudent(int loginUserId, StudentModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = model.StudentId });
            ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = model.ParentId });
            ls_p.Add(new SqlParameter("@StudentCode", SqlDbType.NVarChar) { Value = model.StudentCode });
            ls_p.Add(new SqlParameter("@StudentName", SqlDbType.NVarChar) { Value = model.StudentName });
            if (!string.IsNullOrWhiteSpace(model.StudentImage) && model.StudentImage != "undefined" && model.StudentId == 0)
                ls_p.Add(new SqlParameter("@StudentImage", SqlDbType.NVarChar) { Value = model.StudentImage });
            ls_p.Add(new SqlParameter("@StudentEmail", SqlDbType.NVarChar) { Value = model.StudentEmail });
            ls_p.Add(new SqlParameter("@StudentArabicName", SqlDbType.NVarChar) { Value = model.StudentArabicName });
            ls_p.Add(new SqlParameter("@DOB", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.DOB).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@IqamaNo", SqlDbType.NVarChar) { Value = model.IqamaNo });
            ls_p.Add(new SqlParameter("@NationalityId", SqlDbType.Int) { Value = model.NationalityId });
            ls_p.Add(new SqlParameter("@GenderId", SqlDbType.Int) { Value = model.GenderId });
            ls_p.Add(new SqlParameter("@AdmissionDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.AdmissionDate).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.Int) { Value = model.GradeId });
            ls_p.Add(new SqlParameter("@CostCenterId", SqlDbType.Int) { Value = model.CostCenterId });
            ls_p.Add(new SqlParameter("@SectionId", SqlDbType.Int) { Value = model.SectionId });
            ls_p.Add(new SqlParameter("@PassportNo", SqlDbType.NVarChar) { Value = model.PassportNo });
            if (!string.IsNullOrWhiteSpace(model.PassportExpiry) && model.PassportExpiry != "NaN")
                ls_p.Add(new SqlParameter("@PassportExpiry", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.PassportExpiry).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@Mobile", SqlDbType.NVarChar) { Value = model.Mobile });
            ls_p.Add(new SqlParameter("@StudentAddress", SqlDbType.NVarChar) { Value = model.StudentAddress });
            ls_p.Add(new SqlParameter("@StudentStatusId", SqlDbType.NVarChar) { Value = model.StudentStatusId });
            if (!string.IsNullOrWhiteSpace(model.WithdrawDate) && model.WithdrawDate != "NaN")
                ls_p.Add(new SqlParameter("@WithdrawDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.WithdrawDate).ToString("yyyy-MMM-dd") });
            ls_p.Add(new SqlParameter("@WithdrawAt", SqlDbType.Int) { Value = model.WithdrawAt });
            ls_p.Add(new SqlParameter("@WithdrawYear", SqlDbType.NVarChar) { Value = model.WithdrawYear });
            ls_p.Add(new SqlParameter("@Fees", SqlDbType.NVarChar) { Value = model.Fees });
            ls_p.Add(new SqlParameter("@IsGPIntegration", SqlDbType.Bit) { Value = model.IsGPIntegration });
            ls_p.Add(new SqlParameter("@TermId", SqlDbType.Int) { Value = model.TermId });
            ls_p.Add(new SqlParameter("@AdmissionYear", SqlDbType.NVarChar) { Value = model.AdmissionYear });
            ls_p.Add(new SqlParameter("@PrinceAccount", SqlDbType.Bit) { Value = model.PrinceAccount });
            if (model.StudentId == 0)
                ls_p.Add(new SqlParameter("@UserPass", SqlDbType.NVarChar) { Value = Utility.RandomString(10).Encrypt() });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveStudent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                if (model.StudentId == 0 && ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                    result = Convert.ToInt32(ds.Tables[1].Rows[0]["Result"]);
                else
                    result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteStudent(int loginUserId, int studentId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteStudent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateStudentImage(int loginUserId, int studentId, string imageUrl)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            ls_p.Add(new SqlParameter("@ImageUrl", SqlDbType.VarChar) { Value = imageUrl });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateStudentImage", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<DataSet> GetGrades(int costCenterId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@DropdownType", SqlDbType.Int) { Value = Convert.ToInt32(AppDropdown.Grade) });
            ls_p.Add(new SqlParameter("@ReferenceId", SqlDbType.Int) { Value = Convert.ToInt32(costCenterId) });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetAppDropdown", ls_p);
        }
        public async Task<DataSet> GetParentLookup(ParentLookupModel model)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LookupParentId", SqlDbType.NVarChar) { Value = model.LookupParentId });
            ls_p.Add(new SqlParameter("@LookupFatherName", SqlDbType.NVarChar) { Value = model.LookupFatherName });
            ls_p.Add(new SqlParameter("@LookupFatherArabic", SqlDbType.NVarChar) { Value = model.LookupFatherArabic });
            ls_p.Add(new SqlParameter("@LookupFatherMobileNumber", SqlDbType.NVarChar) { Value = model.LookupFatherMobileNumber });
            ls_p.Add(new SqlParameter("@LookupFatherIqamaNumber", SqlDbType.NVarChar) { Value = model.LookupFatherIqamaNumber });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentLookup", ls_p);
        }

		public async Task<int> FinalStudentWithdraw(int loginUserId, long studentId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_finalStudentWithdraw", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		#endregion

		#region Student Fee Detail
		public async Task<DataSet> GetStudentFeeDetail(int studentId, int studentFeeDetailId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            ls_p.Add(new SqlParameter("@StudentFeeDetailId", SqlDbType.Int) { Value = studentFeeDetailId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentFeeDetail", ls_p);
        }

        public async Task<DataSet> GetStudentFeeStatement( int academicYearId, int parentId, int studentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.Int) { Value = academicYearId });
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = parentId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_ReportStudentStatement", ls_p);
        }
        public async Task<DataSet> GetStudentGrade(long studentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.Int) { Value = studentId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentGrade", ls_p);
        }
        public async Task<DataSet> GetStudentFeeTypeAmount(long studentId, long gradeId, long feeTypeId, long academicYearId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = studentId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.BigInt) { Value = gradeId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = feeTypeId });
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = academicYearId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentFeeTypeAmount", ls_p);
        }
        public async Task<int> SaveStudentFeeDetail(int loginUserId, StudentFeeMasterModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentFeeDetailId", SqlDbType.BigInt) { Value = model.StudentFeeDetailId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = model.StudentId });
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = model.AcademicYearId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.BigInt) { Value = model.GradeId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@FeeAmount", SqlDbType.Decimal) { Value = model.FeeAmount });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveStudentFeeDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteStudentFeeDetail(int loginUserId, long studentFeeDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentFeeDetailId", SqlDbType.Int) { Value = studentFeeDetailId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteStudentFeeDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
		#endregion

		#region Sibling
		public async Task<DataSet> GetSiblingDiscountDetail(long studentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSiblingDiscountDetail", ls_p);
		}

        public async Task<int> SaveSiblingDiscountDetail(int loginUserId, SiblingDiscountDetailModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@StudentSiblingDiscountDetailId", SqlDbType.BigInt) { Value = model.StudentSiblingDiscountDetailId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = model.StudentId });
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = model.AcademicYearId });
            ls_p.Add(new SqlParameter("@DiscountPercent", SqlDbType.Decimal) { Value = model.DiscountPercent });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSiblingDiscountDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
		public async Task<int> DeleteStudentSiblingDiscountDetail(int loginUserId, long studentSiblingDiscountDetailId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@StudentSiblingDiscountDetailId", SqlDbType.Int) { Value = studentSiblingDiscountDetailId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteStudentSiblingDiscountDetail", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		public async Task<int> UpdateSiblingDiscountStatus(int loginUserId, int actionId, long studentSiblingDiscountDetailId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@StudentSiblingDiscountDetailId", SqlDbType.Int) { Value = studentSiblingDiscountDetailId });
			ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = actionId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateSiblingDiscountStatus", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		#endregion

		#region Other Discount
		public async Task<DataSet> GetOtherDiscountDetail(long studentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetOtherDiscountDetail", ls_p);
		}

        public async Task<int> SaveOtherDiscountDetail(int loginUserId, OtherDiscountDetailModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentOtherDiscountDetailId", SqlDbType.BigInt) { Value = model.StudentOtherDiscountDetailId });
            ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = model.StudentId });
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = model.AcademicYearId });
            ls_p.Add(new SqlParameter("@DiscountName", SqlDbType.NVarChar) { Value = model.DiscountName });
            ls_p.Add(new SqlParameter("@DiscountAmount", SqlDbType.Decimal) { Value = model.DiscountAmount });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveOtherDiscountDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteStudentOtherDiscountDetail(int loginUserId, long studentOtherDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentOtherDiscountDetailId", SqlDbType.Int) { Value = studentOtherDiscountDetailId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteStudentOtherDiscountDetail", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateOtherDiscountStatus(int loginUserId, int actionId, long studentOtherDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentOtherDiscountDetailId", SqlDbType.Int) { Value = studentOtherDiscountDetailId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = actionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateOtherDiscountStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion
    }
}
