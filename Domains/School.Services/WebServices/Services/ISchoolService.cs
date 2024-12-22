using School.Models.WebModels.BranchModels;
using School.Models.WebModels.ContactInformationModels;
using School.Models.WebModels.SchoolAccountInfoModels;
using School.Models.WebModels.SchoolModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface ISchoolService
    {
        #region School
        Task<DataSet> GetSchool(SchoolFilterModel filterModel);
        Task<SchoolModel> GetSchoolById(int schoolId);
        Task<int> SaveSchool(int loginUserId, SchoolModel model);
        Task<int> DeleteSchool(int loginUserId, int schoolId);
        Task<int> UpdateLogoPicture(int loginUserId, int schoolId, string ImgPath, string logoName);
        Task<DataSet> GetSchoolLogo(int schoolId);
        Task<int> DeleteSchoolLogo(int schoolLogoId);
        #endregion

        #region Branch
        Task<DataSet> GetBranch(BranchFilterModel filterModel);
        Task<BranchModel> GetBranchById(int branchId);
        Task<int> SaveBranch(int loginUserId, BranchModel model);
        Task<int> DeleteBranch(int loginUserId, int branchId);
        #endregion

        #region Contact Information
        Task<DataSet> GetContactInformation(int schoolId, ContactInformationFilterModel filterModel);
        Task<ContactInformationModel> GetContactInformationById(int schoolId, int contactId);
        Task<int> SaveContactInformation(int loginUserId, ContactInformationModel model);
        Task<int> DeleteContactInformation(int loginUserId, int contactId);
        #endregion

        //#region  Academic Year
        //Task<DataSet> GetSchoolAcademic(int schoolId);
        //Task<SchoolAcademicModel> GetSchoolAcademicById(int schoolAcademicId);
        //Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model);
        //Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId);
        //#endregion

        //#region  Academic Term
        //Task<DataSet> GetSchoolTermAcademic(int schoolId);
        //Task<SchoolTermAcademicModel> GetSchoolTermAcademicById(int schoolId, int schoolTermAcademicId);
        //Task<int> SaveSchoolTermAcademic(int loginUserId, SchoolTermAcademicModel model);
        //Task<int> DeleteSchoolTermAcademic(int loginUserId, int schoolTermAcademicId);
        //#endregion

        #region  School Account Info
        Task<DataSet> GetSchoolAccountInfo(int schoolAccountIId);
        Task<SchoolAccountInfoModel> GetSchoolAccountInfoById(int schoolId, int schoolAccountIId);
        Task<int> SaveSchoolAccountInfo(int loginUserId, SchoolAccountInfoModel model);
        Task<int> DeleteSchoolAccountInfo(int loginUserId, int schoolTermAcademicId);
        #endregion

        #region Generate Fee
        Task<DataSet> GetGenerateFee();
        Task<int> SaveGenerateFee(int loginUserId, GenerateFeeModel model);
        Task<int> UpdateGenerateFee(int loginUserId, int feeGenerateId, int actionId);
        Task<DataSet> GetGenerateFeeById(int feeGenerateId);
        #endregion

        #region Generate Sibling Discount
        Task<DataSet> GetGenerateSiblingDiscount();
        Task<int> SaveGenerateSiblingDiscount(int loginUserId, GenerateSiblingDiscountModel model);
        Task<int> UpdateGenerateSiblingDiscount(int loginUserId, int siblingDiscountId, int actionId);
        Task<DataSet> GetGenerateSiblingDiscountById(int siblingDiscountId);
        #endregion

        Task<DataSet> GetSiblingDiscountDetail(int academicYearId);
        Task<int> CancleMultiSiblingDiscount(int loginUserId, string studentSiblingDiscountDetailIds);
    }

}
