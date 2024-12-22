using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Common.Helpers;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class UserService : IUserService
    {
        UserRepo _UserRepo;
        private readonly ILogger<UserService> _logger;
        public UserService(IOptions<AppSettingConfig> appSettingConfig, ILogger<UserService> logger)
        {
            _UserRepo = new UserRepo(appSettingConfig);
            _logger = logger;
        }

        #region User
        public async Task<UserModel> GetUserById(int userId)
        {
            try
            {
                UserModel model = new UserModel();
                DataSet ds = await _UserRepo.GetUsers(userId, new UserFilterModel());
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    model.UserId = Convert.ToInt32(ds.Tables[0].Rows[0]["UserId"]);
                    model.UserName = Convert.ToString(ds.Tables[0].Rows[0]["UserName"]);
                    model.UserArabicName = Convert.ToString(ds.Tables[0].Rows[0]["UserArabicName"]);
                    model.UserEmail = Convert.ToString(ds.Tables[0].Rows[0]["UserEmail"]);
                    model.UserPhone = Convert.ToString(ds.Tables[0].Rows[0]["UserPhone"]);
                    model.RoleId = Convert.ToInt32(ds.Tables[0].Rows[0]["RoleId"]);
                    model.UserPass = Convert.ToString(ds.Tables[0].Rows[0]["UserPass"]).Decrypt();
                    model.IsApprover = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsApprover"]);
                    model.IsActive = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsActive"]);
                }
                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:UserService:GetUserById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<DataSet> GetUsers(UserFilterModel filterMode)
        {
            try
            {
                DataSet ds = await _UserRepo.GetUsers(0, filterMode);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:UserService:GetUsers : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveUser(int loginUserId, UserModel model)
        {
            try
            {
                int result = await _UserRepo.SaveUser(loginUserId, model);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:UserService:SaveUser : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> DeleteUser(int loginUserId, int userId)
        {
            try
            {
                int result = await _UserRepo.DeleteUser(loginUserId, userId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:UserService:DeleteUser : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        public async Task<int> SaveUserImage(int loginUserId, int userId, string imgPath)
        {
            try
            {
                int result = await _UserRepo.SaveUserImage(loginUserId, userId, imgPath);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:UserService:SaveUserImage : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion
    }
}
