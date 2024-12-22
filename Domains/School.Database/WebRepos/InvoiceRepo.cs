using Microsoft.Extensions.Options;
using School.Common.Helpers;
using School.Models.WebModels;
using School.Models.WebModels.InvoiceSetupModels;
using School.Models.WebModels.VatModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class InvoiceRepo
	{
		DbHelper _DbHelper;
		IOptions<AppSettingConfig> _AppSettingConfig;
		public InvoiceRepo(IOptions<AppSettingConfig> appSettingConfig)
		{
			_AppSettingConfig = appSettingConfig;
			_DbHelper = new DbHelper(appSettingConfig);
		}

		#region Invoice
		public async Task<DataSet> GetInvoice(int invoiceId, InvoiceFilterModel filterModel)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@InvoiceId", SqlDbType.Int) { Value = invoiceId });
			ls_p.Add(new SqlParameter("@Status", SqlDbType.NVarChar) { Value = filterModel.Status });
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.NVarChar) { Value = filterModel.InvoiceNo });
			ls_p.Add(new SqlParameter("@InvoiceType", SqlDbType.NVarChar) { Value = filterModel.InvoiceType });
			ls_p.Add(new SqlParameter("@ParentCode", SqlDbType.NVarChar) { Value = filterModel.ParentCode });
			ls_p.Add(new SqlParameter("@ParentName", SqlDbType.NVarChar) { Value = filterModel.ParentName });
			ls_p.Add(new SqlParameter("@FatherMobile", SqlDbType.NVarChar) { Value = filterModel.FatherMobile });
			ls_p.Add(new SqlParameter("@InvoiceDateStart", SqlDbType.DateTime) { Value = filterModel.InvoiceDateStart });
			ls_p.Add(new SqlParameter("@InvoiceDateEnd", SqlDbType.DateTime) { Value = filterModel.InvoiceDateEnd });
			ls_p.Add(new SqlParameter("@FatherIqama", SqlDbType.NVarChar) { Value = filterModel.FatherIqama });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetInvoice", ls_p);
		}
		public async Task<DataSet> GetReturnInvoices()
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			return await _DbHelper.ExecuteDataProcedureAsync("p_GetReturnInvoice", ls_p);
		}
		public async Task<int> DeleteInvoice(int loginUserId, long invoiceId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@InvoiceId", SqlDbType.Int) { Value = invoiceId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_DeleteInvoice", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}

		public async Task<long> GetLatestInvoice()
		{
			long result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetInvoiceNo", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt64(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}

		public long ProcessInvoiceStatement(long invoiceNo)
		{
			long result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@DestinationDB", SqlDbType.NVarChar) { Value = _AppSettingConfig.Value.UniformDB });
			DataSet ds = _DbHelper.ExecuteDataProcedure("sp_SaveInvoiceToStatement", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt64(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}

		public long ProcessGP(long invoiceNo)
		{
			long result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@InvoiceNo", SqlDbType.BigInt) { Value = invoiceNo });
			ls_p.Add(new SqlParameter("@DestinationDB", SqlDbType.NVarChar) { Value = _AppSettingConfig.Value.UniformDB });
			DataSet ds =  _DbHelper.ExecuteDataProcedure("sp_ProcessGP", ls_p);
			var tableCount = ds != null && ds.Tables.Count > 0 ? ds.Tables.Count : 0;

			if (tableCount > 0 && ds.Tables[tableCount - 1].Rows.Count > 0)
				result = Convert.ToInt64(ds.Tables[tableCount - 1].Rows[0]["Result"]);
			return result;
		}
		#endregion

		#region UniformFee
		public async Task<DataSet> GetItemCodeRecords()
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@UniformDB", SqlDbType.NVarChar) { Value = _AppSettingConfig.Value.UniformDB });
			return await _DbHelper.ExecuteDataProcedureAsync("SP_ItemCodeRecords", ls_p);
		}

		public async Task<DataSet> GetUniformByItemCode(string itemCode, int nationalId = 0)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ItemCode", SqlDbType.NVarChar) { Value = itemCode });
			ls_p.Add(new SqlParameter("@nationalId", SqlDbType.Int) { Value = nationalId });
			ls_p.Add(new SqlParameter("@UniformDB", SqlDbType.NVarChar) { Value = _AppSettingConfig.Value.UniformDB });
			return await _DbHelper.ExecuteDataProcedureAsync("Sp_GetItemCodeRecord", ls_p);
		}
		#endregion

		#region tuitionFee
		public async Task<DataSet> GetParentById(long parentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.BigInt) { Value = parentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentById", ls_p);
		}

		public async Task<DataSet> GetStudentByParentId(long parentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.BigInt) { Value = parentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentByParentId", ls_p);
		}

		public async Task<DataSet> GetStudentById(long studentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = studentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetStudentById", ls_p);
		}

		public async Task<VatDetailModel> GetVATDetail(string invoiceTypeName, int nationalId)
		{
			VatDetailModel vatDetailModel = new VatDetailModel();
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@InvoiceTypeName", SqlDbType.NVarChar) { Value = invoiceTypeName });
			ls_p.Add(new SqlParameter("@NationalityId", SqlDbType.NVarChar) { Value = nationalId });
			var ResultDS = await _DbHelper.ExecuteDataProcedureAsync("SP_GetVATDetail", ls_p);

			if (ResultDS.Tables.Count > 0)
			{
				var ResultDT = ResultDS.Tables[0];
				List<VatDetailModel> listRecord = new List<VatDetailModel>();
				listRecord = Extentions.ConvertToList<VatDetailModel>(ResultDT);
				return listRecord.FirstOrDefault();
			}
			return vatDetailModel;
		}

		public async Task<InvoiceFeeDetailModel> GetFeeAmount(long academicYearId, long studentId, string InvoiceTypeName)
		{
			InvoiceFeeDetailModel vatDetailModel = new InvoiceFeeDetailModel();
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = academicYearId });
			ls_p.Add(new SqlParameter("@StudentId", SqlDbType.BigInt) { Value = studentId });
			ls_p.Add(new SqlParameter("@InvoiceTypeName", SqlDbType.NVarChar) { Value = InvoiceTypeName });
			var ResultDS = await _DbHelper.ExecuteDataProcedureAsync("SP_GetFeeAmount", ls_p);

			if (ResultDS.Tables.Count > 0)
			{
				var ResultDT = ResultDS.Tables[0];
				List<InvoiceFeeDetailModel> listRecord = new List<InvoiceFeeDetailModel>();
				listRecord = Extentions.ConvertToList<InvoiceFeeDetailModel>(ResultDT);
				return listRecord.FirstOrDefault();
			}
			return vatDetailModel;
		}

		public async Task<List<InvoiceFeeDetailParentStudentModel>> GetFeeAmountParentStudent(long academicYearId, long parentid, string InvoiceTypeName)
		{
			List<InvoiceFeeDetailParentStudentModel> vatDetailModel = new List<InvoiceFeeDetailParentStudentModel>();
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@AcademicYearId", SqlDbType.BigInt) { Value = academicYearId });
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.BigInt) { Value = parentid });
			ls_p.Add(new SqlParameter("@InvoiceTypeName", SqlDbType.NVarChar) { Value = InvoiceTypeName });
			var ResultDS = await _DbHelper.ExecuteDataProcedureAsync("SP_GetFeeAmountParentStudent", ls_p);

			if (ResultDS.Tables.Count > 0)
			{
				var ResultDT = ResultDS.Tables[0];
				vatDetailModel = Extentions.ConvertToList<InvoiceFeeDetailParentStudentModel>(ResultDT);
			}
			return vatDetailModel;
		}

		#endregion

		#region GP integration
		public async Task<DataSet> ProcessGPUniformInvoice(int invoiceno)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.Int) { Value = invoiceno });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_ProcessGP_UniformInvoice", ls_p);
		}
		#endregion

		#region Payment Method
		public async Task<DataSet> GetPaymentMethod()
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetPaymentMethod", ls_p);
		}
		#endregion

		#region Parent Balance Amount
		public async Task<DataSet> GetParentFeeBalance(long parentId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@ParentId", SqlDbType.BigInt) { Value = parentId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentFeeBalance", ls_p);
		}
		#endregion
	}
}
