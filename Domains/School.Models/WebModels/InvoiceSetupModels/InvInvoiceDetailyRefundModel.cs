using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace School.Models.WebModels.InvoiceSetupModels
{
	public class InvInvoiceDetailyRefundModel : BaseInvoice
	{
		public long InvoiceRefNo { get; set; }
		//public string IqamaNumber { get; set; }
		//public string InvoiceSessionKey { get; set; }
		//public string SessionKey { get; set; }
		//public long InvoiceDetailId { get; set; }
		//public long InvoiceNo { get; set; }
		public string AcademicYear { get; set; }
		//public string InvoiceType { get; set; }
		public string Description { get; set; }
		public string ItemCode { get; set; }
		//public string StudentId { get; set; }

		//public string ParentId { get; set; }
		//public string StudentName { get; set; }
		//public string ParentName { get; set; }
		//public int? GradeId { get; set; }

		//public decimal? Discount { get; set; }
		public decimal Quantity { get; set; }
		//public decimal UnitPrice { get; set; }
		//public decimal? TaxableAmount { get; set; }
		//public decimal? TaxRate { get; set; }
		//public decimal? TaxAmount { get; set; }
		//public decimal ItemSubtotal { get; set; }

		public decimal? RefundableDiscount { get; set; }
		public decimal RefundableQuantity { get; set; }
		public decimal RefundableUnitPrice { get; set; }
		public decimal? RefundableTaxableAmount { get; set; }
		public decimal? RefundableTaxRate { get; set; }
		public decimal? RefundableTaxAmount { get; set; }
		public decimal RefundableItemSubtotal { get; set; }

		public decimal? RefundedDiscount { get; set; }
		public decimal RefundedQuantity { get; set; }
		public decimal RefundedUnitPrice { get; set; }
		public decimal? RefundedTaxableAmount { get; set; }
		public decimal? RefundedTaxRate { get; set; }
		public decimal? RefundedTaxAmount { get; set; }
		public decimal RefundedItemSubtotal { get; set; }

		public decimal? AvailableDiscount { get { return RefundableDiscount - RefundedDiscount; } }
		public decimal AvailableQuantity { get { return RefundableQuantity - RefundedQuantity; } }
		public decimal AvailableUnitPrice { get { return RefundableUnitPrice - RefundedUnitPrice; } }
		public decimal? AvailableTaxableAmount { get { return RefundableTaxableAmount - RefundedTaxableAmount; } }
		public decimal? AvailableTaxRate { get { return TaxRate; } }
		public decimal? AvailableTaxAmount { get { return RefundableTaxAmount - RefundedTaxAmount; } }
		public decimal AvailableItemSubtotal { get { return RefundableItemSubtotal - RefundedItemSubtotal; } }

		public long? InvoiceDetailRefId { get; set; }
		public bool? IsAdvance { get; set; }
	}
}
