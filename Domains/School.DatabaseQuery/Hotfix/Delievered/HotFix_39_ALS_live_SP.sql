DROP PROCEDURE IF EXISTS [SP_GeneralReport]
GO

CREATE PROCEDURE [dbo].[SP_GeneralReport]    
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
		where isnull(InvoiceNo,0)=0
	)t

	INSERT INTO #tempFeeStatement
	SELECT 
		f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId
		,FeeApplied=feeamount
		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
		,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
	FROM tblFeeStatement f
	join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'

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

DROP PROCEDURE IF EXISTS [SP_GetFeeAmountParentStudent]
GO

CREATE PROCEDURE [dbo].[SP_GetFeeAmountParentStudent]    
 @AcademicYearId bigint    
 ,@ParentId bigint    
 ,@InvoiceTypeName nvarchar(50)            
as            
begin            
  DECLARE @IsStaffMember bit=0;            
  DECLARE @GradeId int=0;            
  DECLARE @TotalAcademicYearPaid decimal(18,2)=0            
  DECLARE @InvoiceTypeId bigint=2008       
            
  declare @CurrentAcademicYearEndDate datetime            
  select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1            
             
  declare @IsAdvance int=0            
  if exists(select * from tblSchoolAcademic where cast(PeriodFrom as date)> cast(@CurrentAcademicYearEndDate as date)     
  and SchoolAcademicId=@AcademicYearId)            
  begin            
   set @IsAdvance =1;            
  end    
    
  --Advance year    
  select SchoolAcademicId    
  into #AdvanceAcademicYear    
  from tblSchoolAcademic    
  where PeriodFrom>@CurrentAcademicYearEndDate    
    
 begin        
 declare  @NationalityId int=0        
 select top 1            
  @IsStaffMember= case when p.IsFatherStaff=1 OR p.IsMotherStaff=1 then 1 else 0 end      
  ,@NationalityId= FatherNationalityId    
 from            
 [dbo].[tblParent] p            
 where p.ParentId= @ParentId            
 end            
    
 declare @VatPercent decimal(18,2)=0;        
  select         
  top 1         
   fd.VatId        
   ,fd.FeeTypeId     
   ,fd.DebitAccount        
   ,fd.CreditAccount        
   ,ISNULL(VatTaxPercent,0)VatTaxPercent         
  into #tempVat        
  from [dbo].[tblFeeTypeMaster] fm        
  left join [dbo].[tblVatMaster] fd on fm.FeeTypeId=fd.FeeTypeId        
  where fm.FeeTypeId=1 OR fm.FeeTypeName like '%'+@InvoiceTypeName+'%'        
  and fm.IsActive=1 and fm.IsDeleted=0        
  and fd.IsActive=1 and fd.IsDeleted=0         
 order by VatId desc      
    
  if exists(select VatId from tblVatCountryExclusionMap where VatId in (select vatid from #tempVat) and CountryId=@NationalityId        
  and IsDeleted=0 and IsActive=1)        
  begin        
   set @VatPercent=0        
  end        
  else        
  begin        
   select @VatPercent=VatTaxPercent from #tempVat        
  end        
        
  if(@InvoiceTypeName like '%Tuition%')            
  begin             
   DECLARE @FinalFeeAmount decimal(18,2)=0            
              
   --Final Amount for parent student- with applied amount and paid amount till this current year    
   select       
    ParentId,StudentId,  FinalFeeAmount=SUM(FeeAmount)-SUM(PaidAmount)     
   INTO #ParentStudentfee    
   from tblFeeStatement where ParentId=@ParentId             
   and IsActive=1 and IsDeleted=0      
   and AcademicYearId not in (select * from #AdvanceAcademicYear)    
   GROUP BY parentid,studentid    
      
   declare @FeeTypeIdTution int       
     select top 1 @FeeTypeIdTution=FeeTypeId from tblFeeTypeMaster where FeeTypeName like '%TUITION%'      
  
  select  
	par.ParentId  
	,par.ParentCode  
	,par.FatherName  
	,par.FatherMobile  
	,stu.StudentId  
	,stu.StudentCode  
	,FeeTypeId=@FeeTypeIdTution    
	,AcademicYearId=@AcademicYearId    
	,IsStaffMember=@IsStaffMember     
	,DiscountPercent=0    
	,VatPercent=@VatPercent    
	,stu.GradeId    
	,grade.GradeName    
	,stu.StudentName    
	,stu.StudentArabicName       
	,TermFeeAmount=0    
	,stu.IsActive    
	,stu.IsDeleted    
	,stu.UpdateDate    
	,stu.UpdateBy    
	,StaffFeeAmount=0    
	,FinalFeeAmount=ISNULL( p.FinalFeeAmount,0)    
	,IsAdvance= case when ISNULL( p.FinalFeeAmount,0)>0 then cast(0  as bit)   else cast(@IsAdvance  as bit)   end    
  from tblStudent stu    
  join tblGradeMaster grade on stu.GradeId=grade.GradeId    
  join tblParent par on stu.ParentId=par.ParentId  
  join #ParentStudentfee p on stu.StudentId=p.StudentId and stu.ParentId=p.ParentId    
  where stu.IsActive=1 and stu.IsDeleted=0    
      
  IF OBJECT_ID('tempdb..#FinalAmount') IS NOT NULL                    
   DROP TABLE #FinalAmount          
    
  IF OBJECT_ID('tempdb..#ParentStudentfee') IS NOT NULL                    
   DROP TABLE #ParentStudentfee        
    
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
      
   IF OBJECT_ID('tempdb..#AdvanceAcademicYear') IS NOT NULL                    
   DROP TABLE #AdvanceAcademicYear        
end 
GO

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
	SELECT 		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId		,FeeApplied		,DiscountApplied		,AmountPaid	INTO #tempFeeStatement	FROM 	(		SELECT 			f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId			,FeeApplied=feeamount			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END		FROM tblFeeStatement f		where isnull(f.InvoiceNo,0)=0		--and cast(UpdateDate as date) between cast(@StartDate as date) and cast(@EndDate as date)	)t	insert into #tempFeeStatement	SELECT 			f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId			,FeeApplied=feeamount			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END		FROM tblFeeStatement f		join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'		where cast(i.InvoiceDate as date) between cast(@StartDate as date) and cast(@EndDate as date)	SELECT sa.AcademicYear			,CostCenter=cc.CostCenterName			,Grade=gm.GradeName		,Gender=gtm.GenderTypeName			,par.ParentCode		,stu.StudentCode		,a.FeeApplied		,a.DiscountApplied		,a.AmountPaid		,VatPaid=0--ISNULL(tax.VatPaid	,0)		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 	INTO #finalResult	FROM #tempFeeStatement a	--LEFT JOIN #VatDetail tax 
	--	ON a.InvoiceNo=tax.InvoiceNo and a.ParentId=tax.ParentId and a.StudentId=tax.StudentId	INNER JOIN tblGradeMaster gm 		ON a.GradeId=gm.GradeId	JOIN tblParent par 		ON a.ParentId=par.ParentId	JOIN tblStudent stu 		ON a.StudentId=stu.StudentId	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    
	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND par.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE par.ParentId END	SELECT		ParentCode		,AcademicYear				,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')		,Balance=FORMAT(Sum(Balance),'#,0.00')	FROM #finalResult	GROUP BY ParentCode,AcademicYear	UNION ALL    
	SELECT ParentCode= ' '
	,AcademicYear ='Total'    
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    	DROP TABLE IF EXISTS #tempFeeStatement	DROP TABLE IF EXISTS #VatDetail	DROP TABLE IF EXISTS #finalResult	
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
	 ,@StartDate datetime=null      
	,@EndDate datetime=null  
)
AS
BEGIN
	SELECT 		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId		,FeeApplied		,DiscountApplied		,AmountPaid	INTO #tempFeeStatement	FROM 	(		SELECT 			InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId			,FeeApplied=feeamount			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END		FROM tblFeeStatement 		where isnull(InvoiceNo,0)=0	)t	insert into #tempFeeStatement	SELECT 		f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId		,FeeApplied=feeamount		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END		,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END	FROM tblFeeStatement f	join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'	where cast(i.InvoiceDate as date) between cast(@StartDate as date) and cast(@EndDate as date)	SELECT 		sa.AcademicYear			,CostCenter=cc.CostCenterName			,Grade=gm.GradeName		,Gender=gtm.GenderTypeName			,par.ParentCode		,stu.StudentCode		,a.FeeApplied		,a.DiscountApplied		,a.AmountPaid		,VatPaid=0--ISNULL(tax.VatPaid	,0)		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 	INTO #finalResult	FROM #tempFeeStatement a	--LEFT JOIN #VatDetail tax 
	--	ON a.InvoiceNo=tax.InvoiceNo and a.ParentId=tax.ParentId and a.StudentId=tax.StudentId	INNER JOIN tblGradeMaster gm 		ON a.GradeId=gm.GradeId	JOIN tblParent par 		ON a.ParentId=par.ParentId	JOIN tblStudent stu 		ON a.StudentId=stu.StudentId	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    
	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND gm.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE gm.CostCenterId END       
   AND a.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE a.GradeId END       
   AND stu.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE stu.GenderId END      	SELECT ParentCode		,StudentCode		,AcademicYear			,CostCenter			,Grade		,Gender				,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')		,Balance=FORMAT(Sum(Balance),'#,0.00')	FROM #finalResult	GROUP BY ParentCode,StudentCode	,AcademicYear,CostCenter,Grade,Gender	UNION ALL    
	SELECT ParentCode = ' '    		,StudentCode = ' '    		,AcademicYear = ' '    
	,CostCenter = ' '    
	,Grade = ' '    
	,Gender ='Total'     
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    	DROP TABLE IF EXISTS #tempFeeStatement	DROP TABLE IF EXISTS #VatDetail	DROP TABLE IF EXISTS #finalResult
END
GO

DROP PROCEDURE IF EXISTS [sp_CSVparentreportexport]
GO

CREATE PROCEDURE [dbo].[sp_CSVparentreportexport]      
 @ParentId int=0  
 ,@AcademicYear int=0  
,@StartDate datetime=null      
,@EndDate datetime=null  
AS                              
BEGIN        
EXEC SP_ParentReport  
  @ParentId  
  ,@AcademicYear 
  ,@StartDate
  ,@EndDate
END    
GO

DROP PROCEDURE IF EXISTS [sp_CSVparentstudentreportexport]
GO

CREATE PROCEDURE [dbo].[sp_CSVparentstudentreportexport]      
 @ParentId int=0  
 ,@StudentId int=0  
 ,@AcademicYear int=0  
 ,@CostCenter int=0  
 ,@Grade int=0  
 ,@Gender int=0  
 ,@StartDate datetime=null      
,@EndDate datetime=null  
AS                              
BEGIN        
EXEC SP_ParentStudentReport  
  @ParentId  
  ,@StudentId  
  ,@AcademicYear  
  ,@CostCenter  
  ,@Grade  
  ,@Gender  
  ,@StartDate
,@EndDate
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
              
            
--Delete previous entry of invoice  
delete from [tblFeeStatement]  
where InvoiceNo= @invoiceno  
  
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