using School.Models.WebModels.UserModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IUserService
    {
        #region User
        Task<DataSet> GetUsers(UserFilterModel filterModel);
        Task<UserModel> GetUserById(int userId);
        Task<int> SaveUser(int loginUserId, UserModel model);
        Task<int> DeleteUser(int loginUserId, int userId);
        Task<int> SaveUserImage(int loginUserId, int userId, string imgPath);
        #endregion
    }
}
