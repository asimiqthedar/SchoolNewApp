using School.Models.WebModels.UserModels;

namespace School.Services.WebServices.Services
{
	public interface IAuthService
    {
        Task<UserModel> Login(UserModel userModel);
    }
}
