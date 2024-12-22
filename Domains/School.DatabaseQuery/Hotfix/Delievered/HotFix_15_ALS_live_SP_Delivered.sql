CREATE PROCEDURE [dbo].sp_CSVInvoiceExport    
 @InvoiceId bigint = 0,                
 @Status nvarchar(50) = NULL,                
 @InvoiceDateStart date = NULL,                
 @InvoiceDateEnd date = NULL,                
 @InvoiceType nvarchar(50) = NULL,                
 @InvoiceNo nvarchar(50) = NULL,                
 @ParentCode nvarchar(50) = NUll,                
 @ParentName nvarchar(400) = NULL,        
 @FatherMobile nvarchar(200) = NULL      
 AS                            
BEGIN      
EXEC sp_GetInvoice    
 @InvoiceId    
 ,@Status    
 ,@InvoiceDateStart    
 ,@InvoiceDateEnd    
 ,@InvoiceType    
 ,@InvoiceNo    
 ,@ParentCode    
 ,@ParentName    
 ,@FatherMobile     
END    
GO

USE [ALS_LIVE]
GO
/***** Object:  StoredProcedure [dbo].[SP_MonthlyUniformStatementParentStudent]    Script Date: 20-08-2024 15:39:23 *****/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER proc [dbo].[SP_MonthlyUniformStatementParentStudent]
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
GO