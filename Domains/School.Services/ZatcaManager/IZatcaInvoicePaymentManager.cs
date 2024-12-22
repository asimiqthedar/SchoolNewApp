using Microsoft.EntityFrameworkCore;
using School.Services.Entities;
using School.Services.ZatcaEntities;

namespace School.Services.ZatcaManager
{
	public interface IZatcaInvoicePaymentManager
    {
        Task<InvInvoicePayment> GetById(long InvoicePaymentId);
        Task<List<InvInvoicePayment>> GetAllByInvoiceNo(long invoiceNo);
        //Task<List<InvoicePayment>> GetAll(InvoicePayment payloadInput);

        Task<InvInvoicePayment> Save(InvInvoicePayment payloadInput);
        Task<List<InvInvoicePayment>> SaveRange(List<InvInvoicePayment> payloadInputList, long invoiceNo);

        Task<List<InvInvoicePayment>> GetAllByInvoiceRefNo(long invoiceNo);
    }
    public class ZatcaInvoicePaymentManager : IZatcaInvoicePaymentManager
    {
        private readonly ALSContext _ALSContextDB;
        public ZatcaInvoicePaymentManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<InvInvoicePayment> GetById(long invoiceNo)
        {
            return await _ALSContextDB.InvInvoicePayments.FirstOrDefaultAsync(s => s.InvoiceNo == invoiceNo);
        }
        public async Task<List<InvInvoicePayment>> GetAllByInvoiceNo(long invoiceNo)
        {
            return await _ALSContextDB.InvInvoicePayments.Where(s => s.InvoiceNo == invoiceNo).ToListAsync();
        }

        public async Task<List<InvInvoicePayment>> GetAllByInvoiceRefNo(long invoiceNo)
        {
            return await _ALSContextDB.InvInvoicePayments.Where(s => s.InvoiceRefNo == invoiceNo).ToListAsync();
        }

        //public async Task<List<InvoicePayment>> GetAll(InvoicePayment payloadInput)
        //{
        //    return await _ALSContextDB.InvoicePayments.Where(s => !s.IsDeleted).ToListAsync();
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
            //if (invoiceNo > 0)
            //{
            //    List<InvoicePayment> listOfexsitingRecord = new List<InvoicePayment>();
            //    listOfexsitingRecord = _ALSContextDB.InvoicePayments.Where(s => s.InvoiceNo == invoiceNo).ToList();
            //    if (listOfexsitingRecord.Any())
            //        _ALSContextDB.InvoicePayments.RemoveRange(listOfexsitingRecord);
            //    await _ALSContextDB.SaveChangesAsync();
            //}
            try
            {
                payloadInputList.ForEach(s =>
                {
                    s.InvoicePaymentId = 0;
                    s.UpdateBy = 0;
                    s.UpdateDate = DateTime.Now.Date;
                });
                _ALSContextDB.InvInvoicePayments.AddRangeAsync(payloadInputList);
                await _ALSContextDB.SaveChangesAsync();
            }
            catch (Exception ex)
            {

            }
            return payloadInputList;
        }
    }

}
