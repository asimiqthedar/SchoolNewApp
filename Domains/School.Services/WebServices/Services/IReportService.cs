using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IReportService
	{
		Task<DataSet> GetCSVReportData(string reportKey, string reportParams);
		Task<DataSet> GetStudentReport(int academicYearId, int parentId, int studentId);
		Task<DataSet> GetMonthlyStatementByParentStudents(int parentId, string parentName, int academicYearId, string startDate, string endDate);
		Task<DataSet> GetMonthlyStatementUniformByParentStudents(string itemCode, long invoiceNo, string parentName, string fatherMobile, string paymentMethod, string paymentRefNo, string startDate, string endDate);
		Task<DataSet> GetTuitionReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate);
		Task<DataSet> GetEntranceReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate);
		Task<DataSet> GetAdvanceFeeReport(int academicYear, int parentId, string parentName, string fatherIqama, string studentName, long invoiceNo, string startDate, string endDate);
		Task<DataSet> GetDiscountReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string startDate, string endDate);
		Task<DataSet> GetAllRevenueReport(int parentId, string parentName, string fatherIqama, string studentName, int academicYear, string invoiceNo, string startDate, string endDate);
		Task<DataSet> GetStudentStatementParentWise(int parentId, string parentName, string fatherIqama, string fatherMobile, int academicYear);
		Task<DataSet> GetParent(int parentId);
        Task<DataSet> GetGeneralReport(int academicYear, int costcenter, int grade, int gender);
		Task<DataSet> GetParentStudentReport(int parentId, int studentId, int academicYear, int costcenter, int grade, int gender, string startDate, string endDate);
		Task<DataSet> GetParentReport(int parentId, int academicYear, string startDate, string endDate);

	}
}
