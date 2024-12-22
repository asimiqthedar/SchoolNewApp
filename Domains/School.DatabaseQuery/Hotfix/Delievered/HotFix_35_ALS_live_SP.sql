DROP PROCEDURE IF EXISTS [SP_GeneralReport]
GO

CREATE PROCEDURE  [dbo].[SP_GeneralReport]    
(    
  @AcademicYear int=0    
 ,@CostCenter int=0    
 ,@Grade int=0    
 ,@Gender int=0    
)    
AS    
BEGIN  
	SELECT 
		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
	INTO #tempFeeStatement
	FROM 
	(
		SELECT 
			InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId
			,FeeApplied=feeamount
	
		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement 
	)t

	SELECT 
		sa.AcademicYear	
		,CostCenter=cc.CostCenterName	
		,Grade=gm.GradeName
		,Gender=gtm.GenderTypeName	
		,par.ParentCode
		,stu.StudentCode
		,a.FeeApplied
		,a.DiscountApplied
		,a.AmountPaid
		,VatPaid=0
		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 
	INTO #finalResult
	FROM #tempFeeStatement a
	INNER JOIN tblGradeMaster gm 
		ON a.GradeId=gm.GradeId
	JOIN tblParent par 
		ON a.ParentId=par.ParentId
	JOIN tblStudent stu 
		ON a.StudentId=stu.StudentId
	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 
	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    

	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND gm.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE gm.CostCenterId END       
   AND a.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE a.GradeId END       
   AND stu.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE stu.GenderId END      

	SELECT 
		AcademicYear	
		,CostCenter	
		,Grade
		,Gender		
		,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')
		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')
		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')
		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')
		,Balance=FORMAT(Sum(Balance),'#,0.00')
	FROM #finalResult
	GROUP BY AcademicYear,CostCenter,Grade,Gender

	UNION ALL    
	SELECT AcademicYear = ' '    
	,CostCenter = ' '    
	,Grade = ' '    
	,Gender ='Total'     
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    

	DROP TABLE IF EXISTS #tempFeeStatement
	DROP TABLE IF EXISTS #VatDetail
	DROP TABLE IF EXISTS #finalResult
END
GO

DROP PROCEDURE IF EXISTS [SP_ParentReport]
GO

CREATE PROCEDURE  [dbo].[SP_ParentReport]
(
	@ParentId int=0
	,@AcademicYear int=0
)
AS
BEGIN
	SELECT 
		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
	INTO #tempFeeStatement
	FROM 
	(
		SELECT 
			InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId
			,FeeApplied=feeamount
	
		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement 
	)t

	SELECT sa.AcademicYear	
		,CostCenter=cc.CostCenterName	
		,Grade=gm.GradeName
		,Gender=gtm.GenderTypeName	
		,par.ParentCode
		,stu.StudentCode
		,a.FeeApplied
		,a.DiscountApplied
		,a.AmountPaid
		,VatPaid=0
		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 
	INTO #finalResult
	FROM #tempFeeStatement a
	INNER JOIN tblGradeMaster gm 
		ON a.GradeId=gm.GradeId
	JOIN tblParent par 
		ON a.ParentId=par.ParentId
	JOIN tblStudent stu 
		ON a.StudentId=stu.StudentId
	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 
	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    

	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND par.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE par.ParentId END

	SELECT
		ParentCode
		,AcademicYear		
		,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')
		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')
		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')
		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')
		,Balance=FORMAT(Sum(Balance),'#,0.00')
	FROM #finalResult
	GROUP BY ParentCode,AcademicYear

	UNION ALL    
	SELECT ParentCode= ' '
	,AcademicYear ='Total'    
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    

	DROP TABLE IF EXISTS #tempFeeStatement
	DROP TABLE IF EXISTS #VatDetail
	DROP TABLE IF EXISTS #finalResult	
END
GO

DROP PROCEDURE IF EXISTS [SP_ParentStudentReport]
GO

CREATE PROCEDURE  [dbo].[SP_ParentStudentReport]
(
	@ParentId int=0
	,@StudentId int=0
	,@AcademicYear int=0
	,@CostCenter int=0
	,@Grade int=0
	,@Gender int=0
)
AS
BEGIN
	SELECT 
		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
	INTO #tempFeeStatement
	FROM 
	(
		SELECT 
			InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId
			,FeeApplied=feeamount
	
		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement 
	)t

	SELECT 
		sa.AcademicYear	
		,CostCenter=cc.CostCenterName	
		,Grade=gm.GradeName
		,Gender=gtm.GenderTypeName	
		,par.ParentCode
		,stu.StudentCode
		,a.FeeApplied
		,a.DiscountApplied
		,a.AmountPaid
		,VatPaid=0
		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 
	INTO #finalResult
	FROM #tempFeeStatement a
	INNER JOIN tblGradeMaster gm 
		ON a.GradeId=gm.GradeId
	JOIN tblParent par 
		ON a.ParentId=par.ParentId
	JOIN tblStudent stu 
		ON a.StudentId=stu.StudentId
	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 
	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    

	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND gm.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE gm.CostCenterId END       
   AND a.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE a.GradeId END       
   AND stu.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE stu.GenderId END      

	SELECT ParentCode
		,StudentCode
		,AcademicYear	
		,CostCenter	
		,Grade
		,Gender		
		,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')
		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')
		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')
		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')
		,Balance=FORMAT(Sum(Balance),'#,0.00')
	FROM #finalResult
	GROUP BY ParentCode,StudentCode	,AcademicYear,CostCenter,Grade,Gender

	UNION ALL   
 
	SELECT ParentCode = ' '    
		,StudentCode = ' '    
		,AcademicYear = ' '    
	,CostCenter = ' '    
	,Grade = ' '    
	,Gender ='Total'     
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    

	DROP TABLE IF EXISTS #tempFeeStatement
	DROP TABLE IF EXISTS #VatDetail
	DROP TABLE IF EXISTS #finalResult
