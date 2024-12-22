DROP PROCEDURE IF EXISTS [SP_UniformSalesReport]
GO

CREATE PROCEDURE  [dbo].[SP_UniformSalesReport]  
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
   ,invDet.InvoiceNo  
   ,invSum.InvoiceDate  
    ,invDet.ParentName  
   ,invDet.FatherMobile  
   ,invDet.Quantity  
   ,invDet.UnitPrice      
   ,invPay.PaymentMethod  
   ,invPay.PaymentReferenceNumber
   
    ,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END
	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

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

  UNION ALL 

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
 
  
 DROP TABLE IF EXISTS #UniformTbl;   
end  
GO

DROP PROCEDURE IF EXISTS [SP_TuitionFeeReport]
GO

CREATE PROCEDURE [dbo].[SP_TuitionFeeReport]  
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
  
   ,invSum.InvoiceNo  
   ,invSum.InvoiceDate  
   ,invPay.PaymentMethod  
   ,invPay.PaymentReferenceNumber  
   ,tcc.CostCenterName

    ,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END
	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

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
 
 UNION ALL 

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
 
  
 DROP TABLE IF EXISTS #TutionTbl;   
  
end  
GO

DROP PROCEDURE IF EXISTS [SP_EntranceFeesReport]
GO

CREATE PROCEDURE [dbo].[SP_EntranceFeesReport]  
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
    
   ,invSum.InvoiceNo  
   ,invSum.InvoiceDate  
   ,invPay.PaymentMethod  
   ,invPay.PaymentReferenceNumber  
   ,tcc.CostCenterName
   
   ,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END
	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

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
 
   UNION ALL  

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
 
 DROP TABLE IF EXISTS #EntranceTbl;   
end  
GO

DROP PROCEDURE IF EXISTS [SP_DiscountReport]
GO

CREATE PROCEDURE [dbo].[SP_DiscountReport]  
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

  UNION ALL 

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
 
 DROP TABLE IF EXISTS #DiscountTbl;   
END  
GO

DROP PROCEDURE IF EXISTS [sp_CSVadvancefeetuitionrevenueexport]
GO

CREATE PROCEDURE [dbo].[sp_CSVadvancefeetuitionrevenueexport]        
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
EXEC SP_AdvanceFeeReport        
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

	,invSum.InvoiceNo    
	,invSum.InvoiceDate    
	,invPay.PaymentMethod    
	,invPay.PaymentReferenceNumber  

	,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END
	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

  from INV_InvoiceSummary invSum    
  join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo    
  join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId    
  join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId  
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
   AND invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END      
   AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END    
   AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'      
   AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%'    
   AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%'      
   AND invDet.AcademicYear = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE invDet.AcademicYear END       
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
end    
GO

DROP PROCEDURE IF EXISTS [SP_MonthlyStatementParentStudent]
GO

CREATE PROCEDURE [dbo].[SP_MonthlyStatementParentStudent]    
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
      
   ,NameMonth=DATENAME(month, invSum.InvoiceDate)    
   ,NameYear=DATENAME(year, invSum.InvoiceDate)

	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

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
  )    
 )t    
 group by ParentId ,ParentName ,NameMonth ,NameYear   
    
end 
GO

DROP PROCEDURE IF EXISTS [SP_AllRevenueReport]
GO

CREATE PROCEDURE [dbo].[SP_AllRevenueReport]
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
			,IsStaff=CASE WHEN invDet.IsStaff=0 THEN 'True' ELSE 'False' END
			,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END
			,invSum.InvoiceNo
			,invSum.InvoiceDate
			,invPay.PaymentMethod
			,invPay.PaymentReferenceNumber
			,tcc.CostCenterName

			,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
			,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
			,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END
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
		
		UNION ALL

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
	
	DROP TABLE IF EXISTS #AllRevenuTbl; 
END
GO

DROP PROCEDURE IF EXISTS [sp_CSVInvoiceExport]
GO

