namespace School.Models.WebModels.GradeModels
{
	public class GradeFilterModel
    {
        public GradeFilterModel()
        {
            FilterIsActive = true;
        }
        public string FilterSearch { get; set; }
        public int FilterCostCenterId { get; set; }
        public int FilterGenderTypeId { get; set; }
        public bool FilterIsActive { get; set; }
    }
}
