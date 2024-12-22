using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IPaymentMethodManager
	{
		Task<List<TblPaymentMethod>> GetList();
		Task<bool> IsAccountExist();
		Task<bool> IsAllPaymentMethosExists(List<string> paymentMethods);

	}
	public class PaymentMethodManager : IPaymentMethodManager
	{
		private readonly ALSContext _ALSContextDB;
		public PaymentMethodManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<List<TblPaymentMethod>> GetList()
		{
			return await _ALSContextDB.TblPaymentMethods.Where(s => s.IsActive && !s.IsDeleted).ToListAsync();
		}

		public async Task<bool> IsAccountExist()
		{
			return await _ALSContextDB.TblPaymentMethods.Where(s => s.IsActive && !s.IsDeleted).AnyAsync(s => s.IsActive && !s.IsDeleted && string.IsNullOrEmpty(s.CreditAccount) || string.IsNullOrEmpty(s.DebitAccount));
		}

		public async Task<bool> IsAllPaymentMethosExists(List<string> paymentMethods)
		{
			var result = _ALSContextDB.TblPaymentMethods.Where(s => s.IsActive && !s.IsDeleted && paymentMethods.Contains(s.PaymentMethodName));
			return result.Distinct().Count() == paymentMethods.Distinct().Count();
		}
	}
}
