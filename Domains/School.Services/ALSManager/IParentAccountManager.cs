using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IParentAccountManager
    {
        Task<TblParentAccount> GetById(long parentAccountId);
        Task<TblParentAccount> GetByParentId(long parentId);
    }
    public class ParentAccountManager : IParentAccountManager
    {
        private readonly ALSContext _ALSContextDB;
        public ParentAccountManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<TblParentAccount> GetById(long parentAccountId)
        {
            return await _ALSContextDB.TblParentAccounts.FirstOrDefaultAsync(s => s.ParentAccountId == parentAccountId);
        }
        public async Task<TblParentAccount> GetByParentId(long parentId)
        {
            return await _ALSContextDB.TblParentAccounts.FirstOrDefaultAsync(s => s.ParentId == parentId && !string.IsNullOrEmpty(s.AdvanceAccount) && !string.IsNullOrEmpty(s.ReceivableAccount));
        }
    }
}