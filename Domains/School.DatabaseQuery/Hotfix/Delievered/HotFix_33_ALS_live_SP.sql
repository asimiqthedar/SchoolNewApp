DROP PROCEDURE IF EXISTS [SP_ParentStudentReport]
GO

CREATE PROCEDURE [dbo].[SP_ParentStudentReport]
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
		ParentCode
		,StudentCode
		,AcademicYear
		,CostCenter
		,Grade
		,Gender
		,GradeId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
		,VatPaid
		,Balance
	INTO #ParentStudentTbl
	FROM
	(
		 SELECT
			tp.ParentCode
			,ts.StudentCode
			,sa.AcademicYear
			,cc.CostCenterName AS 'CostCenter'
			,gm.GradeName AS 'Grade'
			,gtm.GenderTypeName AS 'Gender'
			,gm.GradeId
			,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END) AS 'FeeApplied'
			,SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END) AS 'DiscountApplied'
			,SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END) AS 'AmountPaid'
			,SUM(invd.TaxAmount) AS 'VatPaid'
			,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END) 
			- SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END)  
			-SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END)
			AS 'Balance'
		FROM tblFeeStatement fs
		INNER JOIN tblGradeMaster AS gm 
			ON fs.GradeId = gm.GradeId
		INNER JOIN tblSchoolAcademic AS sa 
			ON fs.AcademicYearId = sa.SchoolAcademicId	
		INNER JOIN tblStudent ts
			ON ts.StudentId = fs.StudentId
		INNER JOIN tblParent tp
			ON tp.ParentId = ts.ParentId
		INNER JOIN tblCostCenterMaster cc 
			ON ts.CostCenterId=cc.CostCenterId
		INNER JOIN tblGenderTypeMaster gtm 
			ON gtm.GenderTypeId=ts.GenderId
		LEFT JOIN INV_InvoiceDetail invd
			ON invd.StudentId=ts.StudentId AND InvoiceType LIKE '%Tuition%'		
		WHERE fs.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE fs.AcademicYearId END  
			AND ts.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE ts.CostCenterId END   
			AND fs.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE fs.GradeId END   
			AND ts.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE ts.GenderId END  
			AND tp.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId  END  
			AND ts.StudentId = CASE WHEN @StudentId > 0 THEN @StudentId ELSE ts.StudentId END  
		GROUP BY tp.ParentCode,ts.StudentCode,sa.AcademicYear,cc.CostCenterName,gm.GradeName,gm.GradeId,gtm.GenderTypeName		
		
	)t
	ORDER BY t.GradeId
	SELECT  ParentCode
		,StudentCode
		,AcademicYear
		,CostCenter
		,Grade
		,Gender	
		,FORMAT(ISNULL(FeeApplied,0),'#,0.00') AS FeeApplied
		,FORMAT(ISNULL(DiscountApplied,0),'#,0.00') AS DiscountApplied
		,FORMAT(ISNULL(AmountPaid,0),'#,0.00') AS AmountPaid
		,FORMAT(ISNULL(VatPaid,0),'#,0.00') AS VatPaid
		,FORMAT(ISNULL(Balance,0),'#,0.00') AS Balance
	FROM  #ParentStudentTbl
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
		FROM  #ParentStudentTbl
	DROP TABLE IF EXISTS #ParentStudentTbl; 
END
GO

DROP PROCEDURE IF EXISTS [SP_ParentReport]
GO

