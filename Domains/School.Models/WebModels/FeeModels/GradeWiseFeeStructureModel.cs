namespace School.Models.WebModels.FeeModels
{
	[Serializable]
	public class GradeWiseFeeStructureModel
	{
		public string FeeGradewiseId { get; set; }
		public string FirstAmount { get; set; }
		public string FirstDueDate { get; set; }
		public string SecondAmount { get; set; }
		public string SecondDueDate { get; set; }
		public string ThirdAmount { get; set; }
		public string ThirdDueDate { get; set; }
	}
}
