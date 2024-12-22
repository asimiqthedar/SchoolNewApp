using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using School.Database.WebRepos;
using School.Models.WebModels;
using School.Models.WebModels.DashboardModels;
using School.Services.WebServices.Services;
using System.Data;

namespace School.Services.WebServices.Implementation
{
	public class HomeService : IHomeService
    {
        HomeRepo _HomeRepo;
        private readonly ILogger<HomeService> _logger;
        public HomeService(IOptions<AppSettingConfig> appSettingConfig, ILogger<HomeService> logger)
        {
            _HomeRepo = new HomeRepo(appSettingConfig);
            _logger = logger;
        }
        public async Task<AdminDashboardModel> GetDashboardAdminDetail(int userId)
        {
            try
            {
                AdminDashboardModel ds = await _HomeRepo.GetDashboardAdminDetail(userId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetDashboardAdminDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<AdminDashboardModel> GetInvoiceDataYearly()
        {
            try
            {
                AdminDashboardModel ds = await _HomeRepo.GetInvoiceDataYearly();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetInvoiceDataYearly : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

		public async Task<AdminDashboardModel> GetCostCenterRevenue()
		{
			try
			{
				AdminDashboardModel ds = await _HomeRepo.GetCostCenterRevenue();
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetCostCenterRevenue : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<AdminDashboardModel> GetGradeRevenue()
		{
			try
			{
				AdminDashboardModel ds = await _HomeRepo.GetGradeRevenue();
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetGradeRevenue : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<DataSet> GetNotificationGroup(int loginUserId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationGroup(loginUserId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationGroup : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetNotificationGroupDetail(int notificationGroupId, int notificationTypeId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationGroupDetail(notificationGroupId, notificationTypeId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationGroupDetail : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            try
            {
                int result = await _HomeRepo.ApproveNotificationById(loginUserId, notificationGroupDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:AproveNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveNotifications(int loginUserId, string notificationGroupDetailIds, int NotificationGroupId = 0, int NotificationTypeId = 0)
        {
            try
            {
                int result = await _HomeRepo.ApproveNotifications(loginUserId, notificationGroupDetailIds, NotificationGroupId, NotificationTypeId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveNotifications : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> RejectNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            try
            {
                int result = await _HomeRepo.RejectNotificationById(loginUserId, notificationGroupDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:RejectNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetNotificationGroupDetailById(long notificationGroupDetailId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationGroupDetailById(notificationGroupDetailId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationGroupDetailById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetNotificationGenerateFee()
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationGenerateFee();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationGenerateFee : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveGenerateFeeNotificationById(int loginUserId, int feeGenerateId)
        {
            try
            {
                int result = await _HomeRepo.ApproveGenerateFeeNotificationById(loginUserId, feeGenerateId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveGenerateFeeNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> RejectGenerateFeeNotificationById(int loginUserId, int feeGenerateId)
        {
            try
            {
                int result = await _HomeRepo.RejectGenerateFeeNotificationById(loginUserId, feeGenerateId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:RejectGenerateFeeNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveMultiGenerateFeeNotification(int loginUserId, string notificationGroupDetailIds)
        {
            try
            {
                int result = await _HomeRepo.ApproveMultiGenerateFeeNotification(loginUserId, notificationGroupDetailIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveMultiGenerateFeeNotification : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetGenerateFeeById(int feeGenerateId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetGenerateFee(feeGenerateId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetGenerateFeeById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }

        #region Sibling Discount
        public async Task<DataSet> GetNotificationGenerateSiblingDiscount()
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationGenerateSiblingDiscount();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationGenerateSiblingDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId)
        {
            try
            {
                int result = await _HomeRepo.ApproveGenerateSiblingDiscountNotificationById(loginUserId, siblingDiscountId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveGenerateSiblingDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> RejectGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId)
        {
            try
            {
                int result = await _HomeRepo.RejectGenerateSiblingDiscountNotificationById(loginUserId, siblingDiscountId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:RejectGenerateSiblingDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveMultiGenerateSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            try
            {
                int result = await _HomeRepo.ApproveMultiGenerateSiblingDiscountNotification(loginUserId, notificationGroupDetailIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveMultiGenerateSiblingDiscountNotification : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<DataSet> GetGenerateSiblingDiscountById(int siblingDiscountId)
        {
            try
            {
                DataSet ds = await _HomeRepo.GetGenerateSiblingDiscount(siblingDiscountId);
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetGenerateSiblingDiscountById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Other Discount
        public async Task<DataSet> GetNotificationOtherDiscount()
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationOtherDiscount();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationOtherDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId)
        {
            try
            {
                int result = await _HomeRepo.ApproveOtherDiscountNotificationById(loginUserId, studentOtherDiscountDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveOtherDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> RejectOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId)
        {
            try
            {
                int result = await _HomeRepo.RejectOtherDiscountNotificationById(loginUserId, studentOtherDiscountDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:RejectOtherDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveMultiOtherDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            try
            {
                int result = await _HomeRepo.ApproveMultiOtherDiscountNotification(loginUserId, notificationGroupDetailIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveMultiOtherDiscountNotification : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion

        #region Sibling Discount Indivisual
        public async Task<DataSet> GetNotificationSiblingDiscount()
        {
            try
            {
                DataSet ds = await _HomeRepo.GetNotificationSiblingDiscount();
                return ds;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:GetNotificationSiblingDiscount : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId)
        {
            try
            {
                int result = await _HomeRepo.ApproveSiblingDiscountNotificationById(loginUserId, studentSiblingDiscountDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveSiblingDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> RejectSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId)
        {
            try
            {
                int result = await _HomeRepo.RejectSiblingDiscountNotificationById(loginUserId, studentSiblingDiscountDetailId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:RejectSiblingDiscountNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        public async Task<int> ApproveMultiSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            try
            {
                int result = await _HomeRepo.ApproveMultiSiblingDiscountNotification(loginUserId, notificationGroupDetailIds);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception:HomeService:ApproveMultiSiblingDiscountNotification : Message :{JsonConvert.SerializeObject(ex)}");
                throw ex;
            }
        }
        #endregion


		#region ParentDashboard
		public async Task<DataSet> GetParentFeeInfo(long parentId)
		{
			try
			{
				DataSet ds = await _HomeRepo.GetParentFeeInfo(parentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetParentFeeInfo : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<ParentDashboardModel> GetParentYearwiseFeeInfo(long parentId)
		{
			try
			{
				ParentDashboardModel ds = await _HomeRepo.GetParentYearwiseFeeInfo(parentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetParentYearwiseFeeInfo : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<TotalParentFeeInfoModel> GetTotalParentFeeInfo(long parentId)
		{
			try
			{
				TotalParentFeeInfoModel ds = await _HomeRepo.GetTotalParentFeeInfo(parentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetTotalParentFeeInfo : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		public async Task<ParentDashboardModel> GetParentMonthwiseFeeInfo(long parentId)
		{
			try
			{
				ParentDashboardModel ds = await _HomeRepo.GetParentMonthwiseFeeInfo(parentId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetParentMonthwiseFeeInfo : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

		#endregion

		#region OpenApply Student
		public async Task<DataSet> GetNotificationOpenApplyStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
		{
			try
			{
				DataSet ds = await _HomeRepo.GetNotificationOpenApplyStudent(NotificationTypeId, NotificationGroupId, NotificationGroupDetailId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetNotificationOpenApplyStudent : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveOpenApplyStudentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.ApproveOpenApplyStudentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveOpenApplyStudentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> RejectOpenApplyStudentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.RejectOpenApplyStudentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:RejectOpenApplyStudentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveMultiOpenApplyStudentNotification(int loginUserId, string notificationGroupDetailIds)
		{
			try
			{
				int result = await _HomeRepo.ApproveMultiOpenApplyStudentNotification(loginUserId, notificationGroupDetailIds);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveMultiOpenApplyStudentNotification : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion


		#region OpenApply Parent
		public async Task<DataSet> GetNotificationOpenApplyParent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
		{
			try
			{
				DataSet ds = await _HomeRepo.GetNotificationOpenApplyParent(NotificationTypeId,  NotificationGroupId,  NotificationGroupDetailId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetNotificationOpenApplyParent : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveOpenApplyParentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.ApproveOpenApplyParentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveOpenApplyParentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> RejectOpenApplyParentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.RejectOpenApplyParentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:RejectOpenApplyParentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveMultiOpenApplyParentNotification(int loginUserId, string notificationGroupDetailIds)
		{
			try
			{
				int result = await _HomeRepo.ApproveMultiOpenApplyParentNotification(loginUserId, notificationGroupDetailIds);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveMultiOpenApplyParentNotification : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion

		#region Withdraw Student
		public async Task<DataSet> GetNotificationWithdrawStudent(int NotificationTypeId, int NotificationGroupId, int NotificationGroupDetailId)
		{
			try
			{
				DataSet ds = await _HomeRepo.GetNotificationWithdrawStudent(NotificationTypeId, NotificationGroupId, NotificationGroupDetailId);
				return ds;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:GetNotificationWithdrawStudent : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveWithdrawStudentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.ApproveWithdrawStudentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveWithdrawStudentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> RejectWithdrawStudentNotificationById(int loginUserId, int NotificationGroupDetailId)
		{
			try
			{
				int result = await _HomeRepo.RejectWithdrawStudentNotificationById(loginUserId, NotificationGroupDetailId);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:RejectWithdrawStudentNotificationById : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		public async Task<int> ApproveMultiWithdrawStudentNotification(int loginUserId, string notificationGroupDetailIds)
		{
			try
			{
				int result = await _HomeRepo.ApproveMultiWithdrawStudentNotification(loginUserId, notificationGroupDetailIds);
				return result;
			}
			catch (Exception ex)
			{
				_logger.LogError($"Exception:HomeService:ApproveMultiWithdrawStudentNotification : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}
		#endregion

	}
}