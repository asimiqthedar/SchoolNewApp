using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IParentManager
	{
		Task<TblParent> GetById(long parentId);
		Task<TblParent> GetByEmail(string email);
	}
	public class ParentManager : IParentManager
	{
		private readonly ALSContext _ALSContextDB;
		public ParentManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<TblParent> GetById(long parentId)
		{
			return await _ALSContextDB.TblParents.FirstOrDefaultAsync(s => s.ParentId == parentId);
		}

		public async Task<TblParent> GetByEmail(string email)
		{
			return await _ALSContextDB.TblParents.FirstOrDefaultAsync(s => s.FatherEmail == email || s.ParentCode==email);
		}

	}
}