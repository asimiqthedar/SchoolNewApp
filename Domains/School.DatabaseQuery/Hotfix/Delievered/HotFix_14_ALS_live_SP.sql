
ALTER proc [dbo].[sp_getAdminDashboardData]
as
begin
	select  count(1) as TotalStudent
	from tblStudent

	select  count(1) as TotalParent from tblParent

	select 
	case when GenderId=1 then 'Male' else 'Female' end as Gender, GradeName as KeyName, count(1) as KeyValue
	from tblStudent stu
	inner join tblGradeMaster grade
	on stu.GradeId=grade.GradeId

	group by GradeName,GenderId

	select 
	AdmissionYear as KeyName, count(1) as KeyValue
	from tblStudent stu
	group by AdmissionYear

	SELECT 		isnull(SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN isnull(ItemSubtotal,0) ELSE 0 END),0) AS MonthlyEntranceRevenue,		isnull(SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN isnull(ItemSubtotal,0) ELSE 0 END),0) AS MonthlyUniformRevenue,		isnull(SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN isnull(ItemSubtotal,0) ELSE 0 END),0) AS MonthlyTuitionRevenue	FROM INV_InvoiceDetail	WHERE DATEPART(YEAR, CAST(UpdateDate AS DATE)) = DATEPART(YEAR, CAST(GETDATE() AS DATE))		AND DATEPART(MONTH, CAST(UpdateDate AS DATE)) = DATEPART(MONTH, CAST(GETDATE() AS DATE))
end
go

ALTER PROCEDURE [dbo].[sp_GetInvoiceDataYearly]
AS
BEGIN

	DECLARE @PeriodFrom DATE
	DECLARE @PeriodTo DATE
	SELECT TOP 1 
		@PeriodFrom=CAST(PeriodFrom AS DATE)
		,@PeriodTo=CAST(PeriodTo AS DATE)
	FROM tblSchoolAcademic 
	WHERE IsActive=1 and IsDeleted=0
		AND CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)  and CAST(PeriodTo AS DATE)

    SELECT 		DATEPART(YEAR, CAST(UpdateDate AS DATE)) AS AYear, 		DATENAME(MONTH, CAST(UpdateDate AS DATE)) AS [MonthName],		SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyEntranceRevenue,		SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyUniformRevenue,		SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyTuitionRevenue	FROM INV_InvoiceDetail	where  CAST(UpdateDate AS DATE) BETWEEN CAST(@PeriodFrom AS DATE) AND CAST(@PeriodTo AS DATE) 	GROUP BY 		DATEPART(YEAR, CAST(UpdateDate AS DATE)), 		DATENAME(MONTH, CAST(UpdateDate AS DATE))
END
go


ALTER PROCEDURE [dbo].[SP_GetFeeAmount]      
	@AcademicYearId bigint      
	,@StudentId bigint,      
	@InvoiceTypeName nvarchar(50)      
as      
    
begin      
	declare @IsStaffMember bit=0;      
	declare @GradeId int=0;    
	declare @TotalAcademicYearPaid decimal(18,2)=0    	

	 DECLARE @PeriodFrom DATE  
	 DECLARE @PeriodTo DATE  

	 SELECT TOP 1   
	  @PeriodFrom=CAST(PeriodFrom AS DATE)  
	  ,@PeriodTo=CAST(PeriodTo AS DATE)  
	 FROM tblSchoolAcademic   
	 WHERE IsActive=1 and IsDeleted=0  
	  AND CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)  and CAST(PeriodTo AS DATE)  

	if(@studentId>0)      
	begin      
		select top 1        
			@IsStaffMember= case when p.IsFatherStaff=1 OR p.IsMotherStaff=1 then 1 else 0 end      
			,@GradeId=s.GradeId    
		from      
		[dbo].[tblParent] p      
		join [dbo].[tblStudent] s on p.ParentId=s.ParentId      
		where StudentId= @studentId      
	end
    
	if(@InvoiceTypeName like '%Tuition%')    
	begin
		select  
			@TotalAcademicYearPaid=isnull(sum( UnitPrice),0)     
		from INV_InvoiceDetail    
		where StudentId=@StudentId and AcademicYear=@AcademicYearId    
		and InvoiceType like '%Tuition%'    
		and IsDeleted=0

		select top 1     
			ftd.FeeTypeDetailId    
			,ftd.FeeTypeId    
			,ftd.AcademicYearId    
			,ftd.GradeId    
			,inv.FeeAmount as TermFeeAmount    
			,ftd.IsActive    
			,ftd.IsDeleted    
			,ftd.UpdateDate    
			,ftd.UpdateBy    
			,inv.FeeAmount as StaffFeeAmount    
			,IsStaffMember=@IsStaffMember     
			,FinalFeeAmount=inv.FeeAmount-  @TotalAcademicYearPaid
		from [dbo].[tblFeeTypeDetail] ftd      
		join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId      
		join  [dbo].[tblStudentFeeDetail] inv on ftm.FeeTypeId=inv.FeeTypeId     
		and inv.StudentId=@StudentId    
		and ftd.AcademicYearId=inv.AcademicYearId    
		where ftd.AcademicYearId=@academicYearId      
		and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'
	end    
	else     
	begin
		select top 1 ftd.*,IsStaffMember=@IsStaffMember ,
		FinalFeeAmount=case when @IsStaffMember=1 then StaffFeeAmount else TermFeeAmount end
		from [dbo].[tblFeeTypeDetail] ftd      
		join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId      
		where AcademicYearId=@academicYearId      
		and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'
	end    
