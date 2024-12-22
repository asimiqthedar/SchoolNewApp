using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.BranchModels;
using School.Models.WebModels.ContactInformationModels;
using School.Models.WebModels.SchoolAccountInfoModels;
using School.Models.WebModels.SchoolModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class SchoolRepo
    {
        DbHelper _DbHelper;
        IOptions<AppSettingConfig> _AppSettingConfig;
        public SchoolRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
            _AppSettingConfig = appSettingConfig;
        }

        #region School

        public async Task<DataSet> GetSchool(int schoolId, SchoolFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Int) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSchool", ls_p);
        }

        public async Task<int> SaveSchool(int loginUserId, SchoolModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.BigInt) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.BigInt) { Value = model.SchoolId });
            ls_p.Add(new SqlParameter("@SchoolNameEnglish", SqlDbType.NVarChar) { Value = model.SchoolNameEnglish });
            ls_p.Add(new SqlParameter("@SchoolNameArabic", SqlDbType.NVarChar) { Value = model.SchoolNameArabic });
            ls_p.Add(new SqlParameter("@LogoImage", SqlDbType.NVarChar) { Value = model.Logo });
            ls_p.Add(new SqlParameter("@BranchId", SqlDbType.BigInt) { Value = model.BranchId });
            ls_p.Add(new SqlParameter("@CountryId", SqlDbType.BigInt) { Value = model.CountryId });
            ls_p.Add(new SqlParameter("@City", SqlDbType.NVarChar) { Value = model.City });
            ls_p.Add(new SqlParameter("@Address", SqlDbType.NVarChar) { Value = model.Address });
            ls_p.Add(new SqlParameter("@Telephone", SqlDbType.NVarChar) { Value = model.Telephone });
            ls_p.Add(new SqlParameter("@SchoolEmail", SqlDbType.NVarChar) { Value = model.SchoolEmail });
            ls_p.Add(new SqlParameter("@WebsiteUrl", SqlDbType.NVarChar) { Value = model.WebsiteUrl });
            ls_p.Add(new SqlParameter("@VatNo", SqlDbType.NVarChar) { Value = model.VatNo });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSchool", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteSchool(int loginUserId, int schoolId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSchool", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateLogoImage(int loginUserId, int schoolId, string imageUrl, string logoName)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            ls_p.Add(new SqlParameter("@ImageUrl", SqlDbType.NVarChar) { Value = imageUrl });
            ls_p.Add(new SqlParameter("@LogoName", SqlDbType.NVarChar) { Value = logoName });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateSchoolLogoImage", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<DataSet> GetSchoolLogo(int schoolId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSchoolLogoImage", ls_p);
        }
        public async Task<int> DeleteSchoolLogo(int schoolLogoId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolLogoId", SqlDbType.Int) { Value = schoolLogoId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSchoolLogoImage", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Branch

        public async Task<DataSet> GetBranch(int branchId, BranchFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@BranchId", SqlDbType.Int) { Value = branchId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Int) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetBranch", ls_p);
        }

        public async Task<int> SaveBranch(int loginUserId, BranchModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@BranchId", SqlDbType.Int) { Value = model.BranchId });
            ls_p.Add(new SqlParameter("@BranchName", SqlDbType.NVarChar) { Value = model.BranchName });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveBranch", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteBranch(int loginUserId, int branchId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@BranchId", SqlDbType.Int) { Value = branchId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteBranch", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Contact Infomation

        public async Task<DataSet> GetContactInfomation(int schoolId, int contactId, ContactInformationFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            ls_p.Add(new SqlParameter("@ContactId", SqlDbType.Int) { Value = contactId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Int) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetContactInformation", ls_p);
        }

        public async Task<int> SaveContactInformation(int loginUserId, ContactInformationModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ContactId", SqlDbType.Int) { Value = model.ContactId });
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = model.SchoolId });
            ls_p.Add(new SqlParameter("@ContactPerson", SqlDbType.NVarChar) { Value = model.ContactPerson });
            ls_p.Add(new SqlParameter("@ContactPosition", SqlDbType.NVarChar) { Value = model.ContactPosition });
            ls_p.Add(new SqlParameter("@ContactTelephone", SqlDbType.NVarChar) { Value = model.ContactTelephone });
            ls_p.Add(new SqlParameter("@ContactEmail", SqlDbType.NVarChar) { Value = model.ContactEmail });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveContactInformation", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteContactInformation(int loginUserId, int contactId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@ContactId", SqlDbType.Int) { Value = contactId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteContactInformation", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        //#region Academic Year

        //public async Task<DataSet> GetSchoolAcademic(int schoolId, int schoolAcademicId)
        //{
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
        //    ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = schoolAcademicId });
        //    return await _DbHelper.ExecuteDataProcedure("sp_GetSchoolAcademic", ls_p);
        //}

        //public async Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model)
        //{
        //    int result = -1;
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
        //    ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = model.SchoolAcademicId });
        //    //ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = model.SchoolId });
        //    ls_p.Add(new SqlParameter("@AcademicYear", SqlDbType.NVarChar) { Value = model.AcademicYear });
        //    ls_p.Add(new SqlParameter("@PeriodFrom", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.PeriodFrom).ToString("yyyy-MMM-dd") });
        //    ls_p.Add(new SqlParameter("@PeriodTo", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.PeriodTo).ToString("yyyy-MMM-dd") });
        //    ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
        //    DataSet ds = await _DbHelper.ExecuteDataProcedure("sp_SaveSchoolAcademic", ls_p);
        //    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
        //    return result;
        //}

        //public async Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId)
        //{
        //    int result = -1;
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
        //    ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = schoolAcademicId });
        //    DataSet ds = await _DbHelper.ExecuteDataProcedure("sp_DeleteSchoolAcademic", ls_p);
        //    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
        //    return result;
        //}
        //#endregion 

        //#region Academic Term

        //public async Task<DataSet> GetSchoolTermAcademic(int schoolId, int schoolTermAcademicId)
        //{
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
        //    ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = schoolTermAcademicId });
        //    return await _DbHelper.ExecuteDataProcedure("sp_GetSchoolTermAcademic", ls_p);
        //}

        //public async Task<int> SaveSchoolTermAcademic(int loginUserId, SchoolTermAcademicModel model)
        //{
        //    int result = -1;
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
        //    ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = model.SchoolTermAcademicId });
        //    ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.Int) { Value = model.SchoolAcademicId });
        //    ls_p.Add(new SqlParameter("@TermId", SqlDbType.Int) { Value = model.TermId });
        //    //ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = model.SchoolId });
        //    ls_p.Add(new SqlParameter("@StartDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.StartDate).ToString("yyyy-MMM-dd") });
        //    ls_p.Add(new SqlParameter("@EndDate", SqlDbType.DateTime) { Value = Convert.ToDateTime(model.EndDate).ToString("yyyy-MMM-dd") });
        //    ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
        //    DataSet ds = await _DbHelper.ExecuteDataProcedure("sp_SaveSchoolTermAcademic", ls_p);
        //    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
        //    return result;
        //}

        //public async Task<int> DeleteSchoolTermAcademic(int loginUserId, int schoolTermAcademicId)
        //{
        //    int result = -1;
        //    List<SqlParameter> ls_p = new List<SqlParameter>();
        //    ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
        //    ls_p.Add(new SqlParameter("@SchoolTermAcademicId", SqlDbType.Int) { Value = schoolTermAcademicId });
        //    DataSet ds = await _DbHelper.ExecuteDataProcedure("sp_DeleteSchoolTermAcademic", ls_p);
        //    if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        //        result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
        //    return result;
        //}
        //#endregion

        #region School Account Info

        public async Task<DataSet> GetSchoolAccountInfo(int schoolId, int schoolAccountIId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = schoolId });
            ls_p.Add(new SqlParameter("@SchoolAccountIId", SqlDbType.Int) { Value = schoolAccountIId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSchoolAccountInfo", ls_p);
        }

        public async Task<int> SaveSchoolAccountInfo(int loginUserId, SchoolAccountInfoModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolAccountIId", SqlDbType.Int) { Value = model.SchoolAccountIId });
            ls_p.Add(new SqlParameter("@SchoolId", SqlDbType.Int) { Value = model.SchoolId });
            ls_p.Add(new SqlParameter("@ReceivableAccount", SqlDbType.NVarChar) { Value = model.ReceivableAccount });
            ls_p.Add(new SqlParameter("@AdvanceAccount", SqlDbType.NVarChar) { Value = model.AdvanceAccount });
            ls_p.Add(new SqlParameter("@CodeDescription", SqlDbType.NVarChar) { Value = model.CodeDescription });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSchoolAccountInfo", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> DeleteSchoolAccountInfo(int loginUserId, int schoolAccountIId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SchoolAccountIId", SqlDbType.Int) { Value = schoolAccountIId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSchoolAccountInfo", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Generate Fee
        public async Task<DataSet> GetGenerateFee(int feeGenerateId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = feeGenerateId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGenerateFee", ls_p);
        }
        public async Task<int> SaveGenerateFee(int loginUserId, GenerateFeeModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = model.FeeGenerateId });
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.BigInt) { Value = model.SchoolAcademicId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.BigInt) { Value = model.GradeId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = model.ActionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveGenerateFee", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateGenerateFee(int loginUserId, int feeGenerateId, int actionId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = feeGenerateId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = actionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateFee", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Generate Sibling Discount
        public async Task<DataSet> GetGenerateSiblingDiscount(int siblingDiscountId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = siblingDiscountId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGenerateSiblingDiscount", ls_p);
        }
        public async Task<int> SaveGenerateSiblingDiscount(int loginUserId, GenerateSiblingDiscountModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.BigInt) { Value = model.SiblingDiscountId });
            ls_p.Add(new SqlParameter("@SchoolAcademicId", SqlDbType.BigInt) { Value = model.SchoolAcademicId });          
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = model.ActionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveGenerateSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> UpdateGenerateSiblingDiscount(int loginUserId, int siblingDiscountId, int actionId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = siblingDiscountId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = actionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        public async Task<DataSet> GetSiblingDiscountDetail(int academicYearId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = academicYearId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSiblingDiscountDetailForCancle", ls_p);
        }
        public async Task<int> CancleMultiSiblingDiscount(int loginUserId, string studentSiblingDiscountDetailIds)
        {
            StudentRepo _StudentRepo = new StudentRepo(_AppSettingConfig);
            int result = -1;
            foreach (string studentSiblingDiscountDetailId in studentSiblingDiscountDetailIds.Split(','))
            {
                int.TryParse(studentSiblingDiscountDetailId.Trim(), out int studentSiblingDiscountDetailIdOut);
                if (studentSiblingDiscountDetailIdOut > 0)
                {
                    result = await _StudentRepo.UpdateSiblingDiscountStatus(loginUserId,5, studentSiblingDiscountDetailIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
    }
}
