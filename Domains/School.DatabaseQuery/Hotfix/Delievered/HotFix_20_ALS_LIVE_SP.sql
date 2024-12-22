ALTER proc [dbo].[SP_UniformSalesReport]
(
    @ItemCode nvarchar(100)=null
   ,@InvoiceNo bigint = 0
   ,@ParentName nvarchar(100)=null
   ,@FatherMobile nvarchar(100)=null
   ,@PaymentMethod nvarchar(100)=null
   ,@PaymentReferenceNumber nvarchar(100)=null
   ,@StartDate datetime=null
   ,@EndDate datetime=null
)
as
begin


	SELECT 
		 ItemCode
		,[Description]
		,InvoiceType
		,InvoiceNo
		,InvoiceDate
		,ParentName
		,FatherMobile
		,Quantity
		,UnitPrice
		,TaxableAmount=sum(TaxableAmount)
		,TaxAmount=sum(TaxAmount)
		,ItemSubtotal=sum(ItemSubtotal)
		,PaymentMethod
		,PaymentReferenceNumber
	INTO #UniformTbl
	FROM
	(
		SELECT 
			 ItemCode = isnull(invDet.ItemCode, '')
			,[Description] = isnull(invDet.[Description], '')
			,invDet.InvoiceType
			,invDet.InvoiceNo
			,invSum.InvoiceDate
            ,invDet.ParentName
			,invDet.FatherMobile
			,invDet.Quantity
			,invDet.UnitPrice   
			,invDet.TaxableAmount	
			,invDet.TaxAmount	
			,invDet.ItemSubtotal
			,invPay.PaymentMethod
			,invPay.PaymentReferenceNumber
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
		where 
		invDet.InvoiceType = 'Uniform Fee' 
		AND invDet.ItemCode LIKE '%' + CASE WHEN len(@ItemCode) > 0 THEN @ItemCode ELSE invDet.ItemCode END + '%'
		AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END
		AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'  
		AND invDet.FatherMobile LIKE '%'+ CASE WHEN len(@FatherMobile) > 0 THEN @FatherMobile ELSE invDet.FatherMobile  END + '%'
		AND invPay.PaymentMethod LIKE '%'+ CASE WHEN len(@PaymentMethod) > 0 THEN @PaymentMethod ELSE invPay.PaymentMethod  END + '%'    
		AND invPay.PaymentReferenceNumber LIKE '%'+ CASE WHEN len(@PaymentReferenceNumber) > 0 THEN @PaymentReferenceNumber ELSE invPay.PaymentReferenceNumber  END + '%'     
		AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))              
		AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))  
	)t
	group by
	    ItemCode,
		[Description],
		UnitPrice,
		Quantity,
        ParentName,
        FatherMobile,
         InvoiceType
		,InvoiceDate
		,InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber

	SELECT  ItemCode
		,[Description]
		,InvoiceType
		,InvoiceNo
		,InvoiceDate=CONVERT(NVARCHAR(20),InvoiceDate,103) 
		,ParentName
		,FatherMobile
		,Quantity
		,UnitPrice
		,TaxableAmount=FORMAT(TaxableAmount,'#,0.00')
		,TaxAmount=FORMAT(TaxAmount,'#,0.00')
		,ItemSubtotal=FORMAT(ItemSubtotal,'#,0.00')
		,PaymentMethod
		,PaymentReferenceNumber 
	FROM #UniformTbl
	UNION ALL
	SELECT ItemCode=' '
		,[Description]=' '
		,InvoiceType=' '
		,InvoiceNo=NULL
		,InvoiceDate=' '
		,ParentName='Total'
		,FatherMobile=' '
		,Quantity=NULL
		,UnitPrice=NULL
		,TaxableAmount=FORMAT(SUM(TaxableAmount),'#,0.00')
		,TaxAmount=FORMAT(SUM(TaxAmount),'#,0.00')
		,ItemSubtotal=FORMAT(SUM(ItemSubtotal),'#,0.00')
		,PaymentMethod=''
		,PaymentReferenceNumber =''
	FROM #UniformTbl

	DROP TABLE IF EXISTS #UniformTbl; 
