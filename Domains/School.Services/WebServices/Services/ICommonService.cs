using System.Data;

namespace School.Services.WebServices.Services
{
	public interface ICommonService
    {
        Task<DataSet> GetNotificationList(int userId);
        Task<int> ApproveNotification(int userId, string NotificationIds);
    }
}
