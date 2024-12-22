CREATE proc sp_reportStudentStatement
	@AcademicYearId int
	,@ParentId int
	,@StudentId int
as
begin

	declare @AcademicYear_PeriodFrom	datetime
	declare @AcademicYear_PeriodTo datetime
	declare @AcademicYear nvarchar(500)
	select top 1 
		@AcademicYear=AcademicYear, @AcademicYear_PeriodFrom=PeriodFrom, @AcademicYear_PeriodTo=PeriodTo 
	from tblSchoolAcademic where SchoolAcademicId=@AcademicYearId

	select * into #Previous_tblSchoolAcademic from tblSchoolAcademic where cast(PeriodTo as date)<cast(@AcademicYear_PeriodFrom as date)

	select StudentId into #StudentTable from tblStudent where (StudentId =@StudentId OR ParentId=@ParentId)

	---- Student Opening Fees amount
	select 
		StudentId,	RecordDate,	FeeTypeName,FeeAmount=SUM(FeeAmount	),PaidAmount=SUM(PaidAmount)
	into #StudentOpeningFeesamount
	from
	(
		select 
			StudentId, '' as RecordDate, 'TUITION FEE -OPENING BALANCE' as FeeTypeName, FeeAmount, 0 as PaidAmount
		from tblStudentFeeDetail 
		where StudentId in (select StudentId from #StudentTable) 
		and AcademicYearId in (select SchoolAcademicId from #Previous_tblSchoolAcademic) 
		and IsActive=1 
		and IsDeleted=0
	)t
	group by 	StudentId,	RecordDate,	FeeTypeName

	----Student Opening Paid Amount
	select 
		StudentId,	RecordDate,	FeeTypeName,FeeAmount=SUM(FeeAmount	),PaidAmount=SUM(PaidAmount)
	into #StudentOpeningPaidamount
	from
	(
		SELECT
			StudentId, '' as RecordDate, 'TUITION FEE -OPENING BALANCE' as FeeTypeName, 0 as FeeAmount,
			TaxableAmount=case when invs.InvoiceType='Invoice' then invd.TaxableAmount else (invd.TaxableAmount*-1) end, 
			0 as PaidAmount
		from INV_InvoiceDetail invd
		join INV_InvoiceSummary invs on invd.InvoiceNo=invs.InvoiceNo
		where StudentId in (select StudentId from #StudentTable) 
		and AcademicYear in (select SchoolAcademicId from #Previous_tblSchoolAcademic)
		and invd.InvoiceType='Tuition Fee'
	)t
	group by 	StudentId,	RecordDate,	FeeTypeName
	
	
	---- Student Current Fees amount
	select 
		StudentId,	InvoiceNo,''as PaymentMethod,RecordDate,	FeeTypeName,FeeAmount=SUM(FeeAmount	),PaidAmount=SUM(PaidAmount)
	into #StudentCurrentFeesamount
	from
	(
		select 
			StudentId,''as InvoiceNo, UpdateDate as RecordDate, 'TUITION FEE -APPLY' as FeeTypeName, FeeAmount, 0 as PaidAmount
		from tblStudentFeeDetail 
		where StudentId in (select StudentId from #StudentTable) 
		and AcademicYearId in (@AcademicYearId) 
		and IsActive=1 
		and IsDeleted=0
	)t
	group by 	StudentId,	RecordDate,	FeeTypeName,InvoiceNo

	----Student Current Paid Amount
	select 
		StudentId,InvoiceNo,PaymentMethod,	RecordDate,	FeeTypeName,FeeAmount=SUM(FeeAmount	),PaidAmount=SUM(PaidAmount)
	into #StudentCurrentPaidamount
	from
	(
		SELECT
			StudentId,invs.InvoiceNo, invd.UpdateDate as RecordDate, 
			FeeTypeName=case when invs.InvoiceType='Invoice' then 'TUITION FEE' else 'TUITION FEE REFUND' end
			,0 as FeeAmount
			,PaidAmount=case when invs.InvoiceType='Invoice' then invd.TaxableAmount else (invd.TaxableAmount*-1) end
			,PaymentMethod= 
				(select REPLACE(STUFF(CAST((
                    SELECT   ', ' +CAST(c.PaymentMethod AS VARCHAR(MAX))
                    FROM ( 
				 SELECT distinct scm.PaymentMethod    
					 FROM INV_InvoicePayment AS scm      
					 WHERE scm.InvoiceNo = invs.InvoiceNo      
				  ) c
				FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')) 
		from INV_InvoiceDetail invd
		join INV_InvoiceSummary invs on invd.InvoiceNo=invs.InvoiceNo
		where StudentId in (select StudentId from #StudentTable) 
		and AcademicYear in (@AcademicYearId)
		and invd.InvoiceType='Tuition Fee'
	)t
	group by 	StudentId,	RecordDate,	FeeTypeName,InvoiceNo,PaymentMethod


	declare @OpeningBalance decimal(18,2)=0
	declare @TotalFeeAmount decimal(18,2)=0
	declare @TotalPaidAmount decimal(18,2)=0

	select @TotalFeeAmount=sum(FeeAmount) from #StudentOpeningFeesamount
	select @TotalPaidAmount=sum(PaidAmount) from #StudentOpeningPaidamount

	set @OpeningBalance=@TotalFeeAmount-@TotalPaidAmount

	select 
		ROW_NUMBER() over(order by RecordDate) as RN,
		StudentId,	InvoiceNo,PaymentMethod,RecordDate,	FeeTypeName,FeeAmount,PaidAmount,BalanceAmount
	into #FinalCurrentRecord
	from
	(
		select StudentId,	InvoiceNo,PaymentMethod,RecordDate,	FeeTypeName,FeeAmount,PaidAmount,BalanceAmount= isnull(FeeAmount,0)- isnull(PaidAmount,0) from #StudentCurrentFeesamount
		union all
		select StudentId,	InvoiceNo,PaymentMethod,RecordDate,	FeeTypeName,FeeAmount,PaidAmount,BalanceAmount= isnull(FeeAmount,0)-isnull(PaidAmount,0) from  #StudentCurrentPaidamount
	)t

	if exists(select 1 from #FinalCurrentRecord)
	begin	
		select StudentId,StudentName,InvoiceNo,PaymentMethod,AcademicYear,	RecordDate=CONVERT(varchar, RecordDate, 34),	FeeTypeName,FeeAmount,PaidAmount,BalanceAmount=isnull(BalanceAmount,0) from 
		(
			select 0 as StudentId,'' as StudentName,'' as InvoiceNo,'' as PaymentMethod,'' as AcademicYear,isnull(@AcademicYear_PeriodFrom,getdate()) as RecordDate,	'TUITION FEE -OPENING BALANCE' as FeeTypeName,0 as FeeAmount, 0 as PaidAmount,
			ISNULL(@OpeningBalance,0) as BalanceAmount
		
		union all

			select fr.StudentId, stu.StudentName,fr.InvoiceNo,fr.PaymentMethod,@AcademicYear as AcademicYear,	fr.RecordDate,	fr.FeeTypeName,fr.FeeAmount,fr.PaidAmount,
			BalanceAmount=ISNULL(Fr.BalanceAmount,0)+ISNULL(se.BalanceAmount,0) + ISNULL(@OpeningBalance,0)
	
			from #FinalCurrentRecord fr
			left join #FinalCurrentRecord se on fr.RN=se.RN-1
			join tblStudent stu on fr.StudentId=stu.StudentId
		)t
		ORDER BY StudentId,RecordDate
	end
	else if(ISNULL(@OpeningBalance,0)>0)
	begin
		select 0 as StudentId, '' as StudentName,'' as InvoiceNo,'' as PaymentMethod,'' as AcademicYear,isnull(@AcademicYear_PeriodFrom,getdate()) as RecordDate,	'TUITION FEE -OPENING BALANCE' as FeeTypeName,0 as FeeAmount, 0 as PaidAmount,
			ISNULL(@OpeningBalance,0) as BalanceAmount
	end
	else
	begin
	select top 0 fr.StudentId, '' as StudentName,fr.InvoiceNo,fr.PaymentMethod,@AcademicYear as AcademicYear,	fr.RecordDate,	fr.FeeTypeName,fr.FeeAmount,fr.PaidAmount,
			BalanceAmount=ISNULL(Fr.BalanceAmount,0) + ISNULL(@OpeningBalance,0)
	
			from #FinalCurrentRecord fr
	end
	

	drop table #FinalCurrentRecord
	drop table #Previous_tblSchoolAcademic
	drop table #StudentTable
	drop table #StudentOpeningFeesamount
	drop table #StudentOpeningPaidamount
	drop table #StudentCurrentFeesamount
	drop table #StudentCurrentPaidamount
END
GO

CREATE PROCEDURE [dbo].[sp_CSVStudentStatement]  
	@AcademicYearId int
	,@ParentId int
	,@StudentId int
AS    
BEGIN    
	exec sp_reportStudentStatement @AcademicYearId 	,@ParentId 	,@StudentId 
END
GO