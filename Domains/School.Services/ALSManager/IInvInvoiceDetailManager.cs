using Microsoft.EntityFrameworkCore;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IInvInvoiceDetailManager
	{
		Task<InvInvoiceDetail> GetById(long InvInvoiceDetailId);
		Task<List<InvInvoiceDetail>> GetAllByInvoiceNo(long invoiceNo);
		//Task<List<InvInvoiceDetail>> GetAll(InvInvoiceDetail payloadInput);

		Task<InvInvoiceDetail> Save(InvInvoiceDetail payloadInput);
		Task<List<InvInvoiceDetail>> SaveRange(List<InvInvoiceDetail> payloadInputList, long invoiceNo);

		Task<List<InvInvoiceDetail>> GetAllByInvoiceRefNo(long invoiceNo, long excludeInvoiceNo);
		Task<List<InvInvoiceDetail>> GetAllByParentCode(string parentCode);

	}
	public class InvInvoiceDetailManager : IInvInvoiceDetailManager
	{
		private readonly ALSContext _ALSContextDB;
		public InvInvoiceDetailManager(ALSContext aLSContextDB)
		{
			_ALSContextDB = aLSContextDB;
		}
		public async Task<InvInvoiceDetail> GetById(long invoiceNo)
		{
			return await _ALSContextDB.InvInvoiceDetails.FirstOrDefaultAsync(s => s.InvoiceNo == invoiceNo);
		}
		public async Task<List<InvInvoiceDetail>> GetAllByInvoiceNo(long invoiceNo)
		{
			return await _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNo && s.IsDeleted == false).ToListAsync();
		}

		public async Task<List<InvInvoiceDetail>> GetAllByInvoiceRefNo(long invoiceNo, long excludeInvoiceNo)
		{
			return await (from det in _ALSContextDB.InvInvoiceDetails
						  join sum in _ALSContextDB.InvInvoiceSummaries
						  on det.InvoiceNo equals sum.InvoiceNo
						  where det.InvoiceRefNo == invoiceNo && det.InvoiceNo != excludeInvoiceNo && det.IsDeleted == false
						  && sum.IsDeleted == false
						  select det
					 )
					 .ToListAsync();
		}

		//public async Task<List<InvInvoiceDetail>> GetAll(InvInvoiceDetail payloadInput)
		//{
		//    return await _ALSContextDB.InvInvoiceDetails.Where(s => !s.IsDeleted).ToListAsync();
		//}

		public async Task<InvInvoiceDetail> Save(InvInvoiceDetail payloadInput)
		{
			if (payloadInput.InvoiceDetailId > 0)
			{
				var record = await _ALSContextDB.InvInvoiceDetails.FirstOrDefaultAsync(s => s.InvoiceDetailId == payloadInput.InvoiceDetailId);
				if (record != null)
				{
					record.IqamaNumber = payloadInput.IqamaNumber;
					record.InvoiceDetailId = payloadInput.InvoiceDetailId;
					record.InvoiceNo = payloadInput.InvoiceNo;
					record.AcademicYear = payloadInput.AcademicYear;
					record.InvoiceType = payloadInput.InvoiceType;
					record.Description = payloadInput.Description;
					record.ItemCode = payloadInput.ItemCode;
					record.StudentId = payloadInput.StudentId;
					record.Discount = payloadInput.Discount;
					record.Quantity = payloadInput.Quantity;
					record.UnitPrice = payloadInput.UnitPrice;
					record.TaxableAmount = payloadInput.TaxableAmount;
					record.TaxRate = payloadInput.TaxRate;
					record.TaxAmount = payloadInput.TaxAmount;
					record.ItemSubtotal = payloadInput.ItemSubtotal;
					record.ParentId = payloadInput.ParentId;
					record.StudentName = payloadInput.StudentName;
					record.ParentName = payloadInput.ParentName;
					record.GradeId = payloadInput.GradeId;
					record.NationalityId = payloadInput.NationalityId;
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
				if (invoiceNo > 0)
				{
					List<InvInvoiceDetail> listOfexsitingRecord = new List<InvInvoiceDetail>();
					listOfexsitingRecord = _ALSContextDB.InvInvoiceDetails.Where(s => s.InvoiceNo == invoiceNo).ToList();
					if (listOfexsitingRecord.Any())
						_ALSContextDB.InvInvoiceDetails.RemoveRange(listOfexsitingRecord);
				}
				payloadInputList.ForEach(s =>
				{
					s.InvoiceDetailId = 0;
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


		public async Task<List<InvInvoiceDetail>> GetAllByParentCode(string parentCode)
		{
			var query = (from invD in _ALSContextDB.InvInvoiceDetails.AsQueryable()
						 join aca in _ALSContextDB.TblSchoolAcademics.AsQueryable()
						 on invD.AcademicYear equals aca.SchoolAcademicId.ToString()
						 where invD.ParentCode == parentCode && aca.IsActive && !aca.IsDeleted
						 select new InvInvoiceDetail
						 {
							 InvoiceDetailId = invD.InvoiceDetailId,
							 InvoiceNo = invD.InvoiceNo,
							 AcademicYear = aca.AcademicYear,
							 InvoiceType = invD.InvoiceType,
							 Description = invD.Description,
							 ItemCode = invD.ItemCode,
							 StudentId = invD.StudentId,
							 Discount = invD.Discount,
							 Quantity = invD.Quantity,
							 UnitPrice = invD.UnitPrice,
							 TaxableAmount = invD.TaxableAmount,
							 TaxRate = invD.TaxRate,
							 TaxAmount = invD.TaxAmount,
							 ItemSubtotal = invD.ItemSubtotal,
							 IsDeleted = invD.IsDeleted,
							 UpdateDate = invD.UpdateDate,
							 UpdateBy = invD.UpdateBy,
							 ParentId = invD.ParentId,
							 StudentName = invD.StudentName,
							 ParentName = invD.ParentName,
							 GradeId = invD.GradeId,
							 NationalityId = invD.NationalityId,
							 IqamaNumber = invD.IqamaNumber,
							 InvoiceDetailRefId = invD.InvoiceDetailRefId,
							 InvoiceRefNo = invD.InvoiceRefNo,
							 IsStaff = invD.IsStaff,
							 FatherMobile = invD.FatherMobile,
							 StudentCode = invD.StudentCode,
							 ParentCode = invD.ParentCode,
							 IsAdvance = invD.IsAdvance
						 }).ToList();
			return query;
		}
	}
}