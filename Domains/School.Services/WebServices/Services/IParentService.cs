using School.Models.WebModels.ParentModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IParentService
    {
        #region Parent
        Task<DataSet> GetParents(ParentFilterModel filterModel);
        Task<ParentModel> GetParentById(int parentId);
        Task<int> SaveParent(int loginUserId, ParentModel model);
        Task<int> DeleteParent(int loginUserId, int parentId);
        Task<int> UpdateParentProfilePicture(int loginUserId, int parentId, string ImgPath);
        Task<int> UpdateAccount(int loginUserId, ParentAccountModel model);

        Task<DataSet> GetStudentFeeStatement(int academicYearId, int parentId, int studentId);
        #endregion
    }
}
