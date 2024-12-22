using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IInvSummaryManager
	{
		Task<InvInvoiceSummary> GetById(long InvInvoiceSummaryId);
		Task<InvInvoiceSummary> GetByInvoiceNo(long invoiceNo);

		Task<List<InvInvoiceSummary>> GetAll(InvInvoiceSummary payloadInput);

		Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput);

		Task<InvInvoiceSummary> GetInvoicesByInvoiceRefundRefNo(long invoiceRefundNo, long invoiceRefundRefNo);
		Task<InvInvoiceSummary> SaveInvoice(string status, InvInvoiceSummary payloadInput,
			List<InvInvoiceDetail> invInvoiceDetails,
			List<InvInvoicePayment> invInvoicePayments);

	}
	public class InvSummaryManager : IInvSummaryManager
	{
		private readonly ALSContext _ALSContextDB;
		public InvSummaryManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}

		#region Invoice
		public async Task<InvInvoiceSummary> GetById(long invoiceId)
		{
			return await _ALSContextDB.InvInvoiceSummaries.FirstOrDefaultAsync(s => s.InvoiceId == invoiceId);
		}
		public async Task<InvInvoiceSummary> GetByInvoiceNo(long invoiceNo)
		{
			return await _ALSContextDB.InvInvoiceSummaries.Where(s => s.InvoiceNo == invoiceNo).FirstOrDefaultAsync();
		}

		public async Task<List<InvInvoiceSummary>> GetAll(InvInvoiceSummary payloadInput)
		{
			return await _ALSContextDB.InvInvoiceSummaries.Where(s => !s.IsDeleted).ToListAsync();
		}

		public async Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput)
		{
			try
			{
				if (payloadInput.InvoiceId > 0)
				{
					var record = await _ALSContextDB.InvInvoiceSummaries.FirstOrDefaultAsync(s => s.InvoiceId == payloadInput.InvoiceId);
					{
						if (record != null)
						{
							record.InvoiceNo = payloadInput.InvoiceNo;
							record.InvoiceDate = payloadInput.InvoiceDate;
							record.Status = payloadInput.Status;
							record.PublishedBy = payloadInput.PublishedBy;
							record.CreditNo = payloadInput.CreditNo;
							record.CreditReason = payloadInput.CreditReason;
							record.CustomerName = payloadInput.CustomerName;
							record.ParentId = payloadInput.ParentId;
							record.IqamaNumber = payloadInput.IqamaNumber;
							record.TaxableAmount = payloadInput.TaxableAmount;
							record.TaxAmount = payloadInput.TaxAmount;
							record.ItemSubtotal = payloadInput.ItemSubtotal;
							record.InvoiceType = payloadInput.InvoiceType;
							record.InvoiceRefNo = payloadInput.InvoiceRefNo;

							record.IsDeleted = false;
							record.UpdateDate = DateTime.Now.Date;
						}
					}
				}
				else
				{
					payloadInput.UpdateDate = DateTime.Now.Date;
					_ALSContextDB.InvInvoiceSummaries.Add(payloadInput);
				}
				await _ALSContextDB.SaveChangesAsync();

			}
			catch (Exception ex)
			{

			}
			return payloadInput;


		}
		#endregion Invoice

		#region Invoice Refund
		//public async Task<InvInvoiceSummary> GetInvoicesByInvoiceRefundNo(long invoiceRefundNo, long invoiceRefundRefNo)
		//{
		//    var result = await _ALSContextDB.InvInvoiceSummaries.Where(s => s.InvoiceNo == invoiceRefundNo).FirstOrDefaultAsync();

		//    return result;
		//}

		public async Task<InvInvoiceSummary> GetInvoicesByInvoiceRefundRefNo(long invoiceRefundNo, long invoiceRefundRefNo)
		{
			var result = await _ALSContextDB.InvInvoiceSummaries.Where(s => s.InvoiceRefNo == invoiceRefundRefNo).FirstOrDefaultAsync();

			return result;
		}
		#endregion Invoice Refund

		public async Task<InvInvoiceSummary> SaveInvoice(string status, InvInvoiceSummary payloadInput,
			List<InvInvoiceDetail> invInvoiceDetails,
			List<InvInvoicePayment> invInvoicePayments)
		{
			//Get latest invoice number

			var latesInvoiceNo = payloadInput.InvoiceNo;
			if (latesInvoiceNo <= 0)
			{
				var lastTransctionrecord = await _ALSContextDB.Transactions.FirstOrDefaultAsync(s => s.TransactionType == "Invoice No");
				if ((lastTransctionrecord != null))
				{
					var newInvoiceNo = lastTransctionrecord.TransactionNo.Value + 1;
					lastTransctionrecord.TransactionNo = newInvoiceNo;
					_ALSContextDB.Transactions.Update(lastTransctionrecord);

					latesInvoiceNo = newInvoiceNo;
				}
			}

			payloadInput.InvoiceNo = latesInvoiceNo;

			var record = await _ALSContextDB.InvInvoiceSummaries.FirstOrDefaultAsync(s => s.InvoiceNo == payloadInput.InvoiceNo);

			if (record != null)
			{
				record.InvoiceDate = payloadInput.InvoiceDate;
				record.Status = payloadInput.Status;
				record.PublishedBy = payloadInput.PublishedBy;
				record.CreditNo = payloadInput.CreditNo;
				record.CreditReason = payloadInput.CreditReason;
				record.CustomerName = payloadInput.CustomerName;
				record.ParentId = payloadInput.ParentId;
				record.IqamaNumber = payloadInput.IqamaNumber;
				record.TaxableAmount = payloadInput.TaxableAmount;
				record.TaxAmount = payloadInput.TaxAmount;
				record.ItemSubtotal = payloadInput.ItemSubtotal;
				record.InvoiceType = payloadInput.InvoiceType;
				record.InvoiceRefNo = payloadInput.InvoiceRefNo;

				record.IsDeleted = false;
				record.UpdateDate = DateTime.Now.Date;
			}
			else
			{
				payloadInput.UpdateDate = DateTime.Now.Date;
				_ALSContextDB.InvInvoiceSummaries.Add(payloadInput);
			}

			#region Invoice detail Save/Update
			if (payloadInput.InvoiceNo > 0)
			{
				List<InvInvoiceDetail> listOfexsitingRecord = new List<InvInvoiceDetail>();
				listOfexsitingRecord = _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo == payloadInput.InvoiceNo).ToList();
				if (listOfexsitingRecord.Any())
				{
					foreach (var item in listOfexsitingRecord)
					{
						_ALSContextDB.InvInvoiceDetails.Remove(item);
					}
				}
			}

			invInvoiceDetails.ForEach(s =>
			{
				s.InvoiceDetailId = 0;
				s.UpdateDate = DateTime.Now.Date;

				s.InvoiceNo = latesInvoiceNo;

				_ALSContextDB.Add(s);
			});

			#endregion Invoice detail Save/Update

			#region Invoice payment Save/Update
			if (payloadInput.InvoiceNo > 0)
			{
				List<InvInvoicePayment> listOfexsitingRecord = new List<InvInvoicePayment>();
				listOfexsitingRecord = _ALSContextDB.InvInvoicePayments.Where(s => s.InvoiceNo == payloadInput.InvoiceNo).ToList();
				if (listOfexsitingRecord.Any())
				{
					foreach (var item in listOfexsitingRecord)
					{
						_ALSContextDB.InvInvoicePayments.Remove(item);
					}
				}
			}
			invInvoicePayments.ForEach(s =>
			{
				s.InvoicePaymentRefId = s.InvoicePaymentRefId.HasValue ? s.InvoicePaymentRefId.Value : 0;
				s.InvoiceRefNo = s.InvoiceRefNo.HasValue ? s.InvoiceRefNo.Value : 0;

				s.InvoicePaymentId = 0;
				s.UpdateDate = DateTime.Now.Date;

				s.InvoiceNo = latesInvoiceNo;

				_ALSContextDB.Add(s);
			});
			#endregion Invoice payment Save/Update

			if (status == "Posted")
			{

			}

			//On Final save
			_ALSContextDB.SaveChanges(true);
			return payloadInput;
		}


	}
}