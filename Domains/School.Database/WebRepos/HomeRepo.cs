using Microsoft.Extensions.Options;
using School.Models.WebModels;
using School.Models.WebModels.DashboardModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class HomeRepo
    {
        DbHelper _DbHelper;
        public HomeRepo(IOptions<AppSettingConfig> appSettingConfig)
        {
            _DbHelper = new DbHelper(appSettingConfig);
        }
        public async Task<AdminDashboardModel> GetDashboardAdminDetail(int userId)
        {
            AdminDashboardModel adminDashboardModel = new AdminDashboardModel();
            //return new DataSet();
            List<SqlParameter> ls_p = new List<SqlParameter>();
            //ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_getAdminDashboardData", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                adminDashboardModel.TotalStudent = Convert.ToInt32(ds.Tables[0].Rows[0]["TotalStudent"]);
            }
            if (ds != null && ds.Tables.Count >= 1 && ds.Tables[1].Rows.Count > 0)
            {
                adminDashboardModel.TotalParent = Convert.ToInt32(ds.Tables[1].Rows[0]["TotalParent"]);
            }
            if (ds != null && ds.Tables.Count >= 2 && ds.Tables[2].Rows.Count > 0)
            {
                adminDashboardModel.GradeWiseStudent = new List<GenderModelSeries>();
                for (int i = 0; i < ds.Tables[2].Rows.Count; i++)
                {
                    GenderModelSeries modelSeries = new GenderModelSeries();
                    modelSeries.KeyName = Convert.ToString(ds.Tables[2].Rows[i]["KeyName"]);
                    modelSeries.KeyValue = Convert.ToInt32(ds.Tables[2].Rows[i]["KeyValue"]);
                    modelSeries.Gender = Convert.ToString(ds.Tables[2].Rows[i]["Gender"]);
                    adminDashboardModel.GradeWiseStudent.Add(modelSeries);
                }
            }
            if (ds != null && ds.Tables.Count >= 3 && ds.Tables[3].Rows.Count > 0)
            {
                adminDashboardModel.YearWiseStudent = new List<ModelSeries>();
                for (int i = 0; i < ds.Tables[3].Rows.Count; i++)
                {
                    ModelSeries modelSeries = new ModelSeries();
                    modelSeries.KeyName = Convert.ToString(ds.Tables[3].Rows[i]["KeyName"]);
                    modelSeries.KeyValue = Convert.ToInt32(ds.Tables[3].Rows[i]["KeyValue"]);
                    adminDashboardModel.YearWiseStudent.Add(modelSeries);
                }
            }

            if (ds != null && ds.Tables.Count >= 4 && ds.Tables[4].Rows.Count > 0)
            {
                adminDashboardModel.MonthlyUniformRevenue = Convert.ToString(ds.Tables[4].Rows[0]["MonthlyUniformRevenue"]);
                adminDashboardModel.MonthlyEntranceRevenue = Convert.ToString(ds.Tables[4].Rows[0]["MonthlyEntranceRevenue"]);
                adminDashboardModel.MonthlyTutitionRevenue = Convert.ToString(ds.Tables[4].Rows[0]["MonthlyTuitionRevenue"]);
            }

            if (ds != null && ds.Tables.Count >= 5 && ds.Tables[5].Rows.Count > 0)
            {
                adminDashboardModel.StudentStatus = new List<StatusModel>();
                for (int i = 0; i < ds.Tables[5].Rows.Count; i++)
                {
                    StatusModel status = new StatusModel();
                    status.StatusName = Convert.ToString(ds.Tables[5].Rows[i]["StatusName"]);
                    status.StatusCount = Convert.ToInt32(ds.Tables[5].Rows[i]["StatusCount"]);
                    adminDashboardModel.StudentStatus.Add(status);
                }
            }

			if (ds != null && ds.Tables.Count >= 6 && ds.Tables[4].Rows.Count > 0)
			{
				adminDashboardModel.TotalYearlyAppliedFee = Convert.ToString(ds.Tables[6].Rows[0]["TotalYearlyAppliedFee"]);
				adminDashboardModel.YearlyEntranceRevenue = Convert.ToString(ds.Tables[6].Rows[0]["YearlyEntranceRevenue"]);
				adminDashboardModel.YearlyUniformRevenue = Convert.ToString(ds.Tables[6].Rows[0]["YearlyUniformRevenue"]);
				adminDashboardModel.YearlyTuitionRevenue = Convert.ToString(ds.Tables[6].Rows[0]["YearlyTuitionRevenue"]);
			}

			//if (ds != null && ds.Tables.Count >= 4 && ds.Tables[4].Rows.Count > 0)
			//{
			//    adminDashboardModel.InvoiceWiseData = new List<InvoiceDataModel>();
			//    for (int i = 0; i < ds.Tables[4].Rows.Count; i++)
			//    {
			//        InvoiceDataModel invoice = new InvoiceDataModel();
			//        invoice.InvoiceYear = Convert.ToString(ds.Tables[4].Rows[i]["InvoiceYear"]);
			//        invoice.Discount = Convert.ToDecimal(ds.Tables[4].Rows[i]["Discount"]);
			//        invoice.TaxableAmount = Convert.ToDecimal(ds.Tables[4].Rows[i]["TaxableAmount"]);
			//        invoice.TaxAmount = Convert.ToDecimal(ds.Tables[4].Rows[i]["TaxAmount"]);
			//        invoice.ItemSubtotal = Convert.ToDecimal(ds.Tables[4].Rows[i]["ItemSubtotal"]);
			//        adminDashboardModel.InvoiceWiseData.Add(invoice);
			//    }
			//}
			return adminDashboardModel;
        }
        public async Task<AdminDashboardModel> GetInvoiceDataYearly()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            AdminDashboardModel adminDashboard = new AdminDashboardModel();
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetInvoiceDataYearly", ls_p);
            if (ds != null && ds.Tables.Count > 0)
            {
                adminDashboard.InvoiceWiseData = new List<InvoiceDataModel>();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    InvoiceDataModel invoice = new InvoiceDataModel();
                    invoice.MonthNames = Convert.ToString(ds.Tables[0].Rows[i]["MonthName"]);
                    invoice.MonthlyUniformRevenue = Convert.ToString(ds.Tables[0].Rows[i]["MonthlyUniformRevenue"]);
                    invoice.MonthlyEntranceRevenue = Convert.ToString(ds.Tables[0].Rows[i]["MonthlyEntranceRevenue"]);
                    invoice.MonthlyTutitionRevenue = Convert.ToString(ds.Tables[0].Rows[i]["MonthlyTuitionRevenue"]);
                    adminDashboard.InvoiceWiseData.Add(invoice);
                }
            }
            return adminDashboard;
        }

        public async Task<AdminDashboardModel> GetCostCenterRevenue()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            AdminDashboardModel adminDashboard = new AdminDashboardModel();
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetCostCenterFees", ls_p);
            if (ds != null && ds.Tables.Count > 0)
            {
                adminDashboard.CostRevenueData = new List<CostCenterRevenueModel>();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    CostCenterRevenueModel costCenterRevenue = new CostCenterRevenueModel();
                    costCenterRevenue.CostCenterName = Convert.ToString(ds.Tables[0].Rows[i]["CostCenterName"]);
                    costCenterRevenue.TotalAppliedFee = Convert.ToString(ds.Tables[0].Rows[i]["TotalAppliedFee"]);
                    costCenterRevenue.TotalPaidAmount = Convert.ToString(ds.Tables[0].Rows[i]["TotalPaidAmount"]);
                    adminDashboard.CostRevenueData.Add(costCenterRevenue);
                }
            }
            return adminDashboard;
        }

        public async Task<AdminDashboardModel> GetGradeRevenue()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            AdminDashboardModel adminDashboard = new AdminDashboardModel();
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetGradeFees", ls_p);
            if (ds != null && ds.Tables.Count > 0)
            {
                adminDashboard.GradeRevenueData = new List<GradeRevenueModel>();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    GradeRevenueModel gradeRevenue = new GradeRevenueModel();
                    gradeRevenue.GradeName = Convert.ToString(ds.Tables[0].Rows[i]["GradeName"]);
                    gradeRevenue.TotalAppliedFee = Convert.ToString(ds.Tables[0].Rows[i]["TotalAppliedFee"]);
                    gradeRevenue.TotalPaidAmount = Convert.ToString(ds.Tables[0].Rows[i]["TotalPaidAmount"]);
                    adminDashboard.GradeRevenueData.Add(gradeRevenue);
                }
            }
            return adminDashboard;
        }

        public async Task<DataSet> GetNotificationList(int userId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@UserId", SqlDbType.Int) { Value = userId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationList", ls_p);
        }
        public async Task<int> ApproveNotification(int userId, string NotificationIds)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = userId });
            ls_p.Add(new SqlParameter("@NotificationIds", SqlDbType.VarChar) { Value = NotificationIds });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveNotification", ls_p);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<DataSet> GetNotificationGroup(int loginUserId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationGroup", ls_p);
        }
        public async Task<DataSet> GetNotificationGroupDetail(int notificationGroupId, int notificationTypeId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@NotificationGroupId", SqlDbType.Int) { Value = notificationGroupId });
            ls_p.Add(new SqlParameter("@NotificationTypeId", SqlDbType.Int) { Value = notificationTypeId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationGroupDetail", ls_p);
        }
        public async Task<int> ApproveNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveNotificationById", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveNotifications(int loginUserId, string notificationGroupDetailIds, int NotificationGroupId = 0, int notificationTypeId = 0)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailIds", SqlDbType.NVarChar) { Value = notificationGroupDetailIds });
            ls_p.Add(new SqlParameter("@NotificationGroupId", SqlDbType.Int) { Value = NotificationGroupId });
            ls_p.Add(new SqlParameter("@NotificationTypeId", SqlDbType.Int) { Value = notificationTypeId });

            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveNotifications", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_RejectNotificationById", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<DataSet> GetNotificationGroupDetailById(long notificationGroupDetailId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.BigInt) { Value = notificationGroupDetailId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationGroupDetailById", ls_p);
        }
        public async Task<DataSet> GetNotificationGenerateFee()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = 0 });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationGenerateFee", ls_p);
        }
        public async Task<int> ApproveGenerateFeeNotificationById(int loginUserId, int feeGenerateId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = feeGenerateId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateFee", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectGenerateFeeNotificationById(int loginUserId, int feeGenerateId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = feeGenerateId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 4 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateFee", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveMultiGenerateFeeNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string feeGenerateId in notificationGroupDetailIds.Split(','))
            {
                int feeGenerateIdOut = 0;
                int.TryParse(feeGenerateId.Trim(), out feeGenerateIdOut);
                if (feeGenerateIdOut > 0)
                {
                    result = await ApproveGenerateFeeNotificationById(loginUserId, feeGenerateIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
        public async Task<DataSet> GetGenerateFee(int feeGenerateId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@FeeGenerateId", SqlDbType.Int) { Value = feeGenerateId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGenerateFee", ls_p);
        }

        #region Sibling Discount Group 
        public async Task<DataSet> GetNotificationGenerateSiblingDiscount()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = 0 });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationGenerateSiblingDiscount", ls_p);
        }
        public async Task<int> ApproveGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = siblingDiscountId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectGenerateSiblingDiscountNotificationById(int loginUserId, int siblingDiscountId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = siblingDiscountId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 4 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateGenerateSiblingDiscount", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveMultiGenerateSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string siblingDiscountId in notificationGroupDetailIds.Split(','))
            {
                int siblingDiscountIdGenerateIdOut = 0;
                int.TryParse(siblingDiscountId.Trim(), out siblingDiscountIdGenerateIdOut);
                if (siblingDiscountIdGenerateIdOut > 0)
                {
                    result = await ApproveGenerateSiblingDiscountNotificationById(loginUserId, siblingDiscountIdGenerateIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
        public async Task<DataSet> GetGenerateSiblingDiscount(int siblingDiscountId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@SiblingDiscountId", SqlDbType.Int) { Value = siblingDiscountId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetGenerateSiblingDiscount", ls_p);
        }
        #endregion

        #region Other Discount
        public async Task<DataSet> GetNotificationOtherDiscount()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationOtherDiscount", ls_p);
        }
        public async Task<int> ApproveOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentOtherDiscountDetailId", SqlDbType.Int) { Value = studentOtherDiscountDetailId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateOtherDiscountStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectOtherDiscountNotificationById(int loginUserId, int studentOtherDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentOtherDiscountDetailId", SqlDbType.Int) { Value = studentOtherDiscountDetailId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 4 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateOtherDiscountStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveMultiOtherDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string studentOtherDiscountDetailId in notificationGroupDetailIds.Split(','))
            {
                int studentOtherDiscountDetailIdOut = 0;
                int.TryParse(studentOtherDiscountDetailId.Trim(), out studentOtherDiscountDetailIdOut);
                if (studentOtherDiscountDetailIdOut > 0)
                {
                    result = await ApproveOtherDiscountNotificationById(loginUserId, studentOtherDiscountDetailIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
        #endregion

        #region Sibling Discount Indivisual
        public async Task<DataSet> GetNotificationSiblingDiscount()
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationSiblingDiscount", ls_p);
        }
        public async Task<int> ApproveSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentSiblingDiscountDetailId", SqlDbType.Int) { Value = studentSiblingDiscountDetailId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateSiblingDiscountStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectSiblingDiscountNotificationById(int loginUserId, int studentSiblingDiscountDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@StudentSiblingDiscountDetailId", SqlDbType.Int) { Value = studentSiblingDiscountDetailId });
            ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 4 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_UpdateSiblingDiscountStatus", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveMultiSiblingDiscountNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string studentSiblingDiscountDetailId in notificationGroupDetailIds.Split(','))
            {
                int studentSiblingDiscountDetailIdOut = 0;
                int.TryParse(studentSiblingDiscountDetailId.Trim(), out studentSiblingDiscountDetailIdOut);
                if (studentSiblingDiscountDetailIdOut > 0)
                {
                    result = await ApproveSiblingDiscountNotificationById(loginUserId, studentSiblingDiscountDetailIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
        #endregion

        #region Parent Dashboard
        public async Task<DataSet> GetParentFeeInfo(long parentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@parentId", SqlDbType.BigInt) { Value = parentId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentFeeInfo", ls_p);
        }

        public async Task<ParentDashboardModel> GetParentYearwiseFeeInfo(long parentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@parentId", SqlDbType.BigInt) { Value = parentId });
            ParentDashboardModel parentDashboard = new ParentDashboardModel();
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentYearwiseFeeInfo", ls_p);
            if (ds != null && ds.Tables.Count > 0)
            {
                parentDashboard.ParentYearwiseFeeInfo = new List<ParentYearwiseFeeInfoModel>();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    ParentYearwiseFeeInfoModel parentfees = new ParentYearwiseFeeInfoModel();
                    parentfees.YearNumber = Convert.ToString(ds.Tables[0].Rows[i]["YearNumber"]);
                    parentfees.TotalFee = Convert.ToString(ds.Tables[0].Rows[i]["TotalFee"]);
                    parentfees.FeePaid = Convert.ToString(ds.Tables[0].Rows[i]["FeePaid"]);

                    parentDashboard.ParentYearwiseFeeInfo.Add(parentfees);
                }
            }
            return parentDashboard;
        }


        public async Task<TotalParentFeeInfoModel> GetTotalParentFeeInfo(long parentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@parentId", SqlDbType.BigInt) { Value = parentId });

            TotalParentFeeInfoModel totalParentFeeInfo = new TotalParentFeeInfoModel();

            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetTotalParentFeeInfo", ls_p);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                totalParentFeeInfo.TotalFee = Convert.ToString(ds.Tables[0].Rows[0]["TotalFee"]);
                totalParentFeeInfo.FeePaid = Convert.ToString(ds.Tables[0].Rows[0]["FeePaid"]);
            }

            return totalParentFeeInfo;
        }

        public async Task<ParentDashboardModel> GetParentMonthwiseFeeInfo(long parentId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@parentId", SqlDbType.BigInt) { Value = parentId });
            ParentDashboardModel parentDashboard = new ParentDashboardModel();
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_GetParentMonthwiseFeeInfo", ls_p);
            if (ds != null && ds.Tables.Count > 0)
            {
                parentDashboard.ParentMonthwiseFeeInfo = new List<ParentMonthwiseFeeInfoModel>();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    ParentMonthwiseFeeInfoModel parentfees = new ParentMonthwiseFeeInfoModel();
                    parentfees.MonthName = Convert.ToString(ds.Tables[0].Rows[i]["MonthName"]);
                    parentfees.TotalFee = Convert.ToString(ds.Tables[0].Rows[i]["TotalFee"]);
                    parentfees.FeePaid = Convert.ToString(ds.Tables[0].Rows[i]["FeePaid"]);

                    parentDashboard.ParentMonthwiseFeeInfo.Add(parentfees);
                }
            }
            return parentDashboard;
        }

        #endregion

        #region OpenApply Student
        public async Task<DataSet> GetNotificationOpenApplyStudent(int notificationTypeId, int notificationGroupId, int notificationGroupDetailId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@NotificationTypeId", SqlDbType.Int) { Value = notificationTypeId });
            ls_p.Add(new SqlParameter("@NotificationGroupId", SqlDbType.Int) { Value = notificationGroupId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationOpenApplyStudent", ls_p);
        }
        public async Task<int> ApproveOpenApplyStudentNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
            //ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
            DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveOpenApplyStudent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> RejectOpenApplyStudentNotificationById(int loginUserId, int notificationGroupDetailId)
        {
            int result = -1;
            List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_RejectOpenApplyStudent", ls_p);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
            return result;
        }
        public async Task<int> ApproveMultiOpenApplyStudentNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string studentOpenApplyStudentDetailId in notificationGroupDetailIds.Split(','))
            {
                int studentOpenApplyStudentDetailIdOut = 0;
                int.TryParse(studentOpenApplyStudentDetailId.Trim(), out studentOpenApplyStudentDetailIdOut);
                if (studentOpenApplyStudentDetailIdOut > 0)
                {
                    result = await ApproveOpenApplyStudentNotificationById(loginUserId, studentOpenApplyStudentDetailIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
        #endregion

        #region OpenApply Parent
        public async Task<DataSet> GetNotificationOpenApplyParent(int notificationTypeId, int notificationGroupId, int notificationGroupDetailId)
        {
            List<SqlParameter> ls_p = new List<SqlParameter>();
            ls_p.Add(new SqlParameter("@NotificationTypeId", SqlDbType.Int) { Value = notificationTypeId });
            ls_p.Add(new SqlParameter("@NotificationGroupId", SqlDbType.Int) { Value = notificationGroupId });
            ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
            return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationOpenApplyParent", ls_p);
        }
        public async Task<int> ApproveOpenApplyParentNotificationById(int loginUserId, int NotificationGroupDetailId)
        {
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = NotificationGroupDetailId });
			//ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveOpenApplyParent", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
        public async Task<int> RejectOpenApplyParentNotificationById(int loginUserId, int NotificationGroupDetailId)
        {
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = NotificationGroupDetailId });
			//ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_RejectOpenApplyParent", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
        public async Task<int> ApproveMultiOpenApplyParentNotification(int loginUserId, string notificationGroupDetailIds)
        {
            int result = -1;
            foreach (string studentOpenApplyParentDetailId in notificationGroupDetailIds.Split(','))
            {
                int studentOpenApplyParentDetailIdOut = 0;
                int.TryParse(studentOpenApplyParentDetailId.Trim(), out studentOpenApplyParentDetailIdOut);
                if (studentOpenApplyParentDetailIdOut > 0)
                {
                    result = await ApproveOpenApplyParentNotificationById(loginUserId, studentOpenApplyParentDetailIdOut);
                    if (result == -1)
                        break;
                }
            }
            return result;
        }
		#endregion

		#region Withdraw Student
		public async Task<DataSet> GetNotificationWithdrawStudent(int notificationTypeId, int notificationGroupId, int notificationGroupDetailId)
		{
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@NotificationTypeId", SqlDbType.Int) { Value = notificationTypeId });
			ls_p.Add(new SqlParameter("@NotificationGroupId", SqlDbType.Int) { Value = notificationGroupId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
			return await _DbHelper.ExecuteDataProcedureAsync("sp_GetNotificationWithdrawStudent", ls_p);
		}
		public async Task<int> ApproveWithdrawStudentNotificationById(int loginUserId, int notificationGroupDetailId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
			//ls_p.Add(new SqlParameter("@ActionId", SqlDbType.Int) { Value = 3 });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_ApproveWithdrawStudent", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		public async Task<int> RejectWithdrawStudentNotificationById(int loginUserId, int notificationGroupDetailId)
		{
			int result = -1;
			List<SqlParameter> ls_p = new List<SqlParameter>();
			ls_p.Add(new SqlParameter("@LoginUserId", SqlDbType.Int) { Value = loginUserId });
			ls_p.Add(new SqlParameter("@NotificationGroupDetailId", SqlDbType.Int) { Value = notificationGroupDetailId });
			DataSet ds = await _DbHelper.ExecuteDataProcedureAsync("sp_RejectWithdrawStudent", ls_p);
			if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
				result = Convert.ToInt32(ds.Tables[0].Rows[0]["Result"]);
			return result;
		}
		public async Task<int> ApproveMultiWithdrawStudentNotification(int loginUserId, string notificationGroupDetailIds)
		{
			int result = -1;
			foreach (string studentWithdrawStudentDetailId in notificationGroupDetailIds.Split(','))
			{
				int studentWithdrawStudentDetailIdOut = 0;
				int.TryParse(studentWithdrawStudentDetailId.Trim(), out studentWithdrawStudentDetailIdOut);
				if (studentWithdrawStudentDetailIdOut > 0)
				{
					result = await ApproveWithdrawStudentNotificationById(loginUserId, studentWithdrawStudentDetailIdOut);
					if (result == -1)
						break;
				}
			}
			return result;
		}
		#endregion
	}
}
