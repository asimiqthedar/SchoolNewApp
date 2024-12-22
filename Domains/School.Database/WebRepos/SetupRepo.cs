using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.ConfigModel;
using School.Models.WebModels.CostCenterModels;
using School.Models.WebModels.DiscountModels;
using School.Models.WebModels.DocumentTypeModels;
using School.Models.WebModels.GenderModels;
using School.Models.WebModels.GradeModels;
using School.Models.WebModels.InvoiceTypeModels;
using School.Models.WebModels.PaymentMethod;
using School.Models.WebModels.SectionModels;
using School.Models.WebModels.StudentStatus;
using School.Models.WebModels.VatModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class SetupRepo
    {
        DbHelper _DbHelper;
        public SetupRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }

        #region Cost Center
        public async Task<DataSet> GetCostCenters(int costCenterId, CostCenterFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@CostCenterId", SqlDbType.Int) { Value = costCenterId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetCostCenter", ls_p);
        }
        public async Task<int> SaveCostCenter(int loginUserId, CostCenterModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@CostCenterId", SqlDbType.Int) { Value = model.CostCenterId });
            ls_p.Add(new SqlParameter("@CostCenterName", SqlDbType.NVarChar) { Value = model.CostCenterName });
            ls_p.Add(new SqlParameter("@Remarks", SqlDbType.NVarChar) { Value = model.Remarks });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveCostCenter", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteCostCenter(int loginUserId, int costCenterId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@CostCenterId", SqlDbType.Int) { Value = costCenterId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteCostCenter", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Gender type
        public async Task<DataSet> GetGenders(int genderTypeId, GenderFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@GenderTypeId", SqlDbType.Int) { Value = genderTypeId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGender", ls_p);
        }
        public async Task<int> SaveGender(int loginUserId, GenderModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@GenderTypeId", SqlDbType.Int) { Value = model.GenderTypeId });
            ls_p.Add(new SqlParameter("@GenderTypeName", SqlDbType.NVarChar) { Value = model.GenderTypeName });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveGender", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteGender(int loginUserId, int genderTypeId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@GenderTypeId", SqlDbType.Int) { Value = genderTypeId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteGender", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Grade
        public async Task<DataSet> GetGrades(int gradeId, GradeFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.Int) { Value = gradeId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterCostCenterId", SqlDbType.Int) { Value = filterModel.FilterCostCenterId });
            ls_p.Add(new SqlParameter("@FilterGenderTypeId", SqlDbType.Int) { Value = filterModel.FilterGenderTypeId });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGrades", ls_p);
        }
        public async Task<DataSet> GetGradeMaxSequenceNo()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGradeMaxSequenceNo", ls_p);
        }
        public async Task<int> SaveGrade(int loginUserId, GradeModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.Int) { Value = model.GradeId });
            ls_p.Add(new SqlParameter("@GradeName", SqlDbType.NVarChar) { Value = model.GradeName });
            ls_p.Add(new SqlParameter("@CostCenterId", SqlDbType.Int) { Value = model.CostCenterId });
            ls_p.Add(new SqlParameter("@GenderTypeId", SqlDbType.Int) { Value = model.GenderTypeId });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveGrade", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteGrade(int loginUserId, int gradeId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.Int) { Value = gradeId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteGrade", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> AdjustGrade(int gradeId, int value, int sequenceNo)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@GradeId", SqlDbType.Int) { Value = gradeId });
            ls_p.Add(new SqlParameter("@Value", SqlDbType.Int) { Value = value });
            ls_p.Add(new SqlParameter("@SequenceNo", SqlDbType.Int) { Value = sequenceNo });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_AdjustGrade", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Document type
        public async Task<DataSet> GetDocumentType(int documentTypeId, DocumentTypeFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@DocumentTypeId", SqlDbType.Int) { Value = documentTypeId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetDocumentType", ls_p);
        }
        public async Task<int> SaveDocumentType(int loginUserId, DocumentTypeModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@DocumentTypeId", SqlDbType.Int) { Value = model.DocumentTypeId });
            ls_p.Add(new SqlParameter("@DocumentTypeName", SqlDbType.NVarChar) { Value = model.DocumentTypeName });
            ls_p.Add(new SqlParameter("@Remarks", SqlDbType.NVarChar) { Value = model.Remarks });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveDocumentType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteDocumentType(int loginUserId, int documentTypeId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@DocumentTypeId", SqlDbType.Int) { Value = documentTypeId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteDocumentType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Section
        public async Task<DataSet> GetSections(int sectionId, SectionFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SectionId", SqlDbType.Int) { Value = sectionId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSections", ls_p);
        }
        public async Task<int> SaveSection(int loginUserId, SectionModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SectionId", SqlDbType.Int) { Value = model.SectionId });
            ls_p.Add(new SqlParameter("@SectionName", SqlDbType.NVarChar) { Value = model.SectionName });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSection", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteSection(int loginUserId, int sectionId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SectionId", SqlDbType.Int) { Value = sectionId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSection", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Invoice type
        public async Task<DataSet> GetInvoiceType(int invoiceTypeId, InvoiceTypeFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@InvoiceTypeId", SqlDbType.Int) { Value = invoiceTypeId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetInvoiceType", ls_p);
        }
        public async Task<int> SaveInvoiceType(int loginUserId, InvoiceTypeModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@InvoiceTypeId", SqlDbType.Int) { Value = model.InvoiceTypeId });
            ls_p.Add(new SqlParameter("@InvoiceTypeName", SqlDbType.NVarChar) { Value = model.InvoiceTypeName });
            ls_p.Add(new SqlParameter("@ReceivableAccount", SqlDbType.NVarChar) { Value = model.ReceivableAccount });
            ls_p.Add(new SqlParameter("@AdvanceAccount", SqlDbType.NVarChar) { Value = model.AdvanceAccount });
            ls_p.Add(new SqlParameter("@ReceivableAccountRemarks", SqlDbType.NVarChar) { Value = model.ReceivableAccountRemarks });
            ls_p.Add(new SqlParameter("@AdvanceAccountRemarks", SqlDbType.NVarChar) { Value = model.AdvanceAccountRemarks });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveInvoiceType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteInvoiceType(int loginUserId, int invoiceTypeId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@invoiceTypeId", SqlDbType.Int) { Value = invoiceTypeId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteInvoiceType", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Student status
        public async Task<DataSet> GetStudentStatus(int studentStatusId, StudentStatusFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@StudentStatusId", SqlDbType.Int) { Value = studentStatusId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Int) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentStatus", ls_p);
        }
        public async Task<int> SaveStudentStatus(int loginUserId, StudentStatusModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentStatusId", SqlDbType.Int) { Value = model.StudentStatusId });
            ls_p.Add(new SqlParameter("@StatusName", SqlDbType.NVarChar) { Value = model.StatusName });
            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveStudentStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteStudentStatus(int loginUserId, int studentStatusId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentStatusId", SqlDbType.Int) { Value = studentStatusId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteStudentStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region OpenApply
        public async Task<DataSet> GetOpenApply(int openApplyId, GenderFilterModel filterModel)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@OpenApplyId", SqlDbType.Int) { Value = openApplyId });
            ls_p.Add(new SqlParameter("@FilterSearch", SqlDbType.NVarChar) { Value = filterModel.FilterSearch });
            ls_p.Add(new SqlParameter("@FilterIsActive", SqlDbType.Bit) { Value = filterModel.FilterIsActive });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetOpenApply", ls_p);
        }
        public async Task<int> SaveOpenApply(int loginUserId, OpenApplyModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });

            ls_p.Add(new SqlParameter("@OpenApplyId", SqlDbType.NVarChar) { Value = model.OpenApplyId });
            ls_p.Add(new SqlParameter("@GrantType", SqlDbType.NVarChar) { Value = model.GrantType });
            ls_p.Add(new SqlParameter("@ClientId", SqlDbType.NVarChar) { Value = model.ClientId });
            ls_p.Add(new SqlParameter("@ClientSecret", SqlDbType.NVarChar) { Value = model.ClientSecret });
            ls_p.Add(new SqlParameter("@Audience", SqlDbType.NVarChar) { Value = model.Audience });
            ls_p.Add(new SqlParameter("@OpenApplyJobPath", SqlDbType.NVarChar) { Value = model.OpenApplyJobPath });

            ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveOpenApply", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        #endregion

        #region Vat
        public async Task<DataSet> GetVats(int vatId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@VatId", SqlDbType.BigInt) { Value = vatId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetVat", ls_p);
        }
        public async Task<int> SaveVat(int loginUserId, VatModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@VatId", SqlDbType.BigInt) { Value = model.VatId });
            ls_p.Add(new SqlParameter("@FeeTypeId", SqlDbType.BigInt) { Value = model.FeeTypeId });
            ls_p.Add(new SqlParameter("@VatTaxPercent", SqlDbType.Decimal) { Value = model.VatTaxPercent });
            ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
            ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveVat", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteVat(int loginUserId, int vatId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@VatId", SqlDbType.Int) { Value = vatId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteVat", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        #region Vat Exempted Nation Mapping
        public async Task<DataSet> GetVatExemptedNationMapping(long vatId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@VatId", SqlDbType.BigInt) { Value = vatId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetVatExemptedNation", ls_p);
            return ds;
        }
        public async Task<int> SaveVatExemptedNationMapping(int loginUserId, VatExemptedNationModel model)
        {
            int result = 0;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@VatId", SqlDbType.Int) { Value = model.VatId });
            ls_p.Add(new SqlParameter("@MultiSelectLeft", SqlDbType.NVarChar) { Value = model.MultiSelectLeft });
            ls_p.Add(new SqlParameter("@MultiSelectRight", SqlDbType.NVarChar) { Value = model.MultiSelectRight });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_VatExemptedNationMapping", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion
        #endregion

        #region Discount
        public async Task<DataSet> GetSiblingDiscounts(int discountId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@DiscountId", SqlDbType.Int) { Value = discountId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetSiblingDiscount", ls_p);
        }
        public async Task<int> SaveSiblingDiscount(int loginUserId, DiscountModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@DiscountId", SqlDbType.Int) { Value = model.DiscountId });
            ls_p.Add(new SqlParameter("@ChildrenNo", SqlDbType.Int) { Value = model.ChildrenNo });
            ls_p.Add(new SqlParameter("@DiscountPercent", SqlDbType.Decimal) { Value = model.DiscountPercent });
            ls_p.Add(new SqlParameter("@StaffDiscountPercent", SqlDbType.Decimal) { Value = model.StaffDiscountPercent });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> DeleteSiblingDiscount(int loginUserId, int discountId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@DiscountId", SqlDbType.Int) { Value = discountId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        #endregion

        #region Email
        public async Task<DataSet> GetEmailConfig(int emailConfigId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@EmailConfigId", SqlDbType.BigInt) { Value = emailConfigId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetEmailConfig", ls_p);
        }
        public async Task<int> SaveEmailConfig(int loginUserId, EmailConfigModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });

            ls_p.Add(new SqlParameter("@EmailConfigId", SqlDbType.NVarChar) { Value = model.EmailConfigId });
            ls_p.Add(new SqlParameter("@Host", SqlDbType.NVarChar) { Value = model.Host });
            ls_p.Add(new SqlParameter("@Port", SqlDbType.Int) { Value = model.Port });
            ls_p.Add(new SqlParameter("@Username", SqlDbType.NVarChar) { Value = model.Username });
            ls_p.Add(new SqlParameter("@Password", SqlDbType.NVarChar) { Value = model.Password });
            ls_p.Add(new SqlParameter("@EnableSSL", SqlDbType.Bit) { Value = model.EnableSSL });
            ls_p.Add(new SqlParameter("@FromEmail", SqlDbType.NVarChar) { Value = model.FromEmail });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveEmailConfig", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        #endregion

        #region Whatsapp
        public async Task<DataSet> GetWhatsappConfig(int whatsappConfigId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@WhatsappConfigId", SqlDbType.BigInt) { Value = whatsappConfigId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetWhatsappConfig", ls_p);
        }
        public async Task<int> SaveWhatsappConfig(int loginUserId, WhatsappConfigModel model)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@WhatsAppConfigId", SqlDbType.NVarChar) { Value = model.WhatsAppConfigId });
            ls_p.Add(new SqlParameter("@AccountSid", SqlDbType.NVarChar) { Value = model.AccountSid });
            ls_p.Add(new SqlParameter("@AuthToken", SqlDbType.NVarChar) { Value = model.AuthToken });
            ls_p.Add(new SqlParameter("@PhoneNumber", SqlDbType.NVarChar) { Value = model.PhoneNumber });
            ls_p.Add(new SqlParameter("@SandboxMode", SqlDbType.Bit) { Value = model.SandboxMode });
            ls_p.Add(new SqlParameter("@StatusCallbackUrl", SqlDbType.NVarChar) { Value = model.StatusCallbackUrl });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SaveWhatsappConfig", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
		#endregion

		#region Payment Method Category

		public async Task<DataSet> GetPaymentMethodCategory(long paymentMethodCategoryId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@PaymentMethodCategoryId", SqlDbType.BigInt) { Value = paymentMethodCategoryId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetPaymentMethodCategory", ls_p);
		}

		public async Task<int> SavePaymentMethodCategory( PaymentMethodCategoryModel model)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@PaymentMethodCategoryId", SqlDbType.BigInt) { Value = model.PaymentMethodCategoryId });
			ls_p.Add(new SqlParameter("@CategoryName", SqlDbType.NVarChar) { Value = model.CategoryName });
			ls_p.Add(new SqlParameter("@IsActive", SqlDbType.Bit) { Value = model.IsActive });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SavePaymentMethodCategory", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}

		#endregion

		#region Payment Method

		public async Task<DataSet> GetPaymentMethod(long paymentMethodId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@PaymentMethodId", SqlDbType.BigInt) { Value = paymentMethodId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetPaymentMethod", ls_p);
		}

        public async Task<int> DeletePaymentMethod(long paymentMethodId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@PaymentMethodId", SqlDbType.Int) { Value = paymentMethodId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeletePaymentMethod", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }

        public async Task<int> SavePaymentMethod(PaymentMethodModel model)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@PaymentMethodId", SqlDbType.BigInt) { Value = model.PaymentMethodId });
			ls_p.Add(new SqlParameter("@PaymentMethodCategoryId", SqlDbType.BigInt) { Value = model.PaymentMethodCategoryId });
			ls_p.Add(new SqlParameter("@PaymentMethodName", SqlDbType.NVarChar) { Value = model.PaymentMethodName });
			ls_p.Add(new SqlParameter("@DebitAccount", SqlDbType.NVarChar) { Value = model.DebitAccount });
			ls_p.Add(new SqlParameter("@CreditAccount", SqlDbType.NVarChar) { Value = model.CreditAccount });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_SavePaymentMethod", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		#endregion

	}
}