CREATE PROCEDURE  [dbo].[sp_CSVInvoiceExport]          
  @InvoiceId bigint = 0,                      
  @Status nvarchar(50) = NULL,                      
  @InvoiceDateStart date = NULL,                      
  @InvoiceDateEnd date = NULL,                      
  @InvoiceType nvarchar(50) = NULL,                      
  @InvoiceNo nvarchar(50) = NULL,                      
  @ParentCode nvarchar(50) = NUll,                      
  @ParentName nvarchar(400) = NULL,              
  @FatherMobile nvarchar(200) = NULL  ,    
 @FatherIqama nvarchar(200) = NULL          
 AS        
 BEGIN                                  
	SET NOCOUNT ON;                                   
                   
	SELECT                         
		tis.InvoiceId                        
		,tis.InvoiceNo                        
		,InvoiceDate= convert(varchar, tis.InvoiceDate, 103)           
		,tis.Status                        
		,tis.PublishedBy                        
		,tis.CreditNo                        
		,tis.CreditReason                        
		,tis.CustomerName                    
		,tis.IqamaNumber        
		,tis.IsDeleted                        
		,tis.UpdateDate                        
		,tis.UpdateBy                       
		,InvoiceType=isnull(tis.InvoiceType,'Invoice')      
		,tis.InvoiceRefNo      
	into #InvoiceSummary                
	FROM INV_InvoiceSummary tis                               
	--LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId                           
	WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                        
	AND (@Status IS NULL OR tis.[Status] = @Status)                        
	AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                        
	AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                        
	AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                        
	AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                        
	AND tis.IsDeleted = 0               
        
	select        
		tis.InvoiceNo           
		,TaxableAmount=sum(tis.TaxableAmount)        
		,TaxAmount=sum(tis.TaxAmount)        
		,ItemSubtotal=sum(tis.ItemSubtotal)        
	into #InvoiceDetail        
	from INV_InvoiceDetail tis        
	join #InvoiceSummary invSum        
	on tis.InvoiceNo=invSum.InvoiceNo        
	where (@FatherIqama IS NULL OR tis.IqamaNumber like '%'+ @FatherIqama+'%')        
	group by tis.InvoiceNo       
                        
	select             
		t.InvoiceNo, t.ParentID,t.ParentName,t.FatherMobile,t.ParentCode,t.StudentId,t.StudentName,t.StudentCode,t.InvoiceTypeValue,              
		ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo, t.ParentCode desc) as RN                
	into #INDMobile                
	from                
	(                
		select distinct                 
			ins.InvoiceNo              
			,ParentID= tp.ParentID             
			,ParentName= tp.ParentName
			,FatherMobile= tp.FatherMobile
			,ParentCode= tp.ParentCode
			,StudentId= case when ts.StudentId is null then ind.StudentId  else ts.StudentId end              
			,StudentName=case when tp.InvoiceType like '%Uniform%' then '' else        
			case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName          
			else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS         
			end             
			end        
			,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end                
                 
			,InvoiceTypeValue=
			(
				select 
					REPLACE(
					STUFF
					(
					CAST
					(
						(
							SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX)) 
							FROM 
							(
								SELECT distinct scm.InvoiceType FROM INV_InvoiceDetail AS scm WHERE scm.InvoiceNo = ins.InvoiceNo 
							) c FOR XML PATH(''), TYPE
						) 
					AS VARCHAR(MAX))
				, 1, 2, ''),' ',' ')        
			)
		from                 
		#InvoiceSummary ins 
		JOIN vw_InvoiceParentInfo tp ON ins.InvoiceNo = tp.InvoiceNo  
		join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo                
		LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId      

		where @ParentCode IS NULL OR (tp.ParentCode=CASE WHEN @ParentCode='' THEN tp.ParentCode ELSE @ParentCode END)
		AND @FatherMobile IS NULL OR(tp.FatherMobile=CASE WHEN  @FatherMobile='' THEN ind.FatherMobile ELSE @FatherMobile END)
		AND @ParentName IS NULL OR (tp.ParentName like '%' + CASE WHEN @ParentName='' THEN tp.ParentName ELSE @ParentName END +'%')
		AND ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0                
	)t          
   
 delete from #INDMobile where RN>1    
 
      
 ----Get Max payemtn info      
 select        
 ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN                
 ,tis.InvoiceNo           
 ,tis.PaymentReferenceNumber      
 ,tis.PaymentMethod      
 into #InvoicePayment        
 from INV_InvoicePayment tis        
 join #InvoiceSummary invSum        
 on tis.InvoiceNo=invSum.InvoiceNo        
      
  delete from #InvoicePayment where RN>1          
            
 select           
  ins.*        
       
  ,ParentID=cast( isnull(ind.ParentID  ,'') as nvarchar(100))              
  ,ParentName=isnull(ind.ParentName  ,'')              
  ,FatherMobile=isnull(ind.FatherMobile  ,'')              
  ,ParentCode=isnull(ind.ParentCode  ,'')              
  ,StudentId=isnull(ind.StudentId  ,'')              
  ,StudentName=isnull(ind.StudentName  ,'')              
  ,StudentCode=isnull(ind.StudentCode,'')              
  ,InvoiceTypeValue=ind.InvoiceTypeValue      
  ,indPay.PaymentMethod      
  ,indPay.PaymentReferenceNumber    
    
    
  ,TaxableAmount= case when ins.InvoiceType='Return' then invDet.TaxableAmount*-1 else invDet.TaxableAmount end   
  ,TaxAmount= case when ins.InvoiceType='Return' then invDet.TaxAmount *-1 else invDet.TaxAmount end  
   ,ItemSubtotal= case when ins.InvoiceType='Return' then invDet.ItemSubtotal *-1 else invDet.ItemSubtotal end  
  
 from #InvoiceSummary ins         
 join #InvoiceDetail invDet on ins.InvoiceNo=invDet.InvoiceNo        
 left join  #INDMobile ind on ins.InvoiceNo=ind.InvoiceNo        
  left join  #InvoicePayment indPay on ins.InvoiceNo=indPay.InvoiceNo           
 WHERE           
 --isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END          
  (@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )          
 and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )          
 and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )          
 --AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'            
 --AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'            
  ORDER BY ins.InvoiceNo DESC               
          
          
 drop table #InvoiceSummary              
 drop table #INDMobile        
 drop table #InvoiceDetail        
drop table #InvoicePayment      

END      
GO

