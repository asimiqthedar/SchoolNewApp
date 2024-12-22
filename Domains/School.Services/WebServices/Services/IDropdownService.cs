using School.Common;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IDropdownService
    {
        Task<DataSet> GetAppDropdown(AppDropdown dropdownType, int referenceId = 0);
    }
}
