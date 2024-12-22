using School.Models.WebModels.GradeModels;
using School.Models.WebModels.StudentModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IStudentService
    {
        #region Student
        Task<DataSet> GetStudents(StudentFilterModel filterModel);
        Task<StudentModel> GetStudentById(int studentId);

		Task<DataSet> GetStudentByIdDs(int studentId);

		Task<int> SaveStudent(int loginUserId, StudentModel model);
        Task<int> DeleteStudent(int loginUserId, int studentId);
        Task<int> UpdateStudentProfilePicture(int loginUserId, int studentId, string ImgPath);
        Task<List<GradeModel>> GetGrades(int costCenterId);
        Task<DataSet> GetParentLookup(ParentLookupModel model);

		Task<int> FinalStudentWithdraw(int loginUserId, long studentId);
		#endregion

		#region Student Fee Detail
		Task<DataSet> GetStudentFeeDetail(int studentId);
        Task<DataSet> GetStudentFeeStatement(int academicYearId, int parentId, int studentId);
        Task<StudentFeeMasterModel> GetStudentFeeDetailById(int studentId, int studentFeeDetailId);
        Task<int> GetStudentGrade(long studentId);

		Task<string> GetStudentGradeAr(long studentId);

		
		Task<decimal> GetStudentFeeTypeAmount(long studentId, long gradeId, long feeTypeId, long academicYearId);
        Task<int> SaveStudentFeeDetail(int loginUserId, StudentFeeMasterModel model);
        Task<int> DeleteStudentFeeDetail(int loginUserId, long studentFeeDetailId);
        #endregion

        #region Sibling
        Task<DataSet> GetSiblingDiscountDetail(long studentId);
        Task<int> SaveSiblingDiscountDetail(int loginUserId, SiblingDiscountDetailModel model);
        Task<int> DeleteStudentSiblingDiscountDetail(int loginUserId, long studentSiblingDiscountDetailId);
		Task<int> UpdateSiblingDiscountStatus(int loginUserId, int actionId, long studentSiblingDiscountDetailId);
		#endregion

		#region Other Discount
		Task<DataSet> GetOtherDiscountDetail(long studentId);
		Task<int> SaveOtherDiscountDetail(int loginUserId, OtherDiscountDetailModel model);
		Task<int> DeleteStudentOtherDiscountDetail(int loginUserId, long studentOtherDiscountDetailId);
        Task<int> UpdateOtherDiscountStatus(int loginUserId, int actionId, long studentOtherDiscountDetailId);
		#endregion
	}
}
