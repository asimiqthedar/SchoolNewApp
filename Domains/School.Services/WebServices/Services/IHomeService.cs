using School.Models.WebModels.DashboardModels;
using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IHomeService
    {
        Task<AdminDashboardModel> GetDashboardAdminDetail(int userId);
        Task<AdminDashboardModel> GetInvoiceDataYearly();
		Task<AdminDashboardModel> GetCostCenterRevenue();
		Task<AdminDashboardModel> GetGradeRevenue();
		Task<DataSet> GetNotificationGroup(int loginUserId);
        Task<DataSet> GetNotificationGroupDetail(int notificationGroupId, int notificationTypeId);
        Task<int> ApproveNotificationById(int loginUserId, int notificationGroupDetailId);
        Task<int> RejectNotificationById(int loginUserId, int notificationGroupDetailId);
        Task<DataSet> GetNotificationGroupDetailById(long notificationGroupDetailId);
        Task<int> ApproveNotifications(int loginUserId, string notificationGroupDetailIds, int NotificationGroupId = 0, int NotificationTypeId = 0);

        Task<DataSet> GetNotificationGenerateFee();
        Task<int> ApproveGenerateFeeNotificationById(int loginUserId, int feeGenerateId);
        Task<int> RejectGenerateFeeNotificationById(int loginUserId, int feeGenerateId);
        Task<int> ApproveMultiGenerateFeeNotification(int loginUserId, string notificationGroupDetailIds);
        Task<DataSet> GetGenerateFeeById(int feeGenerateId);

        #region Sibling Discount
        Task<DataSet> GetNotificationGenerateSiblingDiscount();
        Task<int> ApproveGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId);
        Task<int> RejectGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId);
        Task<int> ApproveMultiGenerateSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds);
        Task<DataSet> GetGenerateSiblingDiscountById(int siblingDiscountId);
        #endregion

        #region Other Discount
        Task<DataSet> GetNotificationOtherDiscount();
        Task<int> ApproveOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId);
        Task<int> RejectOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId);
        Task<int> ApproveMultiOtherDiscountNotification(int loginUserId, string notificationGroupDetailIds);
        #endregion

        #region Sibling Discount Indivisual
        Task<DataSet> GetNotificationSiblingDiscount();
        Task<int> ApproveSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId);
        Task<int> RejectSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId);
        Task<int> ApproveMultiSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds);
        #endregion

        #region Parent Dashboard
        Task<DataSet> GetParentFeeInfo(long parentId);
        Task<ParentDashboardModel> GetParentYearwiseFeeInfo(long parentId);
        Task<ParentDashboardModel> GetParentMonthwiseFeeInfo(long parentId);

		Task<TotalParentFeeInfoModel> GetTotalParentFeeInfo(long parentId);

		#endregion
		#region OpenApply Student
		Task<DataSet> GetNotificationOpenApplyStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId);
        Task<int> ApproveOpenApplyStudentNotificationById(int loginUserId, int studentOpenApplyStudentDetailId);
        Task<int> RejectOpenApplyStudentNotificationById(int loginUserId, int studentOpenApplyStudentDetailId);
        Task<int> ApproveMultiOpenApplyStudentNotification(int loginUserId, string notificationGroupDetailIds);

		#endregion OpenApply Student

		#region OpenApply Parent
		Task<DataSet> GetNotificationOpenApplyParent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId);
		Task<int> ApproveOpenApplyParentNotificationById(int loginUserId, int studentOpenApplyParentDetailId);
        Task<int> RejectOpenApplyParentNotificationById(int loginUserId, int studentOpenApplyParentDetailId);
        Task<int> ApproveMultiOpenApplyParentNotification(int loginUserId, string notificationGroupDetailIds);
        #endregion OpenApply Parent

        #region Withdraw Student
        Task<DataSet> GetNotificationWithdrawStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId);
        Task<int> ApproveWithdrawStudentNotificationById(int loginUserId, int NotificationGroupDetailId);

        Task<int> RejectWithdrawStudentNotificationById(int loginUserId, int NotificationGroupDetailId);
        Task<int> ApproveMultiWithdrawStudentNotification(int loginUserId, string notificationGroupDetailIds);
		#endregion Withdraw Student
	}

}
