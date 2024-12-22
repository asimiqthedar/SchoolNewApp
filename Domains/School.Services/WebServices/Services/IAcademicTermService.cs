using School.Models.WebModels.SchoolTermAcademicModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IAcademicTermService
    {
        #region  Academic Term
        Task<DataSet> GetTermAcademic(int schoolTermAcademicId);
        Task<SchoolTermAcademicModel> GetTermAcademicById(int schoolTermAcademicId);
        Task<int> SaveTermAcademic(int loginUserId, SchoolTermAcademicModel model);
        Task<int> DeleteTermAcademic(int loginUserId, int schoolTermAcademicId);
        #endregion
    }

}
