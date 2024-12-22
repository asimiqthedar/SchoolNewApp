namespace School.Models.WebModels.DashboardModels
{
	public class ParentDashboardModel
	{
		public ParentDashboardModel() { }

		public List<ParentYearwiseFeeInfoModel> ParentYearwiseFeeInfo { get; set; }
		public List<ParentMonthwiseFeeInfoModel> ParentMonthwiseFeeInfo { get; set; }
		public TotalParentFeeInfoModel TotalParentFeeInfo { get; set; }

	}
}