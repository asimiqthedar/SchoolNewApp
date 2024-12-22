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

namespace School.Services.WebServices.Services
{
	public interface ISetupService
    {
        #region Cost Center
        Task<DataSet> GetCostCenters(CostCenterFilterModel filterModel);
        Task<CostCenterModel> GetCostCenterById(int costCenterId);
        Task<int> SaveCostCenter(int loginUserId, CostCenterModel model);
        Task<int> DeleteCostCenter(int loginUserId, int costCenterId);
        #endregion

        #region Gender type
        Task<DataSet> GetGenders(GenderFilterModel filterModel);
        Task<GenderModel> GetGenderById(int genderTypeId);
        Task<int> SaveGender(int loginUserId, GenderModel model);
        Task<int> DeleteGender(int loginUserId, int genderTypeId);
        #endregion

        #region Grade
        Task<DataSet> GetGrades(GradeFilterModel filterModel);
        Task<GradeModel> GetGradeById(int gradeId);
        Task<GradeModel> GetGradeMaxSequenceNo();
        Task<int> SaveGrade(int loginUserId, GradeModel model);
        Task<int> DeleteGrade(int loginUserId, int gradeId);
        Task<int> AdjustGrade(int gradeId, int value, int sequenceNo);
        #endregion

        #region Document Type
        Task<DataSet> GetDocumentType(DocumentTypeFilterModel filterModel);
        Task<DocumentTypeModel> GetDocumentTypeById(int documentTypeId);
        Task<int> SaveDocumentType(int loginUserId, DocumentTypeModel model);
        Task<int> DeleteDocumentType(int loginUserId, int documentTypeId);
        #endregion

        #region Section
        Task<DataSet> GetSections(SectionFilterModel filterModel);
        Task<SectionModel> GetSectionById(int sectionId);
        Task<int> SaveSection(int loginUserId, SectionModel model);
        Task<int> DeleteSection(int loginUserId, int sectionId);
        #endregion

        #region Invoice Type
        Task<DataSet> GetInvoiceType(InvoiceTypeFilterModel filterModel);
        Task<InvoiceTypeModel> GetInvoiceTypeById(int invoiceTypeId);
        Task<int> SaveInvoiceType(int loginUserId, InvoiceTypeModel model);
        Task<int> DeleteInvoiceType(int loginUserId, int invoiceTypeId);
        #endregion


        #region Student Status
        Task<DataSet> GetStudentStatus(StudentStatusFilterModel filterModel);
        Task<StudentStatusModel> GetStudentStatusById(int studentStatusId);
        Task<int> SaveStudentStatus(int loginUserId, StudentStatusModel model);
        Task<int> DeleteStudentStatus(int loginUserId, int studentStatusId);
        #endregion

        #region OpenApply
        Task<OpenApplyModel> GetGetOpenApply(int genderTypeId);
        Task<int> SaveOpenApply(int loginUserId, OpenApplyModel model);
        #endregion

        #region Vat
        Task<DataSet> GetVats();
        Task<VatModel> GetVatById(int vatId);
        Task<int> SaveVat(int loginUserId, VatModel model);
        Task<int> DeleteVat(int loginUserId, int vatId);
        Task<DataSet> GetVatExemptedNationMapping(long vatId);
        Task<int> SaveVatExemptedNationMapping(int loginUserId, VatExemptedNationModel model);
        #endregion
        #region Discount
        Task<DataSet> GetSiblingDiscounts();
        Task<DiscountModel> GetSiblingDiscountById(int discountId);
        Task<int> SaveSiblingDiscount(int loginUserId, DiscountModel model);
        Task<int> DeleteSiblingDiscount(int loginUserId, int discountId);

        #endregion

        #region Email
        Task<EmailConfigModel> GetEmailConfig(int emailConfigId);
        Task<int> SaveEmailConfig(int loginUserId, EmailConfigModel model);
        #endregion

        #region Whatsapp
        Task<WhatsappConfigModel> GetWhatsappConfig(int whatsappConfigId);
        Task<int> SaveWhatsappConfig(int loginUserId, WhatsappConfigModel model);
        #endregion


        #region Payment Method Category

        Task<PaymentMethodCategoryModel> GetPaymentMethodCategoryById(long paymentMethodCategoryId);

        Task<DataSet> GetPaymentMethodCategory();

        Task<int> SavePaymentMethodCategory(PaymentMethodCategoryModel model);


        #endregion

        #region Payment Method
        Task<PaymentMethodModel> GetPaymentMethodById(long paymentMethodId);
        Task<DataSet> GetPaymentMethod();
		Task<int> SavePaymentMethod(PaymentMethodModel model);
        Task<int> DeletePaymentMethod(long paymentMethodId);
        #endregion

    }

}
