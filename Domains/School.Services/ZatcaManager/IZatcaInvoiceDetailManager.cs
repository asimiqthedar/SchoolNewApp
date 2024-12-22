using Microsoft.EntityFrameworkCore;
using School.Services.Entities;
using School.Services.ZatcaEntities;

namespace School.Services.ALSManager
{
	public interface IZatcaInvoiceDetailManager
    {
        Task<InvInvoiceDetail> GetById(long InvoiceDetailId);
        Task<List<InvInvoiceDetail>> GetAllByInvoiceNo(long invoiceNo);

        Task<InvInvoiceDetail> Save(InvInvoiceDetail payloadInput);
        Task<List<InvInvoiceDetail>> SaveRange(List<InvInvoiceDetail> payloadInputList, long invoiceNo);

    }
    public class ZatcaInvoiceDetailManager : IZatcaInvoiceDetailManager
    {
        private readonly ALSContext _ALSContextDB;
        public ZatcaInvoiceDetailManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }
        public async Task<InvInvoiceDetail> GetById(long invoiceNo)
        {
            return await _ALSContextDB.InvInvoiceDetails.FirstOrDefaultAsync(s => s.InvoiceNo == invoiceNo);
        }
        public async Task<List<InvInvoiceDetail>> GetAllByInvoiceNo(long invoiceNo)
        {
            return await _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNo).ToListAsync();
        }

        public async Task<InvInvoiceDetail> Save(InvInvoiceDetail payloadInput)
        {
            if (payloadInput.InvoiceDetailId > 0)
            {
                var record = await _ALSContextDB.InvInvoiceDetails.FirstOrDefaultAsync(s => s.InvoiceDetailId == payloadInput.InvoiceDetailId);
                if (record != null)
                {
                    //record.IqamaNumber = payloadInput.IqamaNumber;
                    //record.InvoiceDetailId = payloadInput.InvoiceDetailId;
                    //record.InvoiceNo = payloadInput.InvoiceNo;
                    //record.AcademicYear = payloadInput.AcademicYear;
                    //record.InvoiceType = payloadInput.InvoiceType;
                    //record.Description = payloadInput.Description;
                    //record.ItemCode = payloadInput.ItemCode;
                    //record.StudentId = payloadInput.StudentId;
                    //record.Discount = payloadInput.Discount;
                    //record.Quantity = payloadInput.Quantity;
                    //record.UnitPrice = payloadInput.UnitPrice;
                    //record.TaxableAmount = payloadInput.TaxableAmount;
                    //record.TaxRate = payloadInput.TaxRate;
                    //record.TaxAmount = payloadInput.TaxAmount;
                    //record.ItemSubtotal = payloadInput.ItemSubtotal;
                    //record.ParentId = payloadInput.ParentId;
                    //record.StudentName = payloadInput.StudentName;
                    //record.ParentName = payloadInput.ParentName;
                    //record.GradeId = payloadInput.GradeId;
                    //record.NationalityId = payloadInput.NationalityId;
                }
            }
            else
            {
                _ALSContextDB.InvInvoiceDetails.Add(payloadInput);
            }
            await _ALSContextDB.SaveChangesAsync();
            return payloadInput;
        }

        public async Task<List<InvInvoiceDetail>> SaveRange(List<InvInvoiceDetail> payloadInputList, long invoiceNo)
        {
            try
            {
                if (invoiceNo>0)
                {
                    List<InvInvoiceDetail> listOfexsitingRecord = new List<InvInvoiceDetail>();
                    listOfexsitingRecord = _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
                    if (listOfexsitingRecord.Any())
                        _ALSContextDB.InvInvoiceDetails.RemoveRange(listOfexsitingRecord);
                }
                payloadInputList.ForEach(s =>
                {
                    s.InvoiceNo= invoiceNo;
                    
                    s.UpdateBy = 0;
                    s.UpdateDate = DateTime.Now.Date;
                });
                _ALSContextDB.InvInvoiceDetails.AddRangeAsync(payloadInputList);
                await _ALSContextDB.SaveChangesAsync();
            }
            catch (Exception ex)
            {
            }
            return payloadInputList;
        }
    }
}