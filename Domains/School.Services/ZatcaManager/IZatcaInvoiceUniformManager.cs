using Microsoft.EntityFrameworkCore;
using School.Services.Entities;
using School.Services.ZatcaEntities;

namespace School.Services.ALSManager
{
	public interface IZatcaInvoiceUniformManager
	{
		Task<UniformDetail> GetById(long UniformDetailId);
		Task<List<UniformDetail>> GetAllByInvoiceNo(long invoiceNo);

		//Task<UniformDetail> Save(UniformDetail payloadInput);
		Task<List<UniformDetail>> SaveRange(List<UniformDetail> payloadInputList, long invoiceNo);

	}
	public class ZatcaInvoiceUniformManager : IZatcaInvoiceUniformManager
	{
		private readonly ALSContext _ALSContextDB;
		public ZatcaInvoiceUniformManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<UniformDetail> GetById(long UniformDetailId)
		{
			return await _ALSContextDB.UniformDetails.FirstOrDefaultAsync(s => s.UniformDetailID == UniformDetailId);
		}
		public async Task<List<UniformDetail>> GetAllByInvoiceNo(long invoiceNo)
		{
			return await _ALSContextDB.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToListAsync();
		}

		//public async Task<UniformDetail> Save(UniformDetail payloadInput)
		//{
		//	if (payloadInput.Id > 0)
		//	{
		//		var record = await _ALSContextDB.UniformDetails.FirstOrDefaultAsync(s => s.Id == payloadInput.Id);
		//		if (record != null)
		//		{
		//			//record.IqamaNumber = payloadInput.IqamaNumber;
		//			//record.UniformDetailId = payloadInput.UniformDetailId;
		//			//record.InvoiceNo = payloadInput.InvoiceNo;
		//			//record.AcademicYear = payloadInput.AcademicYear;
		//			//record.InvoiceType = payloadInput.InvoiceType;
		//			//record.Description = payloadInput.Description;
		//			//record.ItemCode = payloadInput.ItemCode;
		//			//record.StudentId = payloadInput.StudentId;
		//			//record.Discount = payloadInput.Discount;
		//			//record.Quantity = payloadInput.Quantity;
		//			//record.UnitPrice = payloadInput.UnitPrice;
		//			//record.TaxableAmount = payloadInput.TaxableAmount;
		//			//record.TaxRate = payloadInput.TaxRate;
		//			//record.TaxAmount = payloadInput.TaxAmount;
		//			//record.ItemSubtotal = payloadInput.ItemSubtotal;
		//			//record.ParentId = payloadInput.ParentId;
		//			//record.StudentName = payloadInput.StudentName;
		//			//record.ParentName = payloadInput.ParentName;
		//			//record.GradeId = payloadInput.GradeId;
		//			//record.NationalityId = payloadInput.NationalityId;
		//		}
		//	}
		//	else
		//	{
		//		_ALSContextDB.UniformDetails.Add(payloadInput);
		//	}
		//	await _ALSContextDB.SaveChangesAsync();
		//	return payloadInput;
		//}

		public async Task<List<UniformDetail>> SaveRange(List<UniformDetail> payloadInputList, long invoiceNo)
		{
			try
			{
				if (invoiceNo>0)
				{
					List<UniformDetail> listOfexsitingRecord = new List<UniformDetail>();
					listOfexsitingRecord = _ALSContextDB.UniformDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
					if (listOfexsitingRecord.Any())
						_ALSContextDB.UniformDetails.RemoveRange(listOfexsitingRecord);
				}

				payloadInputList.ForEach(s =>
				{
					s.UniformDetailID = 0;

					s.InvoiceNo = invoiceNo;
					s.CreatedBy = "0";
					s.CreatedOn = DateTime.Now.Date;
					s.UpdatedBy = "0";
					s.UpdatedOn = DateTime.Now.Date;
				});
				await _ALSContextDB.UniformDetails.AddRangeAsync(payloadInputList);
				await _ALSContextDB.SaveChangesAsync();
			}
			catch (Exception ex)
			{
			}
			return payloadInputList;
		}
	}
}