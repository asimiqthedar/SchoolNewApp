using Microsoft.EntityFrameworkCore;
using School.Services.Entities;
using School.Services.ZatcaEntities;


namespace School.Services.ALSManager
{
	public interface IZatcaInvoiceSummaryManager
	{
		Task<InvInvoiceSummary> GetById(long invoiceId);
		Task<InvInvoiceSummary> GetByInvoiceNo(long invoiceNo);

		Task<List<InvInvoiceSummary>> GetAll(InvInvoiceSummary payloadInput);

		Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput);
		Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput, List<InvInvoiceDetail> invoiceDetailList, List<UniformDetail> uniformDetailList, List<InvInvoicePayment> invoicePaymentList, long invoiceNo);

		//Task<InvInvoiceSummary> GetInvoicesByInvoiceRefundRefNo(string invoiceRefundNo, string invoiceRefundRefNo);
	}
	public class ZatcaInvoiceSummaryManager : IZatcaInvoiceSummaryManager
	{
		private readonly ALSContext _ZatcaContext;
		public ZatcaInvoiceSummaryManager(ALSContext zatcaContext)
		{
			_ZatcaContext = zatcaContext;
		}

		#region Invoice
		public async Task<InvInvoiceSummary> GetById(long InvoiceId)
		{
			return await _ZatcaContext.InvInvoiceSummaries.FirstOrDefaultAsync(s => s.InvoiceId == InvoiceId);
		}
		public async Task<InvInvoiceSummary> GetByInvoiceNo(long invoiceNo)
		{
			return  _ZatcaContext.InvInvoiceSummaries.FirstOrDefault(s => s.InvoiceNo == invoiceNo);
		}

		public async Task<List<InvInvoiceSummary>> GetAll(InvInvoiceSummary payloadInput)
		{
			//return await _ZatcaContext.InvInvoiceSummaries.Where(s => !s.IsDeleted).ToListAsync();
			return await _ZatcaContext.InvInvoiceSummaries.ToListAsync();
		}

		public async Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput)
		{
			try
			{
				//if (payloadInput.Id > 0)
				//{
				//    var record = await _ZatcaContext.InvInvoiceSummaries.FirstOrDefaultAsync(s => s.InvoiceId == payloadInput.InvoiceId);
				//    {
				//        if (record != null)
				//        {
				//            //record.InvoiceNo = payloadInput.InvoiceNo;
				//            //record.InvoiceDate = payloadInput.InvoiceDate;
				//            //record.Status = payloadInput.Status;
				//            //record.PublishedBy = payloadInput.PublishedBy;
				//            //record.CreditNo = payloadInput.CreditNo;
				//            //record.CreditReason = payloadInput.CreditReason;
				//            //record.CustomerName = payloadInput.CustomerName;
				//            //record.ParentId = payloadInput.ParentId;
				//            //record.IqamaNumber = payloadInput.IqamaNumber;
				//            //record.TaxableAmount = payloadInput.TaxableAmount;
				//            //record.TaxAmount = payloadInput.TaxAmount;
				//            //record.ItemSubtotal = payloadInput.ItemSubtotal;
				//            //record.InvoiceType = payloadInput.InvoiceType;
				//            //record.InvoiceRefNo = payloadInput.InvoiceRefNo;

				//            //record.IsDeleted = false;
				//            //record.UpdateDate = DateTime.Now.Date;
				//        }
				//    }
				//}
				//else
				{
					

					payloadInput.UpdateBy = 0;
					payloadInput.UpdateDate = DateTime.Now.Date;
					_ZatcaContext.InvInvoiceSummaries.Add(payloadInput);
				}
				await _ZatcaContext.SaveChangesAsync();

			}
			catch (Exception ex)
			{

			}
			return payloadInput;
		}

		//public async Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput, List<InvInvoiceDetail> invoiceDetailList, List<UniformDetail> uniformDetailList, List<InvInvoicePayment> invoicePaymentList, long invoiceNo)
		//{
		//	try
		//	{
		//		if (invoiceNo>0)
		//		{
		//			List<InvInvoiceSummary> listOfexsitingRecord = new List<InvInvoiceSummary>();
		//			listOfexsitingRecord = _ZatcaContext.InvInvoiceSummaries.Where(s => s.InvoiceNo == invoiceNo).ToList();
		//			if (listOfexsitingRecord.Any())
		//				_ZatcaContext.InvInvoiceSummaries.RemoveRange(listOfexsitingRecord);
		//		}
		//		payloadInput.InvoiceId = 0;
				

		//		payloadInput.UpdateBy = 0;
		//		payloadInput.UpdateDate = DateTime.Now.Date;
		//		_ZatcaContext.InvInvoiceSummaries.Add(payloadInput);

		//		if (invoiceDetailList.Any())
		//		{
		//			if (invoiceNo>0)
		//			{
		//				List<InvInvoiceDetail> listOfexsitingRecord = new List<InvInvoiceDetail>();
		//				listOfexsitingRecord = _ZatcaContext.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
		//				if (listOfexsitingRecord.Any())
		//					_ZatcaContext.InvInvoiceDetails.RemoveRange(listOfexsitingRecord);
		//			}
		//			invoiceDetailList.ForEach(s =>
		//			{
		//				s.InvoiceDetailId = 0;
		//				s.InvoiceNo = invoiceNo;
						
		//				s.UpdateBy = 0;
		//				s.UpdateDate = DateTime.Now.Date;
		//			});
		//			await _ZatcaContext.InvInvoiceDetails.AddRangeAsync(invoiceDetailList);
		//		}

		//		if (uniformDetailList.Any())
		//		{
		//			if (invoiceNo>0)
		//			{
		//				List<UniformDetail> listOfexsitingRecord = new List<UniformDetail>();
		//				listOfexsitingRecord = _ZatcaContext.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
		//				if (listOfexsitingRecord.Any())
		//					_ZatcaContext.UniformDetails.RemoveRange(listOfexsitingRecord);
		//			}

		//			uniformDetailList.ForEach(s =>
		//			{
		//				s.UniformDetailID = 0;

		//				s.InvoiceNo = invoiceNo;
		//				s.CreatedBy = "0";
		//				s.CreatedOn = DateTime.Now.Date;
		//				s.UpdatedBy = "0";
		//				s.UpdatedOn = DateTime.Now.Date;
		//			});
		//			await _ZatcaContext.UniformDetails.AddRangeAsync(uniformDetailList);
		//		}

		//		if (invoicePaymentList.Any())
		//		{
		//			if (invoiceNo>0)
		//			{
		//				long invoiceNoLong = Convert.ToInt64(invoiceNo);
		//				List<InvInvoicePayment> listOfexsitingRecord = new List<InvInvoicePayment>();
		//				listOfexsitingRecord = _ZatcaContext.InvInvoicePayments.Where(s => s.InvoiceNo == invoiceNoLong).ToList();
		//				if (listOfexsitingRecord.Any())
		//					_ZatcaContext.InvInvoicePayments.RemoveRange(listOfexsitingRecord);

		//				invoicePaymentList.ForEach(s =>
		//				{
		//					s.InvoiceNo = invoiceNoLong;
		//					s.InvoicePaymentId = 0;
		//					s.UpdateBy = 0;
		//					s.UpdateDate = DateTime.Now.Date;
		//				});
		//			}
		//			await _ZatcaContext.InvInvoicePayments.AddRangeAsync(invoicePaymentList);
		//		}

		//		await _ZatcaContext.SaveChangesAsync();

		//	}
		//	catch (Exception ex)
		//	{

		//	}
		//	return payloadInput;
		//}
        
		public async Task<InvInvoiceSummary> Save(InvInvoiceSummary payloadInput, List<InvInvoiceDetail> invoiceDetailList, List<UniformDetail> uniformDetailList, List<InvInvoicePayment> invoicePaymentList, long invoiceNo)
        {
            try
            {

              
                await _ZatcaContext.SaveChangesAsync();

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
        //    var result = await _ZatcaContext.InvInvoiceSummaries.Where(s => s.InvoiceNo == invoiceRefundNo).FirstOrDefaultAsync();

        //    return result;
        //}

        //public async Task<InvInvoiceSummary> GetInvoicesByInvoiceRefundRefNo(string invoiceRefundNo, string invoiceRefundRefNo)
        //{
        //    var result = await _ZatcaContext.InvInvoiceSummaries.Where(s => s.InvoiceRefNo == invoiceRefundRefNo).FirstOrDefaultAsync();

        //    return result;
        //}
        #endregion Invoice Refund
    }
}