end
GO
ALTER proc [dbo].[SP_TuitionFeeReport]
(
  @ParentId int=0
 ,@ParentName nvarchar(250)=null
 ,@FatherIqama nvarchar(250)=null
 ,@StudentName nvarchar(250)=null
 ,@AcademicYear int=0
 ,@InvoiceNo BigInt=0
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
	,CostCenter=CostCenterName
	,AcademicYear
	,IsStaff
	,TaxableAmount=sum(TaxableAmount)
	,TaxAmount=sum(TaxAmount)
	,ItemSubtotal=sum(ItemSubtotal)
	,InvoiceType
	,InvoiceDate
	,InvoiceNo
	,PaymentMethod
	,PaymentReferenceNumber
	INTO #TutionTbl
	from
	(
		select 
			 ParentId=isnull(tp.ParentCode,0)
             ,invDet.ParentName
			,invDet.FatherMobile
			,StudentId = isnull(ts.StudentCode,0)
			,StudentName=isnull(invDet.StudentName,'')
			,tgm.GradeName     
			,tsa.AcademicYear
			,invDet.IqamaNumber
			,IsStaff=CASE WHEN invDet.IsStaff=1 THEN 'Yes' ELSE 'No' END 
			,invDet.TaxableAmount	
			,invDet.TaxAmount	
			,invDet.ItemSubtotal
			,invDet.InvoiceType
			,invSum.InvoiceNo
			,invSum.InvoiceDate
			,invPay.PaymentMethod
			,invPay.PaymentReferenceNumber
			,tcc.CostCenterName
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
		LEFT JOIN tblParent tp on tp.ParentId=invDet.ParentId
		LEFT JOIN tblStudent ts ON ts.StudentId=invDet.StudentId
		LEFT JOIN tblCostCenterMaster tcc ON tcc.CostCenterId=ts.CostCenterId
		where invDet.InvoiceType = 'Tuition Fee'
		AND invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END  
		AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'  
		AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%' 
		AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%' 
		AND invDet.AcademicYear = CASE WHEN @ParentId > 0 THEN @AcademicYear ELSE invDet.AcademicYear END  
		AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END  
		AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))              
		AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))         
	)t
	group by  ParentId,
        ParentName,
        FatherMobile,
        IqamaNumber,
		StudentId,
        StudentName,
        GradeName,
        AcademicYear,
        IsStaff,
         InvoiceType
		,InvoiceDate
		,InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber
		,CostCenterName

SELECT ParentId
	,ParentName
	,IqamaNumber
	,StudentId
	,StudentName
	,GradeName
	,CostCenter
	,AcademicYear
	,FatherMobile
	,IsStaff=CAST(IsStaff AS NVARCHAR(10)) 
	,InvoiceType
	,InvoiceNo=CAST(InvoiceNo AS NVARCHAR(100)) 
	,InvoiceDate=CONVERT(NVARCHAR(20),InvoiceDate,103) 
	,TaxableAmount=FORMAT(TaxableAmount,'#,0.00')
	,TaxAmount=FORMAT(TaxAmount,'#,0.00')
	,ItemSubtotal=FORMAT(ItemSubtotal,'#,0.00')
	,PaymentMethod
	,PaymentReferenceNumber
	FROM #TutionTbl
	UNION ALL
	SELECT ParentId=' '
			,ParentName=' '
			,IqamaNumber=' '
			,StudentId=' '
			,StudentName=' '
			,GradeName=' '
			,CostCenter=' '
			,AcademicYear=' '
			,FatherMobile=' '
			,IsStaff=''
			,InvoiceType=' '
			,InvoiceNo=' '
			,InvoiceDate='Total'
			,TaxableAmount=FORMAT(SUM(TaxableAmount),'#,0.00')
			,TaxAmount=FORMAT(SUM(TaxAmount),'#,0.00')
			,ItemSubtotal=FORMAT(SUM(ItemSubtotal),'#,0.00')
			,PaymentMethod=' '
			,PaymentReferenceNumber=' '
	FROM #TutionTbl

	DROP TABLE IF EXISTS #TutionTbl; 

end
GO
--exec [SP_EntranceFeesReport]

