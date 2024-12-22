using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IGradeMaster
    {
        Task<TblGradeMaster> GetById(long studgradeIdentId);
    }
    public class GradeMaster : IGradeMaster
    {
        private readonly ALSContext _ALSContextDB;
        public GradeMaster(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<TblGradeMaster> GetById(long gradeId)
        {
            return await _ALSContextDB.TblGradeMasters.FirstOrDefaultAsync(s => s.GradeId == gradeId);
        }
    }
}