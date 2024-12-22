CREATE PROCEDURE [dbo].[sp_GetInvoiceDataYearly]
AS
BEGIN

	declare @PeriodFrom date
	declare @PeriodTo date
	select top 1 
	@PeriodFrom=cast(PeriodFrom as date)
	,@PeriodTo=cast(PeriodTo as date)
	from tblSchoolAcademic where IsActive=1 and IsDeleted=0
	and cast(getdate() as date) between cast(PeriodFrom as date)  and cast(PeriodTo as date)

    SELECT 
    DATEPART(YEAR, CAST(UpdateDate AS DATE)) AS AYear, 
    DATENAME(MONTH, CAST(UpdateDate AS DATE)) AS [MonthName],
    SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyEntranceRevenue,
    SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyUniformRevenue,
    SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyTuitionRevenue
FROM INV_InvoiceDetail
where  cast(UpdateDate as date) between cast(@PeriodFrom as date)  and cast(@PeriodTo as date) 
GROUP BY 
    DATEPART(YEAR, CAST(UpdateDate AS DATE)), 
    DATENAME(MONTH, CAST(UpdateDate AS DATE))
END
go
