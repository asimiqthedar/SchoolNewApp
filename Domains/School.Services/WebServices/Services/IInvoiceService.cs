using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.VatModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IInvoiceService
	{
		Task<DataSet> GetInvoice(InvoiceFilterModel filterModel);
		Task<DataSet> GetReturnInvoices();
		Task<int> DeleteInvoice(int loginUserId, long invoiceId);

		Task<long> GetLatestInvoice();

		Task<DataSet> GetItemCodeRecords();
		Task<DataSet> GetUniformByItemCode(string itemCode, int nationalId = 0);

		long ProcessInvoiceStatement(long invoiceNo);
		long ProcessGP(long invoiceNo);

		#region tuitionFee
		Task<DataSet> GetStudentByParentId(long parentId);
		Task<DataSet> GetStudentById(long studentId);
		Task<DataSet> GetParentById(long parentId);
		Task<VatDetailModel> GetVATDetail(string invoiceTypeName, int nationalId);
		Task<InvoiceFeeDetailModel> GetFeeAmount(long academicYearId, long studentId, string InvoiceTypeName);
		Task<List<InvoiceFeeDetailParentStudentModel>> GetFeeAmountParentStudent(long academicYearId, long parentid, string InvoiceTypeName);

		#endregion

		#region Email
		Task<bool> SendInvoice(int invoiceId);
		Task<bool> SendInvoiceEmailWithInvoiceAttachment(long invoiceId, string filePath, string emailTo);
		#endregion

		#region GP integration
		Task<DataSet> ProcessGPUniformInvoice(int invoiceno);
		#endregion

		#region payment Method
		Task<DataSet> GetPaymentMethod();
		#endregion

		#region Parent Balance Amount
		Task<DataSet> GetParentFeeBalance(long parentId);
		#endregion
	}
}
