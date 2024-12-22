namespace School.Models.WebModels.DashboardModels
{
    public class AdminDashboardModel
    {
        public AdminDashboardModel() { }
        public int TotalStudent { get; set; }
        public int TotalParent { get; set; }
        public string MonthlyUniformRevenue { get; set; }
        public string MonthlyEntranceRevenue { get; set; }
        public string MonthlyTutitionRevenue { get; set; }

        public string TotalYearlyAppliedFee { get; set; }
        public string YearlyEntranceRevenue { get; set; }
        public string YearlyUniformRevenue { get; set; }
        public string YearlyTuitionRevenue { get; set; }

        public List<ModelSeries> YearWiseStudent { get; set; }
        public List<GenderModelSeries> GradeWiseStudent { get; set; }

        public List<InvoiceDataModel> InvoiceWiseData { get; set; }
        public List<CostCenterRevenueModel> CostRevenueData { get; set; }
        public List<GradeRevenueModel> GradeRevenueData { get; set; }
        public List<StatusModel> StudentStatus { get; set; }

    }
}