CREATE PROC [dbo].[SP_ParentReport]
(
	@ParentId int=0
	,@AcademicYear int=0
)
AS
BEGIN
	SELECT 
		ParentCode	
		,AcademicYear		
		,FeeApplied
		,DiscountApplied
		,AmountPaid
		,VatPaid
		,Balance
	INTO #ParentTbl
	FROM
	(
		 SELECT
			tp.ParentCode
			,sa.AcademicYear		
			,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END) AS 'FeeApplied'
			,SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END) AS 'DiscountApplied'
			,SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END) AS 'AmountPaid'
			,SUM(invd.TaxAmount) AS 'VatPaid'
			,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END) 
			- SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END)  
			-SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END)
			AS 'Balance'
		FROM tblFeeStatement fs		
		INNER JOIN tblSchoolAcademic AS sa 
			ON fs.AcademicYearId = sa.SchoolAcademicId	
		INNER JOIN tblStudent ts
			ON ts.StudentId = fs.StudentId
		INNER JOIN tblParent tp
			ON tp.ParentId = ts.ParentId	
		LEFT JOIN INV_InvoiceDetail invd
			ON invd.StudentId=ts.StudentId AND InvoiceType LIKE '%Tuition%'		
		WHERE fs.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE fs.AcademicYearId END  		
			AND tp.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId  END  
		GROUP BY tp.ParentCode,sa.AcademicYear
		
	)t
	ORDER BY t.ParentCode
	SELECT  ParentCode	
		,AcademicYear		
		,FORMAT(ISNULL(FeeApplied,0),'#,0.00') AS FeeApplied
		,FORMAT(ISNULL(DiscountApplied,0),'#,0.00') AS DiscountApplied
		,FORMAT(ISNULL(AmountPaid,0),'#,0.00') AS AmountPaid
		,FORMAT(ISNULL(VatPaid,0),'#,0.00') AS VatPaid
		,FORMAT(ISNULL(Balance,0),'#,0.00') AS Balance
	FROM  #ParentTbl
	UNION ALL
	SELECT ParentCode = ' '	
		,AcademicYear = 'Total'		
		,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')
		,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')
		,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')
		,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')
		,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')	
		FROM  #ParentTbl
	DROP TABLE IF EXISTS #ParentTbl; 
END
GO

DROP PROCEDURE IF EXISTS [sp_CSVparentreportexport]
GO

CREATE PROCEDURE [dbo].[sp_CSVparentreportexport]    
	@ParentId int=0
	,@AcademicYear int=0	
AS                            
BEGIN      
EXEC SP_ParentReport
		@ParentId
		,@AcademicYear		
END   
GO

DROP PROCEDURE IF EXISTS [sp_CSVStudentStatement]
GO

CREATE PROCEDURE [dbo].[sp_CSVStudentStatement]  
	@AcademicYearId int  =0
	,@ParentId int 
	,@StudentId int
AS    
BEGIN    
	exec sp_reportStudentStatement @AcademicYearId 	,@ParentId 	,@StudentId 
END
GO


DROP PROCEDURE IF EXISTS [sp_CSVStudent]
GO

CREATE PROCEDURE [dbo].[sp_CSVStudent]    
AS      
BEGIN      
 SET NOCOUNT ON;       
 SELECT  stu.StudentCode AS [Student ID]    
  ,tp.ParentCode AS [Parent ID]    
  ,stu.StudentName AS [Student Name]    
  ,stu.StudentArabicName   AS [Student Arabic Name]    
  ,stu.StudentEmail  AS [Student Email]
  ,stu.DOB   AS [Date of Birth]    
  ,stu.IqamaNo   AS [Iqama No]    
  ,tc.CountryName  AS [Nationality]     
  ,tgt.GenderTypeName   AS [Gender]    
  ,stu.AdmissionDate   AS [Admission Date]    
  ,tcc.CostCenterName AS [Cost Center]      
  ,tg.GradeName   AS [Grade]    
  ,ts.SectionName   AS [Section]    
  ,stu.PassportNo   AS [Passport No]    
  ,stu.PassportExpiry  AS [Passport Expiry]     
  ,stu.Mobile   AS [Mobile]    
  ,stu.StudentAddress   AS [Address]    
  ,tss.StatusName   AS [Status]     
  ,CASE WHEN stu.IsGPIntegration=1 THEN 'Yes' ELSE 'No' END  AS [GP Integration]      
  ,tt.TermName   AS [Term]    
  ,stu.AdmissionYear   AS [Admission Year]    
  ,CASE WHEN stu.PrinceAccount=1 THEN 'Yes' ELSE 'No' END  AS [PrinceAccount]     
 FROM tblStudent stu       
 LEFT JOIN tblParent tp      
  ON tp.ParentId = stu.ParentId      
 LEFT JOIN tblCountryMaster tc      
  ON tc.CountryId = stu.NationalityId      
 LEFT JOIN tblGenderTypeMaster tgt      
  ON tgt.GenderTypeId = stu.GenderId      
 LEFT JOIN tblCostCenterMaster tcc      
  ON tcc.CostCenterId = stu.CostCenterId      
 LEFT JOIN tblGradeMaster tg      
  ON tg.GradeId = stu.GradeId      
 LEFT JOIN tblSection ts      
  ON ts.SectionId = stu.SectionId      
 LEFT JOIN tblStudentStatus tss      
  ON tss.StudentStatusId = stu.StudentStatusId      
 LEFT JOIN tblTermMaster tt      
  ON tt.TermId=stu.TermId      
 LEFT JOIN tblTermMaster tt1      
  ON tt1.TermId=stu.WithdrawAt      
 WHERE stu.IsDeleted =  0 AND stu.IsActive = 1      
 ORDER BY CAST(stu.StudentCode AS bigint)     
