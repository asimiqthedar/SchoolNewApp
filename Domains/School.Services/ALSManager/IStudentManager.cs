using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IStudentManager
    {
        Task<TblStudent> GetById(long studentId);
        Task<List<TblStudent>> GetStudentByParentId(long parentId);
    }
    public class StudentManager : IStudentManager
    {
        private readonly ALSContext _ALSContextDB;
        public StudentManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<TblStudent> GetById(long studentId)
        {
            return await _ALSContextDB.TblStudents.FirstOrDefaultAsync(s => s.StudentId == studentId);
        }

        public async Task<List<TblStudent>> GetStudentByParentId(long parentId)
        {
            return _ALSContextDB.TblStudents.Where(s => s.ParentId == parentId).ToList();
        }
    }
}