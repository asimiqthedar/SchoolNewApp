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
begin

	declare @PeriodFrom datetime   
	declare @PeriodTo datetime   
	declare @AcademicYearName nvarchar(50)  

	select top 1  @PeriodFrom =PeriodFrom ,@PeriodTo =PeriodTo ,@AcademicYearName=AcademicYear from tblSchoolAcademic  
	where SchoolAcademicId=@AcademicYear 
 
	select SchoolAcademicId into #tblSchoolAcademicOpening from  tblSchoolAcademic where PeriodFrom<@PeriodFrom

	--selected year : get applied , discount,return
	select
	FeeStatementType
	,ParentId
	,AcademicYearId
	,InvoiceNo	,InvoiceDate
	,FeeAmount	,CurrentDiscountApplied=PaidAmount
	into #CurrentFeeAppliedWithDiscount
	from tblFeeStatement
	where AcademicYearId=@AcademicYear 
	and InvoiceNo is null
	AND ((@ParentId is null OR @ParentId =0 )OR ParentId=@ParentId)

	--selected year : Paid Amount	
	select
	t.FeeStatementType ,t.ParentId,t.InvoiceNo,t.InvoiceDate
	,FeeAmount=0,CurrentPaidAndReturnAmount=sum(TaxableAmount)
	,VatPaid=sum(VatPaid)
	,Status
	into #CurrentFeePaid	
	from 
	(
		select 
			FeeStatementType='Fee Paid'
			,d.ParentId
			,AcademicYearId=d.AcademicYear
			,d.InvoiceNo	
			,i.InvoiceDate
			,FeeAmount=0
			,TaxableAmount=d.TaxableAmount
			,VatPaid=d.TaxAmount
			,i.Status
		from INV_InvoiceSummary i
		join INV_InvoiceDetail d 
		on i.InvoiceNo=d.InvoiceNo
		where 
		i.Status='posted'
		AND 
		d.InvoiceType='Tuition Fee'
		
		AND 
		(
			(
				IsAdvance=0
				AND 
				(cast(i.InvoiceDate as date) >=cast(@PeriodFrom as date) )  
				AND (cast(i.InvoiceDate as date) <=cast(@PeriodTo as date) ) 
			)
			OR
			(
				IsAdvance=1
				and AcademicYear=@AcademicYear
			)
		)
		AND ((@ParentId is null OR @ParentId =0 )OR d.ParentId=@ParentId)
		
	)t
	group by t.FeeStatementType ,t.ParentId,t.InvoiceNo,t.InvoiceDate,Status

	--Opening year : get applied , discount,return
	select
		FeeStatementType
		,ParentId
		,AcademicYearId
		,InvoiceNo	,InvoiceDate
		,FeeAmount	,OpeningDiscount=PaidAmount
	into #OpeningFeeAppliedWithDiscount
	from tblFeeStatement
	where AcademicYearId in (select * from #tblSchoolAcademicOpening) 
	and InvoiceNo is null
	AND ((@ParentId is null OR @ParentId =0 )OR ParentId=@ParentId)

	--Opening year : Paid Amount
	select
		t.FeeStatementType ,t.ParentId,t.InvoiceNo,t.InvoiceDate
		,FeeAmount	=0	,OpeningPaidAndReturnAmount=sum(TaxableAmount)
	into #OpeningFeePaidNonAdvance
	from
	(
		select 
			FeeStatementType='Fee Paid'
			,d.ParentId
			,AcademicYearId=d.AcademicYear
			,d.InvoiceNo	
			,i.InvoiceDate
			,FeeAmount=0
			,TaxableAmount=d.TaxableAmount
			,VatPaid=d.TaxAmount
		from INV_InvoiceSummary i
		join INV_InvoiceDetail d 
		on i.InvoiceNo=d.InvoiceNo
		where 
		i.Status='posted'
		AND d.InvoiceType='Tuition Fee'
		--AND (cast(i.InvoiceDate as date) <cast(@PeriodFrom as date) )  
		AND ((@ParentId is null OR @ParentId =0 )OR d.ParentId=@ParentId)

		AND 
		(
			(
				IsAdvance=0
				AND 
				cast(i.InvoiceDate as date) <cast(@PeriodFrom as date)
			)
			OR
			(
				IsAdvance=1
				and AcademicYear in (select * from #tblSchoolAcademicOpening)
			)
		)
		--and d.AcademicYear in (select * from #tblSchoolAcademicOpening)
	)t
	group by 	t.FeeStatementType ,t.ParentId,t.InvoiceNo,t.InvoiceDate
	
	---Start: Finalize record
	select  ParentId,FeeAmount=sum(FeeAmount), OpeningPaidAndReturnAmount=sum(OpeningPaidAndReturnAmount) 
	into #OpeningFeePaidNonAdvanceFinal
	from #OpeningFeePaidNonAdvance 
	--where ParentId=1 
	group by ParentId

	select  ParentId,FeeAmount=sum(FeeAmount), OpeningDiscount=sum(OpeningDiscount) 
	into #OpeningFeeAppliedWithDiscountFinal
	from #OpeningFeeAppliedWithDiscount 
	--where ParentId=1 
	group by ParentId

	select  ParentId,VatPaid=sum(VatPaid),FeeAmount=sum(FeeAmount), CurrentPaidAndReturnAmount=sum(CurrentPaidAndReturnAmount)
	into #CurrentFeePaidFinal
	from #CurrentFeePaid 
	--where ParentId=1 
	group by ParentId

	select  ParentId,FeeAmount=sum(FeeAmount), CurrentDiscountApplied=sum(CurrentDiscountApplied) 
	into #CurrentFeeAppliedWithDiscountFinal
	from #CurrentFeeAppliedWithDiscount 
	--where ParentId=1 
	group by ParentId

	---End: Finalize record

	----select '#OpeningFeePaidNonAdvanceFinal'as AA, * from #OpeningFeePaidNonAdvanceFinal
	------where parentid=1  
	----order by ParentId

	----select '##OpeningFeeAppliedWithDiscountFinal'as AA,  * from #OpeningFeeAppliedWithDiscountFinal    
	------where parentid=1  
	----order  by ParentId

	----select '##CurrentFeePaidFinal'as AA,  * from #CurrentFeePaidFinal   
	------where parentid=1  
	----order  by ParentId

	----select '##CurrentFeeAppliedWithDiscountFinal'as AA,  * from #CurrentFeeAppliedWithDiscountFinal    
	----where parentid=1 
	----order  by ParentId

	----select '#OpeningFeeAppliedWithDiscount' as AA,  * from #OpeningFeeAppliedWithDiscount
	----select '#OpeningFeePaidNonAdvance' as AA, * from #OpeningFeePaidNonAdvance

	----select '#OpeningFeePaidNonAdvance' as AA, * from #OpeningFeePaidNonAdvance where ParentId=1
	----select '#OpeningFeeAppliedWithDiscount' as AA, * from #OpeningFeeAppliedWithDiscount where ParentId=1
	----select '#CurrentFeePaid' as AA, * from #CurrentFeePaid where ParentId=1
	----select '#CurrentFeeAppliedWithDiscount' as AA, * from #CurrentFeeAppliedWithDiscount where ParentId=1


	select 
		ParentId	,ParentCode	,FatherName
		,Opening=OpeningFeeAmount	-OpeningPaidAndReturnAmount	-OpeningDiscount	
		,OpeningFeeAmount	,OpeningPaidAndReturnAmount	,OpeningDiscount	

		,CurrentAmount=CurrentFeeAmount	-CurrentPaidAndReturnAmount	-CurrentDiscountApplied
		,CurrentFeeAmount	,CurrentPaidAndReturnAmount	,CurrentDiscountApplied
		,VatPaid
		,Balance=CurrentFeeAmount	-CurrentPaidAndReturnAmount	-CurrentDiscountApplied+ (OpeningFeeAmount	-OpeningPaidAndReturnAmount	-OpeningDiscount	)

	Into #finalRecord
	from 
	(
		select 
			par.ParentId	,par.ParentCode	,par.FatherName
			,OpeningFeeAmount=isnull(a.FeeAmount,0)+isnull(b.FeeAmount,0),OpeningPaidAndReturnAmount=isnull(a.OpeningPaidAndReturnAmount,0)
			,OpeningDiscount=isnull(b.OpeningDiscount,0)
			,CurrentFeeAmount=isnull(c.FeeAmount,0)+isnull(d.FeeAmount,0)	,CurrentPaidAndReturnAmount=isnull(c.CurrentPaidAndReturnAmount,0)
			,CurrentDiscountApplied=isnull(d.CurrentDiscountApplied,0)
			,c.VatPaid
		from
		 tblParent par  
		 left join #OpeningFeePaidNonAdvanceFinal a on par.ParentId=a.ParentId  
		 left join #OpeningFeeAppliedWithDiscountFinal b on par.ParentId=b.ParentId  
		 left join #CurrentFeePaidFinal c on par.ParentId=c.ParentId  
		 left join #CurrentFeeAppliedWithDiscountFinal d on par.ParentId=d.ParentId 
		 where ((@ParentId is null OR @ParentId =0 )OR par.ParentId=@ParentId)
	)t

	select 
		ParentId	='',ParentCode	='',FatherName	=''
		,AcademicYear ='Total'      
		,OpeningBalance	=sum(Opening	),
		--OpeningFeeAmount=	sum(OpeningFeeAmount	),
		--OpeningPaidAndReturnAmount=	sum(OpeningPaidAndReturnAmount	),
		--OpeningDiscount=	sum(OpeningDiscount	),

		--CurrentAmount=	sum(CurrentAmount	),
		FeeApplied=	sum(CurrentFeeAmount	),
		AmountPaid=	sum(CurrentPaidAndReturnAmount	),
		DiscountApplied=sum(CurrentDiscountApplied	)
		,VatPaid=sum(isnull(VatPaid,0))
		,Balance=sum(Balance)
	from 
	#finalRecord

	union all
	select 
		ParentId,ParentCode ,FatherName
		,AcademicYear=@AcademicYearName
		,OpeningBalance=Opening
		--,OpeningFeeAmount,OpeningPaidAndReturnAmount,OpeningDiscount
	
		--,CurrentAmount
		,FeeApplied=CurrentFeeAmount
		,AmountPaid=CurrentPaidAndReturnAmount
		,DiscountApplied=CurrentDiscountApplied
		,VatPaid=isnull(VatPaid,0)
		,Balance
	
	from 
	#finalRecord
	
	drop table #OpeningFeePaidNonAdvanceFinal
	drop table #OpeningFeeAppliedWithDiscountFinal
	drop table #CurrentFeePaidFinal
	drop table #CurrentFeeAppliedWithDiscountFinal

	drop table #OpeningFeePaidNonAdvance
	drop table #OpeningFeeAppliedWithDiscount
	drop table #CurrentFeePaid
	drop table #CurrentFeeAppliedWithDiscount

	drop table #tblSchoolAcademicOpening
	drop table #finalRecord

end
Go