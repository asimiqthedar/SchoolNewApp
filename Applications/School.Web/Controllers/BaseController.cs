using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Newtonsoft.Json;
using School.Common;
using School.Models.WebModels;
using School.Models.WebModels.UserModels;
using School.Services.WebServices.Services;
using School.Web.Results;
using System.Data;
using System.Reflection;
using System.Security.Claims;
using System.Text;

namespace School.Web.Controllers
{
	public abstract class BaseController : Controller
    {
        IHttpContextAccessor _IHttpContextAccessor;

        private IDropdownService _IDropdownService;
        public BaseController(IHttpContextAccessor iHttpContextAccessor, IDropdownService iDropdownService)
        {
            _IHttpContextAccessor = iHttpContextAccessor;
            _IDropdownService = iDropdownService;
        }
        protected JsonNetResult JsonNet(object Data)
        {
            return new JsonNetResult(new { __type = "json", Data = Data });
        }
        public string GetDataFromClaims(string claimName)
        {
            return _IHttpContextAccessor.HttpContext?.User.FindFirstValue(claimName);
        }
        public string GetUserDataFromClaims(string keyName)
        {
            var userModel = JsonConvert.DeserializeObject<UserModel>(_IHttpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.UserData));
            string returnVal = string.Empty;
            Type type = userModel.GetType();
            PropertyInfo[] props = type.GetProperties();
            foreach (var prop in props)
            {
                if (prop.Name == keyName)
                {
                    returnVal = Convert.ToString(prop.GetValue(userModel));
                    break;
                }
            }
            return returnVal;
        }
        public List<UserMenuModel> GetMenusFromClaims()
        {
            var userModel = JsonConvert.DeserializeObject<UserModel>(_IHttpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.UserData));
            return userModel.UserMenueList;
        }
        public async Task<List<SelectListItem>> GetAppDropdown(AppDropdown dropdownType, bool showSelect, int referenceId = 0)
        {
            List<SelectListItem> selectList = new List<SelectListItem>();
            DataSet ds = await _IDropdownService.GetAppDropdown(dropdownType, referenceId);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                selectList = (from DataRow dr in ds.Tables[0].Rows
                              select new SelectListItem()
                              {
                                  Value = Convert.ToString(dr["SValue"]),
                                  Text = Convert.ToString(dr["SText"]),
                              }).ToList();


            }
            if (showSelect)
            {
                selectList.Insert(0, new SelectListItem()
                {
                    Text = "--Select--",
                    Value = "0"
                });
            }
            return selectList;
        }
        public async Task<List<SelectListItem>> GetAppTermYearDropdown(bool showSelect)
        {
            List<SelectListItem> selectList = new List<SelectListItem>();
            for (int i = DateTime.Now.Year - 20; i <= DateTime.Now.Year + 1; i++)
            {
                //selectList.Add(new SelectListItem { Text = $"{i}-{i + 1}", Value = $"{i}-{i + 1}" });
                selectList.Add(new SelectListItem { Text = $"{i}", Value = $"{i}" });
            }
            if (showSelect)
            {
                selectList.Insert(0, new SelectListItem()
                {
                    Text = "--Select--",
                    Value = "0"
                });
            }
            return selectList;
        }
        public async Task<List<SelectListItem>> GetDropdownFromDataTable(DataTable dt, bool showSelect)
        {
            List<SelectListItem> selectList = new List<SelectListItem>();
            if (dt != null && dt.Rows.Count > 0)
            {
                selectList = (from DataRow dr in dt.Rows
                              select new SelectListItem()
                              {
                                  Value = Convert.ToString(dr["SValue"]),
                                  Text = Convert.ToString(dr["SText"]),
                              }).ToList();


            }
            if (showSelect)
            {
                selectList.Insert(0, new SelectListItem()
                {
                    Text = "--Select--",
                    Value = "0"
                });
            }
            return selectList;
        }

        public DateTime GetDatetimeWithDDMMMYYYY(string dateString)
        {
            DateTime dtTime = DateTime.MinValue;
            try
            {
                string format = "dd-MMM-yyyy"; // Specify the format of the input date string
                dtTime = DateTime.ParseExact(dateString, format, null);
            }
            catch (Exception ex)
            {
                dtTime = DateTime.MinValue;
            }
            return dtTime;
        }

		public static string StreamToString(Stream stream)
		{
			stream.Position = 0;
			using (StreamReader reader = new StreamReader(stream, Encoding.UTF8))
			{
				return reader.ReadToEnd();
			}
		}
	}
}
