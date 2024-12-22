using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class AuthService : IAuthService
    {
        AuthRepo _AuthRepo;
        private readonly ILogger<AuthService> _logger;

        public AuthService(IOptions<AppSettingConfig> appSettingConfig, ILogger<AuthService> logger)
        {
            _AuthRepo = new AuthRepo(appSettingConfig);
            _logger = logger;
        }
        public async Task<UserModel> Login(UserModel userModel)
        {
            try
            {
                DataSet ds = await _AuthRepo.GetUserDetail(userModel);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    userModel.UserId = Convert.ToInt32(ds.Tables[0].Rows[0]["UserId"]);
                    userModel.UserName = Convert.ToString(ds.Tables[0].Rows[0]["UserName"]);
                    userModel.RoleId = Convert.ToInt32(ds.Tables[0].Rows[0]["RoleId"]);
                    userModel.RoleName = Convert.ToString(ds.Tables[0].Rows[0]["RoleName"]);
                    userModel.ProfileImg = Convert.ToString(ds.Tables[0].Rows[0]["ProfileImg"]);
                    userModel.IsApprover = Convert.ToBoolean(ds.Tables[0].Rows[0]["IsApprover"]);
                }
                userModel.UserMenueList = new List<UserMenuModel>();//Menus
                if (ds != null && ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                {
                    foreach (DataRow dr in ds.Tables[1].Rows)
                    {
                        UserMenuModel UserMenu = new UserMenuModel();
                        UserMenu.MenuId = Convert.ToInt32(dr["MenuId"]);
                        UserMenu.Menu = Convert.ToString(dr["Menu"]);
                        UserMenu.MenuCtrl = Convert.ToString(dr["MenuCtrl"]);
                        UserMenu.MenuAction = Convert.ToString(dr["MenuAction"]);
                        UserMenu.ParentMenuId = Convert.ToInt32(dr["ParentMenuId"]);
                        UserMenu.DisplaySequence = Convert.ToInt32(dr["DisplaySequence"]);
                        UserMenu.FaIcon = Convert.ToString(dr["FaIcon"]);
                        UserMenu.Level = Convert.ToInt32(dr["Level"]);
                        UserMenu.Hierarchy = Convert.ToString(dr["Hierarchy"]);
                        userModel.UserMenueList.Add(UserMenu);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:AuthService:Login : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
            return userModel;
        }
    }
}
