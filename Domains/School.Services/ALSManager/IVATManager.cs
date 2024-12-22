using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IVATManager
	{
		Task<bool> IsAccountExist();
	}
	public class VATManager : IVATManager
	{
		private readonly ALSContext _ALSContextDB;
		public VATManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<bool> IsAccountExist()
		{
			return await _ALSContextDB.TblVatMasters.Where(s => s.IsActive && !s.IsDeleted).AnyAsync(s => s.IsActive && !s.IsDeleted && string.IsNullOrEmpty(s.CreditAccount) || string.IsNullOrEmpty(s.DebitAccount));
		}
	}
}
