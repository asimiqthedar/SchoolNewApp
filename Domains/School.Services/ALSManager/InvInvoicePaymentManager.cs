using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IInvInvoicePaymentManager
	{
		Task<InvInvoicePayment> GetById(long invoicePaymentId);
		Task<List<InvInvoicePayment>> GetAllByInvoiceNo(long invoiceNo);
		//Task<List<InvInvoicePayment>> GetAll(InvInvoicePayment payloadInput);
		Task<InvInvoicePayment> Save(InvInvoicePayment payloadInput);
		Task<List<InvInvoicePayment>> SaveRange(List<InvInvoicePayment> payloadInputList, long invoiceNo);
		Task<List<InvInvoicePayment>> GetAllByInvoiceRefNo(long invoiceNo, long excludeInvoiceNo);
	}
	public class InvInvoicePaymentManager : IInvInvoicePaymentManager
	{
		private readonly ALSContext _ALSContextDB;
		public InvInvoicePaymentManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<InvInvoicePayment> GetById(long invoicePaymentId)
		{
			return await _ALSContextDB.InvInvoicePayments.FirstOrDefaultAsync(s => s.InvoicePaymentId == invoicePaymentId);
		}
		public async Task<List<InvInvoicePayment>> GetAllByInvoiceNo(long invoiceNo)
		{
			return await _ALSContextDB.InvInvoicePayments.Where(s => !s.IsDeleted && s.InvoiceNo == invoiceNo).ToListAsync();
		}

		public async Task<List<InvInvoicePayment>> GetAllByInvoiceRefNo(long invoiceNo, long excludeInvoiceNo)
		{
			return await (from det in _ALSContextDB.InvInvoicePayments
						  join sum in _ALSContextDB.InvInvoiceSummaries
						  on det.InvoiceNo equals sum.InvoiceNo
						  where det.InvoiceRefNo == invoiceNo && sum.InvoiceNo != excludeInvoiceNo 
						  && det.IsDeleted == false && sum.IsDeleted == false
						  select det
					 )
					 .ToListAsync();
		}

		//public async Task<List<InvInvoicePayment>> GetAll(InvInvoiceSummary payloadInput)
		//{
		//    return await _ALSContextDB.InvInvoicePayments.Where(s => !s.IsDeleted).ToListAsync();
		//}
		public async Task<InvInvoicePayment> Save(InvInvoicePayment payloadInput)
		{
			try
			{
				if (payloadInput.InvoicePaymentId > 0)
				{
					var record = await _ALSContextDB.InvInvoicePayments.FirstOrDefaultAsync(s => s.InvoicePaymentId == payloadInput.InvoicePaymentId);
					if (record != null)
					{
						record.InvoicePaymentId = payloadInput.InvoicePaymentId;
						record.InvoiceNo = payloadInput.InvoiceNo;
						record.PaymentReferenceNumber = payloadInput.PaymentReferenceNumber;
						record.PaymentMethod = payloadInput.PaymentMethod;
						record.PaymentAmount = payloadInput.PaymentAmount;
					}
					else
					{
						_ALSContextDB.InvInvoicePayments.Add(payloadInput);
					}
				}
				await _ALSContextDB.SaveChangesAsync();
			}
			catch (Exception ex)
			{
			}
			return payloadInput;
		}

		public async Task<List<InvInvoicePayment>> SaveRange(List<InvInvoicePayment> payloadInputList, long invoiceNo)
		{
			if (invoiceNo > 0)
			{
				List<InvInvoicePayment> listOfexsitingRecord = new List<InvInvoicePayment>();
				listOfexsitingRecord = _ALSContextDB.InvInvoicePayments.Where(s => s.InvoiceNo == invoiceNo).ToList();
				if (listOfexsitingRecord.Any())
				{
					_ALSContextDB.InvInvoicePayments.RemoveRange(listOfexsitingRecord);
					await _ALSContextDB.SaveChangesAsync();
				}
			}
			payloadInputList.ForEach(s =>
			{
				s.InvoicePaymentRefId = s.InvoicePaymentRefId.HasValue ? s.InvoicePaymentRefId.Value : 0;
				s.InvoiceRefNo = s.InvoiceRefNo.HasValue ? s.InvoiceRefNo.Value : 0;

				s.InvoicePaymentId = 0;
				s.UpdateDate = DateTime.Now.Date;
			});
			_ALSContextDB.InvInvoicePayments.AddRangeAsync(payloadInputList);
			await _ALSContextDB.SaveChangesAsync();
			return payloadInputList;
		}
	}
}