end
go


create proc SP_MonthlyUniformStatementParentStudent
(
 @parentId int=0
 ,@parentName nvarchar(100)=null
 ,@StudentId int=0
 ,@StudentName nvarchar(100)=null
 ,@AcademicYearId int=0
 ,@PaymentType nvarchar(100)=null
 ,@StartDate datetime=null
 ,@EndDate datetime=null
)
as
begin
	---student /parent monthly collection
	--declare @parentId int
	--declare @parentName nvarchar(100)
	--declare @StudentId int
	--declare @StudentName nvarchar(100)
	--declare @AcademicYearId int
	--declare @PaymentType nvarchar(100)
	--declare @StartDate datetime=null
	--declare @EndDate datetime=null

	set @parentName='%'+@parentName+'%'
	set @StudentName='%'+@StudentName+'%'

	select 
	ParentId	,ParentName	,NameMonth	,NameYear ,TaxableAmount=sum(TaxableAmount)	,TaxAmount	=sum(TaxAmount),ItemSubtotal	=sum(ItemSubtotal)
	from
	(
		select 
			ParentId=isnull(invDet.ParentId,0)
			,ParentName=isnull(invDet.ParentName,'')
			,invDet.TaxableAmount	
			,invDet.TaxAmount	
			,invDet.ItemSubtotal
			,NameMonth=DATENAME(month, invSum.InvoiceDate)
			,NameYear=DATENAME(year, invSum.InvoiceDate)
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet 
		on invSum.InvoiceNo=invDet.InvoiceNo
		where 
		invDet.InvoiceType like '%uniform%'
		and (
			(@parentId=0 OR invDet.ParentId=@parentId)
			OR (@parentId=0 OR invDet.StudentId=@parentId)
			OR (@AcademicYearId=0 OR invDet.AcademicYear=@parentId)
			OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)
			OR ((@StudentName is null OR @StudentName='' ) OR invDet.ParentName like @StudentName)
			--OR 
			--(
			--	(
			--		(@StartDate is null OR @StartDate='' )) OR cast(invSum.InvoiceDate as date)>= cast(@StartDate as date)
			--)
		)
	)t
	--order by ParentId	,ParentName	,NameMonth	,NameYear 
	group by ParentId	,ParentName	,NameMonth	,NameYear 
end
go

create proc [dbo].[SP_MonthlyStatementParentStudent]
(
 @parentId int=0
 ,@parentName nvarchar(100)=null
 ,@StudentId int=0
 ,@StudentName nvarchar(100)=null
 ,@AcademicYearId int=0
 ,@PaymentType nvarchar(100)=null
 ,@StartDate datetime=null
 ,@EndDate datetime=null
)
as
begin
	---student /parent monthly collection
	--declare @parentId int
	--declare @parentName nvarchar(100)
	--declare @StudentId int
	--declare @StudentName nvarchar(100)
	--declare @AcademicYearId int
	--declare @PaymentType nvarchar(100)
	--declare @StartDate datetime=null
	--declare @EndDate datetime=null

	set @parentName='%'+@parentName+'%'
	set @StudentName='%'+@StudentName+'%'

	select 
	ParentId	,ParentName	,NameMonth	,NameYear ,TaxableAmount=sum(TaxableAmount)	,TaxAmount	=sum(TaxAmount),ItemSubtotal	=sum(ItemSubtotal)
	from
	(
		select 
			ParentId=isnull(invDet.ParentId,0)
			,ParentName=isnull(invDet.ParentName,'')
			,invDet.TaxableAmount	
			,invDet.TaxAmount	
			,invDet.ItemSubtotal
			,NameMonth=DATENAME(month, invSum.InvoiceDate)
			,NameYear=DATENAME(year, invSum.InvoiceDate)
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet 
		on invSum.InvoiceNo=invDet.InvoiceNo
		where 
		(
			(@parentId=0 OR invDet.ParentId=@parentId)
			OR (@parentId=0 OR invDet.StudentId=@parentId)
			OR (@AcademicYearId=0 OR invDet.AcademicYear=@parentId)
			OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)
			OR ((@StudentName is null OR @StudentName='' ) OR invDet.ParentName like @StudentName)
			--OR 
			--(
			--	(
			--		(@StartDate is null OR @StartDate='' )) OR cast(invSum.InvoiceDate as date)>= cast(@StartDate as date)
			--)
		)
	)t
	group by ParentId	,ParentName	,NameMonth	,NameYear 
end
go