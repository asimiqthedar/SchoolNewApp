namespace School.Models.WebModels.DiscountModels
{
	public class DiscountModel
    {
        public int DiscountId { get; set; }
        public int ChildrenNo { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal StaffDiscountPercent { get; set; }
    }
}
