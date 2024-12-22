using School.Models.WebModels.SchoolAcademicModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IAcademicYearService
    {
        #region  Academic Year
        Task<DataSet> GetSchoolAcademic(int schoolAcademicId);
        Task<SchoolAcademicModel> GetSchoolAcademicById(int schoolAcademicId);
        Task<int> SaveSchoolAcademic(int loginUserId, SchoolAcademicModel model);
        Task<int> DeleteSchoolAcademic(int loginUserId, int schoolAcademicId);
        #endregion
    }

}