END
GO

DROP PROCEDURE IF EXISTS [sp_SaveInvoiceToStatement]
GO

CREATE PROCEDURE [dbo].[sp_SaveInvoiceToStatement]    
  @invoiceno bigint=0   ,          
  @DestinationDB nvarchar(50) = ''               
AS          
BEGIN          
       begin try      
 SET NOCOUNT ON;          
 DECLARE @FeeTypeId INT =3;          
 DECLARE @GradeId int=0;          
 SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'           
 DECLARE @FeeStatementType NVARCHAR(50)='Fee Paid'            
          
        
 INSERT INTO [dbo].[tblFeeStatement]          
 (          
  [FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId],[InvoiceNo],[InvoiceDate],[PaymentMethod]          
  ,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]          
 )          
 SELECT            
  @FeeStatementType        
  ,FeeTypeName=case when invSum.InvoiceType='Invoice' then 'TUITION FEE' else 'TUITION FEE REFUND' end          
  ,[FeeAmount]=0      
  ,[PaidAmount]=case when invSum.InvoiceType='Invoice' then invDet.TaxableAmount else invDet.TaxableAmount*-1 end        
  ,invDet.StudentId,invDet.[ParentId],invDet.StudentName ,invDet.ParentName        
  ,invDet.AcademicYear,invDet.GradeId       
  ,invSum.InvoiceNo      
  ,invSum.InvoiceDate      
  ,invpay.PaymentMethod      
  ,IsActive=1          
  ,IsDeleted=0          
  ,UpdateDate=GETDATE()          
  ,UpdateBy=0         
 from INV_InvoiceDetail invDet        
 join INV_InvoiceSummary invSum on invDet.InvoiceNo=invSum.InvoiceNo        
 join INV_InvoicePayment invpay on invpay.InvoiceNo=invSum.InvoiceNo        
 where invSum.invoiceno=@InvoiceNo         
 and invDet.InvoiceType like '%TUITION%'        
    
 select 0 result      
 end TRY      
 begin catch      
       
 select -1 result      
 end catch      
      
END 
GO

DROP PROCEDURE IF EXISTS [SP_MonthlyStatementParentStudent]
GO

CREATE PROCEDURE  [dbo].[SP_MonthlyStatementParentStudent]    
(    
 @ParentId int=0    
 ,@ParentName nvarchar(100)=null 
 ,@AcademicYearId int=0
 ,@StartDate datetime=null    
 ,@EndDate datetime=null    
)    
as    
begin    
  
 set @parentName='%'+@parentName+'%'    
 select     
 ParentId ,ParentName ,NameMonth ,NameYear ,TaxableAmount=sum(TaxableAmount) ,TaxAmount =sum(TaxAmount),ItemSubtotal =sum(ItemSubtotal)    
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
  invSum.[Status]='Posted'  
 and  
  (    
   (@parentId=0 OR invDet.ParentId=@parentId)
   OR (@AcademicYearId=0 OR invDet.AcademicYear=@AcademicYearId)    
   OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)     
   --OR     
   --(    
   -- (    
   --  (@StartDate is null OR @StartDate='' )) OR cast(invSum.InvoiceDate as date)>= cast(@StartDate as date)    
   --)    
  )    
 )t    
 --order by ParentId ,ParentName ,NameMonth ,NameYear     
 group by ParentId ,ParentName ,NameMonth ,NameYear   
    
end 
GO

DROP PROCEDURE IF EXISTS [sp_CSVmonthlyrevenueexport]
GO

CREATE PROCEDURE  [dbo].[sp_CSVmonthlyrevenueexport]    
	@ParentId int=0    
	,@ParentName nvarchar(100)=null 
	,@AcademicYearId int=0
	,@StartDate datetime=null    
	,@EndDate datetime=null   
AS                            
BEGIN      
EXEC SP_MonthlyStatementParentStudent
	@ParentId  
	,@ParentName
	,@AcademicYearId
	,@StartDate
	,@EndDate
END 
GO