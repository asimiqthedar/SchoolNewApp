DROP PROCEDURE IF EXISTS [SP_ParentReport]
GO

CREATE PROCEDURE [dbo].[SP_ParentReport]  
(  
	@ParentId int=0  
	,@AcademicYear int=0  
	,@StartDate datetime=null        
	,@EndDate datetime=null        
)  
AS
BEGIN 
	declare @PeriodFrom	datetime 
	declare @PeriodTo datetime 
	declare @AcademicYearName nvarchar(50)
	select top 1  @PeriodFrom	=PeriodFrom	,@PeriodTo	=PeriodTo	,@AcademicYearName=AcademicYear from tblSchoolAcademic
	where SchoolAcademicId=@AcademicYear

	--Get total applied fee, applied discount, management discount
	select 
	ParentId	,PeriodFrom	,PeriodTo
	,AcademicYear
	,FeeApplied=sum(FeeApplied)	
	,DiscountApplied=sum(DiscountApplied)	
	,AmountPaid	=0--sum(AmountPaid)
	,BalanceAmount=0--isnull(sum(FeeApplied),0)-isnull(sum(DiscountApplied),0)	-isnull(sum(AmountPaid),0)		
	into #vw_FeeStatementParenStudent
	from 
	(
		select 		
			vps.ParentId  
		   ,FeeApplied=feeamount  
		   ,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END  
		   ,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		   ,vps.PeriodFrom,vps.PeriodTo		,AcademicYear
		from
		vw_FeeStatementParenStudent vps 
		join tblSchoolAcademic t on vps.AcademicYearId=t.SchoolAcademicId
		where
		 (@AcademicYear is null OR vps.AcademicYearId=@AcademicYear)
		and ((@ParentId is null OR @ParentId =0 )OR vps.ParentId=@ParentId)
	)t
	group by ParentId	,PeriodFrom	,PeriodTo,AcademicYear

	--Opening record
	--Get total applied fee, applied discount, management discount
	select 
	ParentId
	,BalanceAmount=isnull(sum(FeeApplied),0)-isnull(sum(DiscountApplied),0)	-isnull(sum(AmountPaid),0)		
	into #vw_FeeStatementParenStudentOpening
	from 
	(
		select 
			ParentId  
		   ,FeeApplied=feeamount  
		   ,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END  
		   ,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		   ,PeriodFrom,PeriodTo		
		from vw_FeeStatementParenStudent  vps
		where cast( PeriodFrom as date)< cast( @PeriodFrom  as date)
		and ((@ParentId is null OR @ParentId =0 )OR vps.ParentId=@ParentId)
	)t
	group by ParentId	,PeriodFrom	,PeriodTo

	--get apid amount if date not passing then treat academic sleected date as start and end date
	if(@StartDate is not null)
		set @StartDate=@PeriodFrom

	if(@EndDate is not null)
		set @EndDate=@PeriodTo

	select
	ParentId	,AmountPaid=sum(AmountPaid),VatPaid=sum(VatPaid)
	into #TempParentPaymentPaid
	from 
	(
		SELECT   
			f.ParentId
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END  
			,VatPaid=isnull(i.TaxAmount,0)
		FROM tblFeeStatement f  
		join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'  
		where 
		(@StartDate  is null OR cast(i.InvoiceDate as date) >=cast(@StartDate as date) )
		AND (@EndDate  is null OR cast(i.InvoiceDate as date) <=cast(@EndDate as date) )
		and AcademicYearId=@AcademicYear
		and isnull(f.InvoiceNo,0)>0 
		and ((@ParentId is null OR @ParentId =0 )OR f.ParentId=@ParentId)
	)t
	group by ParentId

	--get Final Records
	select 
	par.ParentCode	,AcademicYear=isnull(a.AcademicYear,@AcademicYearName)
	,FeeApplied	=ISNULL( a.FeeApplied,0)	
	,DiscountApplied=ISNULL( a.DiscountApplied,0)	
	,AmountPaid=ISNULL( b.AmountPaid,0)	
	,VatPaid=ISNULL( b.VatPaid,0)
	,Balance=ISNULL( a.FeeApplied,0)	-ISNULL( a.DiscountApplied,0)	-ISNULL( b.AmountPaid,0)	
	,OpeningBalance=ISNULL( c.BalanceAmount,0)
	
	into #FinalRecord
	from 
	tblParent par
	left join 	#vw_FeeStatementParenStudent a on par.ParentId=a.ParentId
	left join 	#TempParentPaymentPaid b on a.ParentId=b.ParentId
	left join #vw_FeeStatementParenStudentOpening c on a.ParentId=c.ParentId
	where ((@ParentId is null OR @ParentId =0 )OR par.ParentId=@ParentId)

	SELECT 
		ParentCode= ' '  
		,AcademicYear ='Total'    
		,OpeningBalance=FORMAT(SUM(ISNULL(OpeningBalance,0)),'#,0.00')     
		,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')      
		,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')      
		,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')      
		,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')      
		,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')  
	from #FinalRecord
	union all

	select 
	 ParentCode=cast(ParentCode as nvarchar(100))	,AcademicYear	
	 ,OpeningBalance	=FORMAT(ISNULL(OpeningBalance,0),'#,0.00')
	 ,FeeApplied	=FORMAT(ISNULL(FeeApplied,0),'#,0.00')
	 ,DiscountApplied	=FORMAT(ISNULL(DiscountApplied,0),'#,0.00')
	 ,AmountPaid	=FORMAT(ISNULL(AmountPaid,0),'#,0.00')
	 ,VatPaid	=FORMAT(ISNULL(VatPaid,0),'#,0.00')
	 ,Balance=FORMAT(ISNULL(Balance,0),'#,0.00')
	from #FinalRecord

	DROP TABLE IF EXISTS #vw_FeeStatementParenStudent   
	DROP TABLE IF EXISTS #TempParentPaymentPaid
	DROP TABLE IF EXISTS #vw_FeeStatementParenStudentOpening   
	DROP TABLE IF EXISTS #FinalRecord

END  
GO