ALTER proc [dbo].[SP_EntranceFeesReport]
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
	 ParentName
	,FatherMobile
	,IqamaNumber
	,StudentName
	,GradeName
	,CostCenter = CostCenterName
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
	INTO #EntranceTbl
	from
	(
		select 
             invDet.ParentName
			,invDet.FatherMobile
			,StudentName=isnull(invDet.StudentName,'')
			,tgm.GradeName     
			,tsa.AcademicYear
			,invDet.IqamaNumber
			,IsStaff=CASE WHEN invDet.IsStaff=1 THEN 'Yes' ELSE 'No' END 
			,invDet.TaxableAmount	
			,invDet.TaxAmount	
			,invDet.ItemSubtotal
			,invDet.InvoiceType
			,invSum.InvoiceNo
			,invSum.InvoiceDate
			,invPay.PaymentMethod
			,invPay.PaymentReferenceNumber
			,tcc.CostCenterName
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
		LEFT JOIN tblStudent ts ON ts.StudentId=invDet.StudentId
		LEFT JOIN tblCostCenterMaster tcc ON tcc.CostCenterId=ts.CostCenterId
		where 
		 invDet.InvoiceType = 'Entrance Fee' 
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
        ParentName,
        FatherMobile,
        IqamaNumber,
        StudentName,
        GradeName,
        AcademicYear,
        IsStaff,
         InvoiceType
		,InvoiceDate
		,InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber
		,CostCenterName
	SELECT  ParentName
			,IqamaNumber
			,FatherMobile
			,StudentName
			,GradeName
			,CostCenter
			,AcademicYear
			,IsStaff=CAST(IsStaff AS NVARCHAR(10)) 
			,InvoiceType
			,InvoiceNo=CAST(InvoiceNo AS NVARCHAR(100)) 
			,InvoiceDate=CONVERT(NVARCHAR(20),InvoiceDate,103) 
			,TaxableAmount=FORMAT(TaxableAmount,'#,0.00')
			,TaxAmount=FORMAT(TaxAmount,'#,0.00')
			,ItemSubtotal=FORMAT(ItemSubtotal,'#,0.00')
			,PaymentMethod
			,InvoiceRefNo
	FROM #EntranceTbl
	UNION ALL
	SELECT ParentName =' '
			,IqamaNumber=' '
			,FatherMobile=' '
			,StudentName=' '
			,GradeName=' '
			,CostCenter=' '
			,AcademicYear=' '
			,IsStaff=' '
			,InvoiceType=' '
			,InvoiceNo=' '
			,InvoiceDate='Total'
			,TaxableAmount=FORMAT(SUM(TaxableAmount),'#,0.00')
			,TaxAmount=FORMAT(SUM(TaxAmount),'#,0.00')
			,ItemSubtotal=FORMAT(SUM(ItemSubtotal),'#,0.00')
			,PaymentMethod=' '
			,InvoiceRefNo=' '
	FROM #EntranceTbl
	DROP TABLE IF EXISTS #EntranceTbl; 
end
GO
ALTER PROCEDURE [dbo].[sp_SaveInvoiceToStatement]  
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
 and invSum.InvoiceType='Invoice'       
 and invDet.InvoiceType like '%TUITION%'      
  
 select 0 result    
 end TRY    
 begin catch    
     
 select -1 result    
 end catch    
    
END
GO
ALTER PROC [dbo].[SP_DiscountReport]
(
  @ParentId INT=0
 ,@ParentName NVARCHAR(200)=null
 ,@FatherIqama NVARCHAR(200)=null
 ,@StudentName NVARCHAR(100)=null
 ,@AcademicYearId INT=0
 ,@StartDate DATETIME=null
 ,@EndDate DATETIME=null
)
AS
BEGIN
	SELECT tp.ParentCode
			,tp.FatherName
			,tp.FatherIqamaNo 
			,ts.StudentCode
			,ts.StudentName
			,tgm.GradeName
			,tcc.CostCenterName
			,tsa.AcademicYear
			 ,COALESCE(
				ts.Mobile COLLATE SQL_Latin1_General_CP1_CI_AS, 
				tp.FatherMobile COLLATE SQL_Latin1_General_CP1_CI_AS, 
				tp.MotherMobile COLLATE SQL_Latin1_General_CP1_CI_AS
			) AS Mobile
			,CASE WHEN tp.IsFatherStaff=1 THEN 'Yes' ELSE 'No' END IsFatherStaff
			,fs.FeeStatementType
			,fs.UpdateDate
			,CASE WHEN fs.PaidAmount>0 THEN fs.PaidAmount ELSE NULL END AS 'DiscountApplied'
			,CASE WHEN fs.PaidAmount<0 THEN fs.PaidAmount*-1 ELSE NULL END AS 'DiscountCancelled'
	INTO #DiscountTbl
	FROM tblFeeStatement fs
	INNER JOIN tblStudent ts
		ON ts.StudentId=fs.StudentId
	INNER JOIN tblParent tp
		ON tp.ParentId=fs.ParentId
	INNER JOIN tblGradeMaster tgm 
		ON tgm.GradeId = fs.GradeId
	INNER JOIN tblSchoolAcademic tsa 
		ON tsa.SchoolAcademicId = fs.AcademicYearId
	INNER JOIN tblCostCenterMaster tcc
		ON tcc.CostCenterId=ts.CostCenterId
	WHERE fs.FeeStatementType LIKE '%Discount%'
		AND tp.ParentId= CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId END
		AND tp.FatherName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE tp.FatherName  END + '%'  
		AND tp.FatherIqamaNo LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE tp.FatherIqamaNo  END + '%'  
		AND ts.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE ts.StudentName  END + '%'  
		AND tsa.SchoolAcademicId= CASE WHEN @AcademicYearId > 0 THEN @AcademicYearId ELSE tsa.SchoolAcademicId END
		AND (@StartDate IS NULL OR cast(fs.UpdateDate as date) >= cast(@StartDate as date))              
		AND (@EndDate IS NULL OR cast(fs.UpdateDate as date) <= cast(@EndDate as date))
	ORDER BY StudentName
	SELECT ParentCode
			,FatherName
			,FatherIqamaNo 
			,StudentCode
			,StudentName
			,GradeName
			,CostCenterName
			,AcademicYear
			,Mobile
			,IsFatherStaff
			,FeeStatementType
			,UpdateDate=CONVERT(NVARCHAR(20),UpdateDate,103) 
			,DiscountApplied=FORMAT(DiscountApplied,'#,0.00')
			,DiscountCancelled=FORMAT(DiscountCancelled,'#,0.00')
	FROM #DiscountTbl	
	UNION ALL
	SELECT ParentCode=' '
			,FatherName=' '
			,FatherIqamaNo =' '
			,StudentCode=' '
			,StudentName=' '
			,GradeName=' '
			,CostCenterName=' '
			,AcademicYear=' '
			,Mobile=' '
			,IsFatherStaff=' '
			,FeeStatementType=' '
			,UpdateDate='Total'
			,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')
			,DiscountCancelled=FORMAT(SUM(DiscountCancelled),'#,0.00')
	FROM #DiscountTbl
	DROP TABLE IF EXISTS #DiscountTbl; 
END
GO
ALTER PROCEDURE [dbo].[sp_GetAppDropdown]    
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
	   ,CAST(ISNULL(tp.ParentCode,0) AS INT) AS ParentCode 
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
  SELECT trm.SchoolAcademicId AS SValue    
   ,trm.AcademicYear  AS SText    
  FROM tblSchoolAcademic trm    
  WHERE  trm.IsDeleted = 0 and trm.IsActive=1 --AND trm.SchoolId=@ReferenceId     
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
   ,tp.StudentCode  AS SText    
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
END
GO
--exec [sp_ProcessGP_UniformInvoice] 6698,'two'  

ALTER proc [dbo].[sp_ProcessGP_UniformInvoice]  
(            
  @invoiceno bigint=0   ,        
  @DestinationDB nvarchar(50) = ''        
)            
AS            
BEGIN       
  BEGIN TRY       
      
 IF OBJECT_ID('tempdb..#INT_ALS_SalesInvoiceSourceTable') IS NOT NULL    
	DROP TABLE #INT_ALS_SalesInvoiceSourceTable    

	delete from INT_SalesInvoiceSourceTable where SOPNumber=@invoiceno
	delete from INT_SalesPaymentSourceTable where SOPNumber=@invoiceno
	delete from INT_SalesDistributionSourceTable where SOPNumber=@invoiceno
    
 --Update database  
 DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'     
            
 -----------sales detail processing            
 declare @SOPType int=3            
 declare @DocID nvarchar(50)='STDINV'            
 declare @IntegrationStatus int=0            
            
 Declare @InvoiceTypeCount int=0            
 declare @totalPayableAmount decimal(18,4)=0            
            
 select             
  SeqNum=ROW_NUMBER() over(partition by invSum.invoiceno order by InvoiceDetailId)            
  ,SOPNumber=invSum.invoiceno            
  ,SOPType=@SOPType            
  ,DocID=@DocID            
  ,DocDate= cast(invSum.InvoiceDate as date)            
  ,CustomerNumber='CASH CUSTOMER'            
  ,ItemNumber=invDet.ItemCode            
  ,Quantity=invDet.Quantity             
  ,UnitPrice=invDet.ItemSubtotal-invDet.TaxAmount    
  ,ItemSubtotal=invDet.ItemSubtotal            
  ,IntegrationStatus=@IntegrationStatus            
  ,Error=0            
  ,invDet.InvoiceType            
 into #INT_ALS_SalesInvoiceSourceTable            
 from INV_InvoiceDetail invDet            
 join INV_InvoiceSummary invSum            
 on invDet.InvoiceNo=invSum.InvoiceNo            
 where invDet.InvoiceType like '%Uniform%'            
 and invSum.invoiceno=@invoiceno            
            
 insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)            
 select             
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error            
 from #INT_ALS_SalesInvoiceSourceTable            
            
 -----------payment processing            
     
 select @InvoiceTypeCount=count(InvoiceType) from #INT_ALS_SalesInvoiceSourceTable             
 select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_ALS_SalesInvoiceSourceTable            
            
 --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.            
 --Bank Transfer =5            
 --Check=5            
 --Cash=4            
 --Visa=6            
              
 if(@InvoiceTypeCount>1)            
 begin            
  insert into INT_SalesPaymentSourceTable            
  (            
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,            
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error            
  )            
  select             
   SeqNum            
   ,SOPNumber            
   ,SOPType            
   ,PaymentType            
   ,PaymentAmount     
   ,CheckbookID    
   ,CardName            
   ,CheckNumber            
   ,CreditCardNumber            
   ,AuthorizationCode            
   ,ExpirationDate            
   ,IntegrationStatus            
   ,Error            
  from             
  (            
   select top 1             
    SeqNum=1            
    ,SOPNumber=invoiceno            
    ,SOPType=3            
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end            
    ,PaymentAmount=@totalPayableAmount            
    ,CheckbookID=PaymentMethod    
    ,CardName=''         
    ,CheckNumber=PaymentReferenceNumber            
    ,CreditCardNumber=null            
    ,AuthorizationCode=null            
    ,ExpirationDate=null            
    ,IntegrationStatus=0            
    ,Error=null            
   from als_live.dbo.INV_InvoicePayment            
   where invoiceno=@invoiceno            
  )t  
 end            
 else            
 begin            
  insert into INT_SalesPaymentSourceTable            
  (            
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,            
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error            
  )            
  select  
   SeqNum            
   ,SOPNumber            
   ,SOPType            
   ,PaymentType            
   ,PaymentAmount    
   ,CheckbookID    
   ,CardName            
   ,CheckNumber            
   ,CreditCardNumber            
   ,AuthorizationCode            
   ,ExpirationDate            
   ,IntegrationStatus            
   ,Error            
  from             
  (            
   select            
    SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)            
    ,SOPNumber=invoiceno            
    ,SOPType=3            
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end            
    ,PaymentAmount=@totalPayableAmount            
    ,CheckbookID=PaymentMethod    
    ,CardName=''            
    ,CheckNumber=PaymentReferenceNumber            
    ,CreditCardNumber=null            
    ,AuthorizationCode=null            
    ,ExpirationDate=null            
    ,IntegrationStatus=0            
    ,Error=null            
   from INV_InvoicePayment            
   where invoiceno=@invoiceno             
  )t       
 end  
  
 --payment information can be multiple with their debit account number and payment amount    
    
 declare @UniformDebitAccount nvarchar(50)=''    
 declare @UniformCreditAccount nvarchar(50)=''    
    
 declare @VATDebitAccount nvarchar(50)=''    
 declare @VATCreditAccount nvarchar(50)=''    
    
 select top 1    
  @VATDebitAccount=vat.DebitAccount,    
  @VATCreditAccount=vat.CreditAccount     
 from tblVatMaster vat    
 inner join tblFeeTypeMaster fee     
 on vat.FeeTypeId=fee.FeeTypeId    
 where vat.IsActive=1 and vat.IsDeleted=0    
 and FeeTypeName like '%UNIFORM%'    
    
 select top 1     
  @UniformDebitAccount=DebitAccount,    
  @UniformCreditAccount=CreditAccount     
 from tblFeeTypeMaster    
 where FeeTypeName like '%UNIFORM%'    
    
 declare @TotalTaxableAmount decimal(18,2)=0    
 declare @TotalTaxAmount decimal(18,2)=0    
   
 select   
  @TotalTaxableAmount =sum(ItemSubtotal), @TotalTaxAmount=sum(TaxAmount)   
 from INV_InvoiceDetail where invoiceno=@invoiceno      
   
 set @TotalTaxableAmount =@TotalTaxableAmount -@TotalTaxAmount -- total payment +tax +taxable amount    
    
 ---Add credit side-- taxable amount with uniform credit account    
 insert into INT_SalesDistributionSourceTable    
 (  
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error  
 )    
 select    
  SeqNum=1 -- only 1 row will push            
  ,SOPNumber=@invoiceno    
  ,SOPType=3       
  ,DistType=1    
  ,AccountNumber=@UniformCreditAccount    
  ,DebitAmount= 0    
  ,CreditAmount=@TotalTaxableAmount    
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))    
  ,IntegrationStatus=0            
  ,Error=null       
    
 ---Add credit side-- VAT amount with VAT credit account    
 insert into INT_SalesDistributionSourceTable    
 (  
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error  
 )    
 select    
  SeqNum=2 -- only 1 row will push            
  ,SOPNumber=@invoiceno    
  ,SOPType=3       
  ,DistType=1    
  ,AccountNumber=@VATCreditAccount    
  ,DebitAmount=0     
  ,CreditAmount=@TotalTaxAmount    
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))    
  ,IntegrationStatus=0            
  ,Error=null       
     
 -- Debit record will be added for payment method    
 ---Add credit side-- from payment method     
 --Multiple record as per payment category    
 insert into INT_SalesDistributionSourceTable    
 (  
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error  
 )    
 select    
  SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)      +2      
  ,SOPNumber=invoiceno    
  ,SOPType=3    
  ,DistType=3    
  ,AccountNumber=pm.CreditAccount    
  ,DebitAmount=PaymentAmount    
  ,CreditAmount=0    
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))    
  ,IntegrationStatus=0            
  ,Error=null    
 from INV_InvoicePayment tp    
 join tblPaymentMethod pm    
 on tp.PaymentMethod=pm.PaymentMethodName OR tp.PaymentMethodId=pm.PaymentMethodId    
 where invoiceno=@invoiceno    
    
 declare @FromDateRange Datetime = '01/01/1900'        
 declare @ToDateRange Datetime = '01/01/1900'            
        
 --exec INT_CreateSalesInvoiceInGP @CallFrom=1, @SourceDB='als_live',@DestDB= @DestinationDB,@FromDate = @FromDateRange ,@ToDate = @ToDateRange        
        
 select     
  @FromDateRange= InvoiceDate,    
  @ToDateRange= InvoiceDate     
 from INV_InvoiceSummary invSum            
 where invSum.invoiceno=@invoiceno    
    
 DECLARE @sql AS NVARCHAR(MAX)        
    
 /*        
 Use sp_executesql to dynamically pass in the db and stored procedure        
 to execute while also defining the values and assigning to local variables.        
 */        
 SET @sql = N'EXEC ' + @DestinationDB + '.dbo.[INT_CreateSalesInvoiceInGP] @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'        
 EXEC sp_executesql @sql        
 , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '        
 , @CallFrom = 0        
 , @SourceDB = @SourceDBName        
 , @DestDB = @DestinationDB        
 , @FromDate = @FromDateRange        
 , @ToDate = @ToDateRange        
        
 print @sql       
     
  select 0 result    
  
  SELECT
   CallFrom = 0        
 , SourceDB = @SourceDBName        
 , DestDB = @DestinationDB        
 , FromDate = @FromDateRange        
 , ToDate = @ToDateRange  

 end TRY          
 begin catch  
  SELECT -1 AS Result, 'Error!' AS Response      
  EXEC usp_SaveErrorDetail      
  select* from tblErrors          
  end catch  