END  
GO

DROP PROCEDURE IF EXISTS [SP_AdvanceFeeReport]
GO

CREATE PROCEDURE [dbo].[SP_AdvanceFeeReport]      
(      
 @ParentId int=0      
,@ParentName nvarchar(100)=null      
,@FatherIqama nvarchar(100)=null      
,@StudentName nvarchar(100)=null      
,@AcademicYear int=0      
,@InvoiceNo bigint=0      
,@StartDate datetime=null      
,@EndDate datetime=null      
)      
as      
begin      
      
 select       
  ParentId      
 ,ParentName      
 ,FatherMobile      
 ,IqamaNumber      
 ,StudentId      
 ,StudentName      
 ,GradeName      
 ,CostCenter=0      
 ,AcademicYear      
 ,IsStaff      
 ,TaxableAmount=sum(TaxableAmount)      
 ,TaxAmount=sum(TaxAmount)      
 ,ItemSubtotal=sum(ItemSubtotal)      
 ,InvoiceType      
 ,InvoiceDate      
 ,InvoiceNo      
 ,PaymentMethod      
 ,InvoiceRefNo = PaymentReferenceNumber      
 from      
 (      
  select       
    ParentId=isnull(invDet.ParentId,0)      
             ,invDet.ParentName      
   ,invDet.FatherMobile      
   ,StudentId = isnull(invDet.StudentId,0)      
   ,StudentName=isnull(invDet.StudentName,'')      
   ,tgm.GradeName           
   ,tsa.AcademicYear      
   ,invDet.IqamaNumber      
   ,invDet.IsStaff      
   ,invDet.TaxableAmount       
   ,invDet.TaxAmount       
   ,invDet.ItemSubtotal      
   ,invDet.InvoiceType      
   ,invSum.InvoiceNo      
   ,invSum.InvoiceDate      
 ,invPay.PaymentMethod      
 ,invPay.PaymentReferenceNumber     
  from INV_InvoiceSummary invSum      
  join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo      
  left join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId      
  left join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId    
  join    
  (    
  select     
   ROW_NUMBER()over(partition by invPay2.InvoiceNo order by invPay2.PaymentAmount desc) as RNPay    
   ,invPay2.InvoiceNo , invPay2.PaymentMethod  ,invPay2.PaymentReferenceNumber     
 from  INV_InvoicePayment as invPay2     
  )invPay     
  on invDet.InvoiceNo = invPay.InvoiceNo  and RNPay=1    
      
  where       
      invDet.InvoiceType = 'Tuition Fee'    
   and invDet.IsAdvance=cast(1 as bit)  
   AND invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END        
   AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END      
   AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'        
   AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%'      
   AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%'        
   AND invDet.AcademicYear = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE invDet.AcademicYear END         
   AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))                    
   AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))        
         
        
 )t      
 group by    
 ParentId,      
 ParentName,      
 FatherMobile,  
 StudentId,      
 StudentName,      
 GradeName,      
 AcademicYear,  
 IqamaNumber,    
 IsStaff,      
 InvoiceType      
 ,InvoiceDate      
 ,InvoiceNo      
 ,PaymentMethod      
 ,PaymentReferenceNumber      
end 
GO