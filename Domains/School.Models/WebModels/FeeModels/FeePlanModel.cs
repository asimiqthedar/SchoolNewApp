namespace School.Models.WebModels.FeeModels
{
	[Serializable]
    public class FeePlanModel
    {
        public long FeeStructureId { get; set; }
        public string AcademicYear { get; set; }
        public long FeeTypeId { get; set; }
        public string FeeTypeName { get; set; }
        public decimal FeeAmount { get; set; }
        public bool IsGradeWise { get; set; }

    }
}
