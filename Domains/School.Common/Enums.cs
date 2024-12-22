namespace School.Common
{
	public enum AppRole
	{
		Admin = 1,
		Student = 2,
		Parent = 3,
		Teacher = 4
	}
	public enum AppDropdown
	{
		Role = 1,
		CostCenter = 2,
		Gender = 3,
		Grade = 4,
		Country = 5,
		DocumentType = 6,
		Parent = 7,
		Section = 8,
		StudentStatus = 9,
		Term = 10,
		Branch = 11,
		AcadmicYear = 12,
		FeeType = 13,
		DiscountRule = 14,
		Student = 15,
		PaymentMethodCategory = 16,
		AllStudentStatus = 17,
	}

	public enum DocFor
	{
		Parent = 1,
		Student = 2
	}
	public enum ConfigTemplate
	{
		InvoiceEmail = 1,
		ParentStatement = 2,
		ParentStatementSummary = 3,
        ParentStatementSummaryGov = 4,
		ParentStatementSummaryGovAr = 5,

	}
}
