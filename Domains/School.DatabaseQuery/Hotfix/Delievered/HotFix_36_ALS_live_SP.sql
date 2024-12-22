
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
    
DROP PROCEDURE IF EXISTS [SP_GetFeeAmount]
GO

CREATE PROCEDURE [dbo].[SP_GetFeeAmount]      
 @AcademicYearId bigint      
 ,@StudentId bigint,      
 @InvoiceTypeName nvarchar(50)      
as      
begin      
 DECLARE @IsStaffMember bit=0;      
 DECLARE @GradeId int=0;      
 DECLARE @TotalAcademicYearPaid decimal(18,2)=0      
 DECLARE @InvoiceTypeId bigint=2008      
      
 DECLARE @PeriodFrom DATE      
 DECLARE @PeriodTo DATE      
      
 declare @CurrentAcademicYearEndDate datetime      
 select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1      
       
 declare @IsAdvance int=0      
 if exists(select * from tblSchoolAcademic where cast(PeriodFrom as date)> cast(@CurrentAcademicYearEndDate as date) and SchoolAcademicId=@AcademicYearId)      
 begin      
  set @IsAdvance =1;      
 end      
      
 SELECT TOP 1       
  @PeriodFrom=CAST(PeriodFrom AS DATE)      
  ,@PeriodTo=CAST(PeriodTo AS DATE)      
 FROM tblSchoolAcademic       
 WHERE IsActive=1 and IsDeleted=0      
 AND CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)and CAST(PeriodTo AS DATE)      
      
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
  DECLARE @FinalFeeAmount decimal(18,2)=0      
        
  select     
   @FinalFeeAmount=SUM(FeeAmount)-SUM(PaidAmount)       
  from tblFeeStatement where StudentId=@StudentId       
  and IsActive=1 and IsDeleted=0      
       
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
   ,FinalFeeAmount=@FinalFeeAmount       
  into #FinalAmount      
  from [dbo].[tblFeeTypeDetail] ftd      
  join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId      
  join [dbo].[tblStudentFeeDetail] inv on ftm.FeeTypeId=inv.FeeTypeId       
  and inv.StudentId=@StudentId      
  and ftd.AcademicYearId=inv.AcademicYearId      
  where       
  --ftd.AcademicYearId=@academicYearId      
  --and       
  ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'      
      
    

	  if  exists(select 1 from #FinalAmount)
	  begin
		select    
		   FeeTypeDetailId       
		   ,FeeTypeId       
		   ,AcademicYearId       
		   ,GradeId       
		   ,TermFeeAmount       
		   ,IsActive       
		   ,IsDeleted       
		   ,UpdateDate       
		   ,UpdateBy       
		   ,StaffFeeAmount      
		   ,FinalFeeAmount         
		   ,IsAdvance=cast(@IsAdvance as bit)      
		from #FinalAmount    
	  end
	  else
	  begin
		 declare @FeeTypeId int 
		 select top 1 @FeeTypeId=FeeTypeId from tblFeeTypeMaster where FeeTypeName like '%TUITION%'
	
		 select 
		 FeeTypeDetailId=0
		 ,FeeTypeId=@FeeTypeId
		 ,@AcademicYearId as AcademicYearId 
		 ,GradeId
		 ,TermFeeAmount=0
		 ,IsActive,IsDeleted, UpdateDate,UpdateBy
		 ,StaffFeeAmount	=0
		 ,FinalFeeAmount=0
		 ,IsAdvance=cast(1as bit)      
		 from tblStudent where studentid=@StudentId
	  end

      
  IF OBJECT_ID('tempdb..#FinalAmount') IS NOT NULL              
  DROP TABLE #FinalAmount    
 end      
 else       
 begin      
  select top 1       
   ftd.*,IsStaffMember=@IsStaffMember      
   ,FinalFeeAmount=case when @IsStaffMember=1 then StaffFeeAmount else TermFeeAmount end      
   ,DiscountPercent=0      
   ,IsAdvance=cast(0  as bit)      
  from [dbo].[tblFeeTypeDetail] ftd      
  join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId      
  where AcademicYearId=@academicYearId      
  and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'      
 end      
end   
GO

DROP PROCEDURE IF EXISTS sp_deleteinvoicePermanently
GO

CREATE PROCEDURE sp_deleteinvoicePermanently
	@InvoiceNo int=0
as
begin
	select * from INV_InvoiceDetail where InvoiceNo =@InvoiceNo 
	select * from INV_InvoicePayment where InvoiceNo =@InvoiceNo 
	select * from INV_InvoiceSummary where InvoiceNo =@InvoiceNo 
	select * from tblfeestatement  where InvoiceNo =@InvoiceNo 

	select * from [ZATCAInvoiceLive].[dbo].[InvoiceSummary] where InvoiceNo =@InvoiceNo 
	select * from [ZATCAInvoiceLive].[dbo].[InvoiceDetail] where InvoiceNo =@InvoiceNo 
	select * from [ZATCAInvoiceLive].[dbo].[InvoicePayment] where InvoiceNo =@InvoiceNo

	----Now delete
	delete from INV_InvoiceDetail where InvoiceNo =@InvoiceNo 
	delete from INV_InvoicePayment where InvoiceNo =@InvoiceNo 
	delete from INV_InvoiceSummary where InvoiceNo =@InvoiceNo 
	delete from tblfeestatement  where InvoiceNo =@InvoiceNo 

	delete from [ZATCAInvoiceLive].[dbo].[InvoiceSummary] where InvoiceNo =@InvoiceNo 
	delete from [ZATCAInvoiceLive].[dbo].[InvoiceDetail] where InvoiceNo =@InvoiceNo 
	delete from [ZATCAInvoiceLive].[dbo].[InvoicePayment] where InvoiceNo =@InvoiceNo 
end
GO

DROP PROCEDURE IF EXISTS [sp_GetAppDropdown]
GO

CREATE PROCEDURE [dbo].[sp_GetAppDropdown]          
 @DropdownType int          
 ,@ReferenceId int          
AS          
BEGIN          
 SET NOCOUNT ON;          
 IF @DropdownType = 1          
 BEGIN          
  SELECT trl.RoleId AS SValue          
   ,trl.RoleName AS SText          
  FROM tblRole trl          
  WHERE trl.IsActive = 1 AND trl.IsDeleted = 0          
  ORDER BY trl.RoleName          
 END          
 IF @DropdownType = 2          
 BEGIN          
  SELECT tcc.CostCenterId AS SValue          
   ,tcc.CostCenterName AS SText          
  FROM tblCostCenterMaster tcc          
  WHERE tcc.IsActive = 1 AND tcc.IsDeleted = 0          
  ORDER BY tcc.CostCenterName          
 END          
 IF @DropdownType = 3          
 BEGIN          
  SELECT tgt.GenderTypeId AS SValue          
   ,tgt.GenderTypeName AS SText          
  FROM tblGenderTypeMaster tgt          
  WHERE tgt.IsActive = 1 AND tgt.IsDeleted = 0          
  ORDER BY tgt.GenderTypeName          
 END          
 IF @DropdownType = 4          
 BEGIN          
  SELECT tg.GradeId AS SValue          
   --,tg.GradeName AS SText          
  -- ,CONCAT_WS(' - ',tg.GradeName, tgt.GenderTypeName)  AS SText          
  ,case when tgt.GenderTypeName is null then  isnull(tg.GradeName,'') else (isnull(tg.GradeName,'') +' - '+isnull(tgt.GenderTypeName,'')) end AS SText          
  FROM tblGradeMaster tg          
  INNER JOIN tblCostCenterMaster tcc          
   ON tcc.CostCenterId = tg.CostCenterId          
  LEFT JOIN tblGenderTypeMaster tgt          
   ON tgt.GenderTypeId = tg.GenderTypeId          
  WHERE tg.IsActive = 1 AND tg.IsDeleted = 0          
   AND tg.CostCenterId = CASE WHEN @ReferenceId > 0 THEN @ReferenceId ELSE tg.CostCenterId END           
  ORDER BY tg.SequenceNo    ASC      
 END          
 IF @DropdownType = 5          
 BEGIN          
  SELECT tc.CountryId AS SValue          
   --,CONCAT_WS(' - ',tc.CountryName, tc.CountryCode)  AS SText         
   ,tc.CountryName  AS SText         
  FROM tblCountryMaster tc            
  WHERE tc.IsActive = 1 AND tc.IsDeleted = 0             
  ORDER BY tc.CountryName          
 END          
 IF @DropdownType = 6          
 BEGIN          
  SELECT dt.DocumentTypeId AS SValue          
   ,dt.DocumentTypeName  AS SText          
  FROM tblDocumentTypeMaster dt            
  WHERE dt.IsActive = 1 AND dt.IsDeleted = 0             
  ORDER BY dt.DocumentTypeName          
 END         
 IF @DropdownType = 7          
 BEGIN        
 SELECT SValue,SText FROM(      
   SELECT tp.ParentId AS SValue          
    ,tp.ParentCode+' - '+tp.FatherName  AS SText       
    ,CAST(ISNULL(tp.ParentCode,0) AS nvarchar(50)) AS ParentCode       
   FROM tblParent tp            
   WHERE tp.IsActive = 1 AND tp.IsDeleted = 0             
  )t      
  ORDER BY t.ParentCode      
 END         
 IF @DropdownType = 8          
 BEGIN          
  SELECT tgs.SectionId AS SValue          
   ,tgs.SectionName  AS SText          
  FROM tblSection tgs           
  WHERE tgs.IsActive = 1 AND tgs.IsDeleted = 0             
  ORDER BY tgs.SectionName          
 END         
 IF @DropdownType = 9          
 BEGIN          
  SELECT tss.StudentStatusId AS SValue                  
   ,tss.StatusName  AS SText                  
  FROM tblStudentStatus tss                    
  WHERE tss.IsActive = 1 AND tss.IsDeleted = 0           
  and tss.StatusName !='Withdraw'          
  ORDER BY tss.StatusName        
 END         
 IF @DropdownType = 10          
 BEGIN          
  SELECT trm.TermId AS SValue          
   ,trm.TermName  AS SText          
  FROM tblTermMaster trm          
  WHERE trm.IsActive = 1 AND trm.IsDeleted = 0             
  ORDER BY trm.TermName          
 END         
 IF @DropdownType = 11          
 BEGIN          
  SELECT trm.BranchId AS SValue          
   ,trm.BranchName  AS SText          
  FROM tblBranchMaster trm          
  WHERE trm.IsActive = 1 AND trm.IsDeleted = 0             
  ORDER BY trm.BranchName          
 END         
 IF @DropdownType = 12          
 BEGIN    
 SELECT SValue ,SText    
 FROM     
 (    
  SELECT      
  ROW_NUMBER() OVER(ORDER BY IsCurrentYear DESC,PeriodFrom ASC ) AS rn    
  ,trm.SchoolAcademicId AS SValue              
  ,trm.AcademicYear  AS SText       
  FROM tblSchoolAcademic trm              
  WHERE  trm.IsDeleted = 0 and trm.IsActive=1     
 )T    
 ORDER BY rn    
 END        
 IF @DropdownType = 13          
 BEGIN          
  SELECT FeeTypeId AS SValue          
  ,FeeTypeName  AS SText          
  FROM tblFeeTypeMaster          
  WHERE  IsDeleted = 0 AND IsActive=1          
 END         
 IF @DropdownType = 14          
 BEGIN          
  SELECT DiscountRuleId AS SValue          
  ,DiscountRuleDescription  AS SText          
  FROM tblDiscountRules        
  WHERE  IsDeleted = 0 AND IsActive=1          
 END        
 IF @DropdownType = 15          
 BEGIN          
  SELECT tp.StudentId AS SValue          
   ,tp.StudentCode+' - '+ tp.StudentName   AS SText          
  FROM tblStudent tp            
  WHERE tp.IsActive = 1 AND tp.IsDeleted = 0             
  ORDER BY tp.StudentCode          
 END       
  IF @DropdownType = 16        
 BEGIN          
  SELECT tpmc.PaymentMethodCategoryId AS SValue          
   ,tpmc.CategoryName  AS SText          
  FROM tblPaymentMethodCategory tpmc         
  WHERE  tpmc.IsDeleted = 0 and tpmc.IsActive=1          
 END   
  IF @DropdownType = 17         
 BEGIN          
  SELECT tss.StudentStatusId AS SValue                  
   ,tss.StatusName  AS SText                  
  FROM tblStudentStatus tss                    
  WHERE tss.IsActive = 1 AND tss.IsDeleted = 0       
  ORDER BY tss.StatusName        
 END     
END 
GO
