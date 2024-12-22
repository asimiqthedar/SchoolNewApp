using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface ISchoolAcademicManager
    {
        Task<TblSchoolAcademic> GetById(int academicYearId);
        Task<List<TblSchoolAcademic>> GetAll();
        Task<TblSchoolAcademic> IsAdvanceAcademic(int academicYearId);
        Task<TblSchoolAcademic> GetCurrentAcademic();

	}
    public class SchoolAcademicManager : ISchoolAcademicManager
    {
        private readonly ALSContext _ALSContextDB;
        public SchoolAcademicManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<TblSchoolAcademic> GetById(int academicYearId)
        {
            return await _ALSContextDB.TblSchoolAcademics.FirstOrDefaultAsync(s => s.SchoolAcademicId == academicYearId);
        }
        public async Task<TblSchoolAcademic> IsAdvanceAcademic(int academicYearId)
        {
            var currentAcademicYear = await _ALSContextDB.TblSchoolAcademics.FirstOrDefaultAsync(s => s.IsCurrentYear.Value);

            return await _ALSContextDB.TblSchoolAcademics.Where(s => s.SchoolAcademicId == academicYearId && s.PeriodFrom > currentAcademicYear.PeriodTo).FirstOrDefaultAsync();
        }
        public async Task<List<TblSchoolAcademic>> GetAll()
        {
            return await _ALSContextDB.TblSchoolAcademics.Where(s => s.IsActive && !s.IsDeleted).ToListAsync();
        }

		public async Task<TblSchoolAcademic> GetCurrentAcademic()
		{
			return await _ALSContextDB.TblSchoolAcademics.FirstOrDefaultAsync(s => s.IsCurrentYear.Value);
		}
	}
}