end
GO
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

	SELECT 
		ISNULL(SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyEntranceRevenue,
		ISNULL(SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyUniformRevenue,
		ISNULL(SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyTuitionRevenue
	FROM INV_InvoiceDetail
	WHERE DATEPART(YEAR, CAST(UpdateDate AS DATE)) = DATEPART(YEAR, CAST(GETDATE() AS DATE))
		AND DATEPART(MONTH, CAST(UpdateDate AS DATE)) = DATEPART(MONTH, CAST(GETDATE() AS DATE))


	--exec [sp_getInvoiceData]
	--select AdmissionYear, AdmissionDate ,DATEPART(year, cast(AdmissionDate as date)) from tblStudent

	--update tblStudent
	--set AdmissionYear=DATEPART(year, cast(AdmissionDate as date))

end
GO
ALTER PROC [dbo].[SP_FeeStatement]
@AcademicYearId bigint
,@StudentId bigint
,@ParentId bigint
as
--declare @AcademicYearId bigint=2008
--declare @StudentId bigint=80
--declare @ParentId bigint=0

--set @AcademicYearId =2008
--set @StudentId =80
--set @ParentId =0

declare @AcademicYear_PeriodFrom	datetime
declare @AcademicYear_PeriodTo datetime
--select * from tblSchoolAcademic

select top 1 @AcademicYear_PeriodFrom=PeriodFrom, @AcademicYear_PeriodTo=PeriodTo from tblSchoolAcademic where SchoolAcademicId=@AcademicYearId

select * into #Previous_tblSchoolAcademic from tblSchoolAcademic where cast(PeriodTo as date)<cast(@AcademicYear_PeriodFrom as date)

--select '#Previous_tblSchoolAcademic ' as AA,  * from #Previous_tblSchoolAcademic 

select StudentId into #StudentTable from tblStudent where (StudentId =@StudentId OR ParentId=@ParentId)

SELECT StudentId,FeeTypeName,RecordDate,sum(FeeAmount) as FeeAmount,sum(OpeningAmount ) as OpeningAmount 
FROM 
(
	--previous academic record
	SELECT StudentId,AcademicYearId,'TUITION FEE -OPENING BALANCE' as FeeTypeName,0 as FeeAmount, FeeAmount  as OpeningAmount,CAST (UpdateDate AS DATE) AS RecordDate 
	from tblStudentFeeDetail where StudentId in (select StudentId from #StudentTable) and AcademicYearId in (select SchoolAcademicId from #Previous_tblSchoolAcademic) and IsActive=1 and IsDeleted=0
	UNION ALL
	SELECT StudentId,AcademicYear as AcademicYearId,'TUITION FEE -OPENING BALANCE ' as FeeTypeName,0 as FeeAmount,(TaxableAmount*-1) as OpeningAmount,CAST (UpdateDate AS DATE) AS RecordDate 
	from INV_InvoiceDetail where StudentId in (select StudentId from #StudentTable) and AcademicYear in (select SchoolAcademicId from #Previous_tblSchoolAcademic)

	UNION ALL
	---Current Academic record
	SELECT StudentId,AcademicYearId,'TUITION FEE ' as FeeTypeName, FeeAmount  as FeeAmount, 0 as OpeningAmount,CAST (UpdateDate AS DATE) AS RecordDate  
	FROM tblStudentFeeDetail 
	WHERE StudentId in (select StudentId from #StudentTable) and AcademicYearId=@AcademicYearId and IsActive=1 and IsDeleted=0
	
	UNION ALL
	
	SELECT StudentId,AcademicYear as AcademicYearId,'TUITION FEE ' as FeeTypeName,(TaxableAmount*-1) as FeeAmount , 0 as OpeningAmount,CAST (UpdateDate AS DATE) AS RecordDate  
	from INV_InvoiceDetail where StudentId in (select StudentId from #StudentTable) and AcademicYear=@AcademicYearId
)t
GROUP BY StudentId,FeeTypeName,RecordDate
order by t.RecordDate

drop table #Previous_tblSchoolAcademic 
drop table #StudentTable

--sp_tables '%fee%'
GO
ALTER PROCEDURE [dbo].[sp_CSVUniformRevenueExport]    
    @ItemCode nvarchar(100)=null
   ,@InvoiceNo bigint = 0
   ,@ParentName nvarchar(100)=null
   ,@FatherMobile nvarchar(100)=null
   ,@PaymentMethod nvarchar(100)=null
   ,@PaymentReferenceNumber nvarchar(100)=null
   ,@StartDate datetime=null
   ,@EndDate datetime=null
 AS                            
BEGIN      
EXEC SP_UniformSalesReport    
    @ItemCode
   ,@InvoiceNo    
   ,@ParentName    
   ,@FatherMobile  
   ,@PaymentMethod   
   ,@PaymentReferenceNumber
   ,@StartDate
   ,@EndDate     
END
GO
CREATE PROCEDURE [dbo].[sp_CSVallrevenueexport]    
  @ParentId int=0
 ,@ParentName nvarchar(250)=null
 ,@FatherIqama nvarchar(250)=null
 ,@StudentName nvarchar(250)=null
 ,@AcademicYear int=0
 ,@InvoiceNo BigInt=0
 ,@StartDate datetime=null
 ,@EndDate datetime=null
 AS                            
BEGIN      
EXEC SP_AllRevenueReport
	@ParentId    
	,@ParentName    
	,@FatherIqama    
	,@StudentName    
	,@AcademicYear    
	,@InvoiceNo    
	,@StartDate
	,@EndDate     
END
GO
CREATE PROC [dbo].[SP_TotalRevenueReport] 
(
  @ParentId int=0
 ,@ParentName nvarchar(250)=null
 ,@FatherIqama nvarchar(250)=null
 ,@StudentName nvarchar(250)=null
 ,@AcademicYear int=0
 ,@InvoiceNo BigInt=0
 ,@StartDate datetime=null
 ,@EndDate datetime=null
)
AS
BEGIN

    SELECT 
        ParentId,
        ParentName,
        FatherMobile,
        IqamaNumber,
        StudentId,
        StudentName,
        GradeName,
        AcademicYear,
        IsStaff,
        TaxableAmount = SUM(TaxableAmount),
        TaxAmount = SUM(TaxAmount),
        ItemSubtotal = SUM(ItemSubtotal),
        InvoiceType,
        InvoiceDate,
        InvoiceNo,
        PaymentMethod,
        PaymentReferenceNumber
    FROM
    (
        SELECT 
            ParentId = ISNULL(invDet.ParentId, 0),
            invDet.ParentName,
            invDet.FatherMobile,
            StudentId = ISNULL(invDet.StudentId, 0),
            StudentName = ISNULL(invDet.StudentName, ''),
            tgm.GradeName,
            tsa.AcademicYear,
            invDet.IqamaNumber,
            invDet.IsStaff,
            invDet.TaxableAmount, 
            invDet.TaxAmount, 
            invDet.ItemSubtotal,
            invDet.InvoiceType,
            invSum.InvoiceNo,
            invSum.InvoiceDate,
            invPay.PaymentMethod,
             invPay.PaymentReferenceNumber
        FROM INV_InvoiceSummary invSum
        JOIN INV_InvoiceDetail invDet ON invSum.InvoiceNo = invDet.InvoiceNo
        JOIN tblGradeMaster tgm ON invDet.GradeId = tgm.GradeId
        JOIN tblSchoolAcademic tsa ON invDet.AcademicYear = tsa.SchoolAcademicId
        JOIN INV_InvoicePayment invPay ON invDet.InvoiceNo = invPay.InvoiceNo
        WHERE 
        invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END  
		AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'  
		AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%' 
		AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%' 
		AND invDet.AcademicYear = CASE WHEN @ParentId > 0 THEN @AcademicYear ELSE invDet.AcademicYear END  
		AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END  
		--AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))              
		--AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))    
    ) t
    GROUP BY  
        ParentId,
        ParentName,
        FatherMobile,
        IqamaNumber,
        StudentId,
        StudentName,
        GradeName,
        AcademicYear,
        IsStaff,
        InvoiceType,
        InvoiceDate,
        InvoiceNo,
        PaymentMethod,
        PaymentReferenceNumber
END
GO
CREATE PROCEDURE [dbo].[sp_CSVTotalRevenueExport]    
  @ParentId int=0
 ,@ParentName nvarchar(250)=null
 ,@FatherIqama nvarchar(250)=null
 ,@StudentName nvarchar(250)=null
 ,@AcademicYear int=0
 ,@InvoiceNo BigInt=0
 ,@StartDate datetime=null
 ,@EndDate datetime=null
 AS                            
BEGIN      
EXEC SP_TotalRevenueReport    
	@ParentId    
	,@ParentName    
	,@FatherIqama    
	,@StudentName    
	,@AcademicYear    
	,@InvoiceNo    
	,@StartDate
	,@EndDate     
END
GO
CREATE PROCEDURE [dbo].[sp_CSVdiscountreportexport]    
   @ParentId INT=0
 ,@ParentName NVARCHAR(200)=null
 ,@FatherIqama NVARCHAR(200)=null
 ,@StudentName NVARCHAR(100)=null
 ,@AcademicYearId INT=0
 ,@StartDate DATETIME=null
 ,@EndDate DATETIME=null
 AS                            
BEGIN      
	EXEC SP_DiscountReport    
		@ParentId
	   ,@ParentName    
	   ,@FatherIqama    
	   ,@StudentName  
	   ,@AcademicYearId   
	   ,@StartDate
	   ,@EndDate     
END
GO
CREATE proc [dbo].[SP_AllRevenueReport]
(
  @ParentId int=0
 ,@ParentName nvarchar(250)=null
 ,@FatherIqama nvarchar(250)=null
 ,@StudentName nvarchar(250)=null
 ,@AcademicYear int=0
 ,@InvoiceNo BigInt=0
 ,@StartDate datetime=null
 ,@EndDate datetime=null
)
AS
BEGIN
	SELECT 
		 ParentId
		,ParentName
		,FatherMobile
		,IqamaNumber
		,StudentId
		,StudentName
		,GradeName
		,CostCenter=CostCenterName
		,AcademicYear
		,IsStaff
		,TaxableAmount=SUM(TaxableAmount)
		,TaxAmount=SUM(TaxAmount)
		,ItemSubtotal=SUM(ItemSubtotal)
		,InvoiceType
		,InvoiceDate
		,InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber
	INTO #AllRevenuTbl
	FROM
	(
		SELECT 
			 ParentId=ISNULL(tp.ParentCode,0)
             ,invDet.ParentName
			,invDet.FatherMobile
			,StudentId = ISNULL(ts.StudentCode,0)
			,StudentName=ISNULL(invDet.StudentName,'')
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
			,tcc.CostCenterName
		FROM INV_InvoiceSummary invSum
		INNER JOIN INV_InvoiceDetail invDet ON invSum.InvoiceNo=invDet.InvoiceNo
		INNER JOIN INV_InvoicePayment AS invPay ON invDet.InvoiceNo = invPay.InvoiceNo
		LEFT JOIN tblGradeMaster AS tgm ON invDet.GradeId = tgm.GradeId
		LEFT JOIN tblSchoolAcademic AS tsa ON invDet.AcademicYear = tsa.SchoolAcademicId		
		LEFT JOIN tblParent tp ON tp.ParentId=invDet.ParentId
		LEFT JOIN tblStudent ts ON ts.StudentId=invDet.StudentId
		LEFT JOIN tblCostCenterMaster tcc ON tcc.CostCenterId=ts.CostCenterId
		WHERE --invDet.InvoiceType = 'Tuition Fee'
		--AND 
		invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END  
		AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'  
		AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%' 
		AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%' 
		AND invDet.AcademicYear = CASE WHEN @ParentId > 0 THEN @AcademicYear ELSE invDet.AcademicYear END  
		AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END  
		AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))              
		AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))         
	)t
	GROUP BY  ParentId,
        ParentName,
        FatherMobile,
        IqamaNumber,
		StudentId,
        StudentName,
        GradeName,
        AcademicYear,
        IsStaff,
         InvoiceType
		,InvoiceDate
		,InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber
		,CostCenterName

	SELECT  ParentId
		,ParentName
		,IqamaNumber
		,StudentId
		,StudentName
		,GradeName
		,CostCenter
		,AcademicYear
		,FatherMobile
		,IsStaff
		,InvoiceType
		,InvoiceNo=CAST(InvoiceNo AS NVARCHAR(100)) 
		,InvoiceDate=CONVERT(NVARCHAR(20),InvoiceDate,103) 
		,TaxableAmount=FORMAT(TaxableAmount,'#,0.00')
		,TaxAmount=FORMAT(TaxAmount,'#,0.00')
		,ItemSubtotal=FORMAT(ItemSubtotal,'#,0.00')
		,PaymentMethod
		,PaymentReferenceNumber 
		FROM  #AllRevenuTbl
	UNION ALL
	SELECT   ParentId=' '
		,ParentName=' '
		,IqamaNumber=' '
		,StudentId=' '
		,StudentName=' '
		,GradeName=' '
		,CostCenter=' '
		,AcademicYear=' '
		,FatherMobile=' '
		,IsStaff=' '
		,InvoiceType=' '
		,InvoiceNo=' '
		,InvoiceDate='Total'
		,TaxableAmount=FORMAT(SUM(TaxableAmount),'#,0.00')
		,TaxAmount=FORMAT(SUM(TaxAmount),'#,0.00')
		,ItemSubtotal=FORMAT(SUM(ItemSubtotal),'#,0.00')
		,PaymentMethod=' '
		,PaymentReferenceNumber =' '
		FROM  #AllRevenuTbl
	DROP TABLE IF EXISTS #AllRevenuTbl; 
END
GO
CREATE PROCEDURE [dbo].[sp_ProcessGP]  
  @invoiceno bigint=0   ,        
  @DestinationDB nvarchar(50) = ''             
AS        
BEGIN        
	
 ----Process GP integration  
 exec [sp_ProcessGP_UniformInvoice] @invoiceno,@DestinationDB  
      
end
GO
