DROP PROCEDURE IF EXISTS [sp_ReportStudentStatement]
GO

CREATE PROCEDURE [dbo].[sp_ReportStudentStatement]        
 @AcademicYearId int  =0    
 ,@ParentId int      
 ,@StudentId int      
AS        
BEGIN    
 DECLARE @AcademicYear_PeriodFrom DATETIME    
 DECLARE @AcademicYear NVARCHAR(500)      
     
 SELECT TOP 1 @AcademicYear_PeriodFrom=PeriodFrom     
 FROM tblSchoolAcademic     
 WHERE @AcademicYearId = 0     
  OR SchoolAcademicId=@AcademicYearId    
 ORDER BY PeriodFrom ASC    
    
 IF(@AcademicYearId=0)    
  SET @AcademicYear_PeriodFrom= CAST('1/1/1990' AS DATETIME)    
    
 SELECT * INTO #Previous_tblSchoolAcademic     
 FROM tblSchoolAcademic     
 WHERE CAST(PeriodTo AS DATE)<CAST(@AcademicYear_PeriodFrom AS DATE)     
  AND IsActive=1 AND IsDeleted=0    
    
 SELECT TOP 1 @AcademicYear=AcademicYear     
 FROM #Previous_tblSchoolAcademic     
 ORDER BY PeriodTo DESC    
        
 SELECT StudentId INTO #StudentTable     
 FROM tblStudent     
 WHERE StudentId = @StudentId     
  OR (@StudentId=0 AND ParentId=@ParentId)    
    
 -- Student Opening Fees Balance        
 SELECT StudentId    
  ,RecordDate    
  ,FeeTypeName    
  ,FeeAmount=SUM(ISNULL(FeeAmount,0))    
  ,PaidAmount=SUM(ISNULL(PaidAmount,0))        
 INTO #StudentOpeningFeesBalance       
 FROM        
 (        
  SELECT StudentId    
  ,NULL AS RecordDate    
  ,'TUITION FEE -OPENING BALANCE' AS FeeTypeName    
  ,ISNULL(FeeAmount,0) AS FeeAmount    
  ,ISNULL(PaidAmount,0) AS PaidAmount      
  FROM tblFeeStatement      
  WHERE StudentId IN (SELECT StudentId FROM #StudentTable)         
  AND AcademicYearId IN (SELECT SchoolAcademicId FROM #Previous_tblSchoolAcademic)         
  AND IsActive=1 AND IsDeleted=0        
 )t        
 GROUP BY StudentId,RecordDate,FeeTypeName    
      
 DECLARE @OpeningBalance DECIMAL(18,2)=0        
 DECLARE @TotalFeeAmount DECIMAL(18,2)=0        
 DECLARE @TotalPaidAmount DECIMAL(18,2)=0        
        
 SELECT @TotalFeeAmount=SUM(FeeAmount) FROM #StudentOpeningFeesBalance       
 SELECT @TotalPaidAmount=SUM(PaidAmount) FROM #StudentOpeningFeesBalance        
        
 SET @OpeningBalance=@TotalFeeAmount-@TotalPaidAmount        
    
 DECLARE @StudentName NVARCHAR(100)    
     
 SELECT TOP 1 @StudentName= StudentName     
 FROM tblStudent     
 WHERE StudentId= @StudentId    
     
 SELECT @StudentId AS StudentId    
  ,ISNULL(@StudentName,'') AS StudentName    
  ,'' AS InvoiceNo      
  ,'' AS PaymentMethod      
  ,@AcademicYear AS AcademicYear      
  ,NULL AS RecordDate,     
  'TUITION FEE -OPENING BALANCE' AS FeeTypeName    
  ,FeeAmount= CASE WHEN @OpeningBalance>0 THEN @OpeningBalance ELSE 0 END    
  ,PaidAmount= CASE WHEN @OpeningBalance< 0 THEN @OpeningBalance ELSE 0 END    
  ,BalanceAmount=0    
    ,StudentCode =''  
    ,GradeName=''  
 UNION ALL      
 SELECT fs.StudentId      
  ,ts.StudentName      
  ,InvoiceNo      
  ,PaymentMethod      
  ,sa.AcademicYear      
  ,fs.UpdateDate AS RecordDate      
  ,FeeStatementType AS FeeTypeName      
  ,FeeAmount      
  ,PaidAmount      
  ,0 AS BalanceAmount    
    ,ts.StudentCode   
    ,gm.GradeName  
 FROM tblFeeStatement fs      
 INNER JOIN tblSchoolAcademic sa ON sa.SchoolAcademicId=fs.AcademicYearId      
 INNER JOIN tblStudent ts      on fs.StudentId=ts.StudentId  
  join tblGradeMaster gm on ts.GradeId=gm.GradeId  
 WHERE fs.StudentId in (SELECT StudentId from #StudentTable)         
 AND (@AcademicYearId=0 OR fs.AcademicYearId IN (@AcademicYearId))    
 AND fs.IsActive=1         
 AND fs.IsDeleted=0     
    
 DROP TABLE #Previous_tblSchoolAcademic        
 DROP TABLE #StudentTable        
 DROP TABLE #StudentOpeningFeesBalance        
END 
GO

DROP PROCEDURE IF EXISTS [SP_GetStudentParentWise]
GO

CREATE PROCEDURE [dbo].[SP_GetStudentParentWise]        
 @ParentId bigint=0        
 ,@ParentName NVarChar(500)=null        
 ,@FatherIqama NVarChar(100)=null        
 ,@FatherMobile NVarChar(20)=null        
AS        
BEGIN        
 SELECT ts.StudentId        
  ,ts.StudentCode        
  ,ts.StudentName        
  ,tp.ParentId        
  ,tp.FatherName        
  ,tp.FatherIqamaNo        
  ,tp.FatherMobile        
  ,gm.GradeName  
 FROM tblStudent ts        
 INNER JOIN tblParent tp ON ts.ParentId=tp.ParentId        
 join tblGradeMaster gm on ts.GradeId=gm.GradeId  
 WHERE tp.ParentId = CASE WHEN @ParentId>0 THEN @ParentId ELSE tp.ParentId END        
 AND tp.FatherName = CASE WHEN LEN(@ParentName)>0 THEN @ParentName ELSE tp.FatherName END        
 AND tp.FatherIqamaNo = CASE WHEN LEN(@FatherIqama)>0 THEN @FatherIqama ELSE tp.FatherIqamaNo END        
 AND tp.FatherMobile = CASE WHEN LEN(@FatherMobile)>0 THEN @FatherMobile ELSE tp.FatherMobile END        
 AND ts.IsActive=1 and ts.IsDeleted=0    
 order by gm.SequenceNo  
END   
GO

DROP PROCEDURE IF EXISTS [sp_GetParentFeeBalance]
GO

CREATE PROCEDURE  [dbo].[sp_GetParentFeeBalance]  
 @ParentId bigint      
as  
begin  
 select   
  ParentId ,TotalFeeAmount ,TotalPaidAmount,TotalBalance= TotalFeeAmount -TotalPaidAmount  
 from   
 (  
  select ParentId ,TotalFeeAmount=sum(FeeAmount) ,TotalPaidAmount=sum(PaidAmount)   
  from tblFeeStatement  
  where ParentId = @ParentId   
  group by ParentId  
 )t  
end  
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

DROP PROCEDURE IF EXISTS [sp_GetInvoice]
GO

CREATE PROCEDURE [dbo].[sp_GetInvoice]  
 @InvoiceId bigint = 0,                        
 @Status nvarchar(50) = NULL,                        
 @InvoiceDateStart date = NULL,                        
 @InvoiceDateEnd date = NULL,                        
 @InvoiceType nvarchar(50) = NULL,                        
 @InvoiceNo nvarchar(50) = NULL,                        
 @ParentCode nvarchar(50) = NUll,                        
 @ParentName nvarchar(400) = NULL,                
 @FatherMobile nvarchar(200) = NULL,    
 @FatherIqama nvarchar(200) = NULL    
AS          
BEGIN                                  
SET NOCOUNT ON;                                   
 -------------Start: invoice summary                         
 SELECT                         
  tis.InvoiceId                        
  ,tis.InvoiceNo                        
  ,tis.InvoiceDate                        
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
 into #InvoiceSummary2                
 FROM INV_InvoiceSummary tis                                                    
 WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                        
 AND (@Status IS NULL OR tis.[Status] = @Status)                        
 AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                        
 AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                        
 AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                        
 AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                        
 AND tis.IsDeleted = 0    
    
 SELECT        
  tis.InvoiceNo           
  ,TaxableAmount=sum(tis.TaxableAmount)        
  ,TaxAmount=sum(tis.TaxAmount)        
  ,ItemSubtotal=sum(tis.ItemSubtotal)        
 into #InvoiceDetail        
 from INV_InvoiceDetail tis        
 join #InvoiceSummary2 invSum on tis.InvoiceNo=invSum.InvoiceNo        
 where (@FatherIqama IS NULL OR tis.IqamaNumber like '%'+ @FatherIqama+'%')        
 group by tis.InvoiceNo     
    
 select     
  ROW_NUMBER() over(partition by ins.InvoiceNo order by  ins.InvoiceNo desc) as RN       
  ,ins.InvoiceNo      
  ,InvoiceTypeValue=          
  (    
   select REPLACE(STUFF(CAST((                
   SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))                
   FROM (                 
     SELECT distinct scm.InvoiceType                    
     FROM INV_InvoiceDetail AS scm                      
     WHERE scm.InvoiceNo = ins.InvoiceNo  
    ) c                
   FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')        
  )       
 into #InvoiceTypeDetail    
 from       
 #InvoiceSummary2 ins     
    
 delete from #InvoiceTypeDetail where RN>1    
    
 ----Get Max payemtn info      
 select        
  ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN                
  ,tis.InvoiceNo           
  ,tis.PaymentReferenceNumber      
  ,tis.PaymentMethod      
 into #InvoicePayment        
 from INV_InvoicePayment tis        
 join #InvoiceSummary2 invSum        
 on tis.InvoiceNo=invSum.InvoiceNo        
      
 delete from #InvoicePayment where RN>1      
    
 select     
  ins.*    
  ,indt.InvoiceTypeValue    
  ,ind.ItemSubtotal,ind.TaxableAmount,ind.TaxAmount,    
  inp.PaymentMethod,inp.PaymentReferenceNumber    
 into #InvoiceSummary    
 from     
 #InvoiceSummary2 ins    
 join #InvoiceTypeDetail indt on ins.InvoiceNo=indt.InvoiceNo      
 join #InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo      
 join #InvoicePayment inp on ins.InvoiceNo=inp.InvoiceNo      
     
 -------------End invoice summary     
     
 -------------Start parent Info    
 ---- Tuition fee    
 select     
  ROW_NUMBER() over(partition by ins.InvoiceNo  order by par.ParentId desc,  tis.StudentId asc) as RN            
  ,tis.InvoiceNo,ParentId=isnull(tis.ParentId, par.ParentId)    
  ,ParentName=isnull(tis.ParentName,par.FatherName)    
  ,FatherMobile=isnull(tis.FatherMobile,par.FatherMobile)    
  ,ParentCode=isnull(tis.ParentCode,par.ParentCode)    
  ,StudentName=isnull(tis.StudentName,stu.StudentName)     
  ,StudentId=isnull(tis.StudentId,stu.StudentId)    
  ,StudentCode=isnull(tis.StudentCode,stu.StudentCode)     
 into #InvoiceParentInfoTuitionFee    
 from INV_InvoiceDetail tis        
 join #InvoiceSummary ins on tis.InvoiceNo=ins.InvoiceNo     
 left join tblParent par on tis.ParentId=par.ParentId  OR tis.ParentCode=par.ParentCode  
 left join tblStudent stu on tis.StudentId=stu.StudentId    
 where tis.InvoiceType like '%tuition%'    
 and tis.ParentId>0    
    
 delete from #InvoiceParentInfoTuitionFee where RN>1    
    
 select     
  ROW_NUMBER() over(partition by ins.InvoiceNo  order by  tis.StudentId asc) as RN            
  ,tis.InvoiceNo,ParentId, StudentName ,ParentName, FatherMobile ,StudentId,StudentCode ,ParentCode    
 into #InvoiceParentInfoUniformFee    
 from INV_InvoiceDetail tis        
 join #InvoiceSummary ins    
 on tis.InvoiceNo=ins.InvoiceNo     
 where tis.InvoiceType not like '%tuition%'    
    
 delete from #InvoiceParentInfoUniformFee where RN>1    
       
 select           
  ins.CreditNo,ins.CreditReason,ins.CustomerName,ins.InvoiceDate,ins.InvoiceId,ins.InvoiceNo,ins.InvoiceRefNo  
  ,ins.InvoiceType,ins.InvoiceTypeValue,ins.IqamaNumber,ins.IsDeleted,ins.ItemSubtotal,ins.PaymentMethod  
  ,ins.PaymentReferenceNumber,ins.PublishedBy,ins.Status,ins.TaxableAmount,ins.TaxAmount,ins.UpdateBy  
  ,ins.UpdateDate  
  ,ParentID=cast( isnull(ind.ParentID  ,null) as nvarchar(100))              
  ,ParentName=isnull(ind.ParentName  ,null)              
  ,FatherMobile=isnull(ind.FatherMobile  ,null)              
  ,ParentCode=isnull(ind.ParentCode  ,null)    
  ,StudentId=isnull(isnull(ind.StudentId  ,null),'')    
  ,StudentName=case when ins.InvoiceTypeValue like '%Uniform %' then null else isnull(ind.StudentName  ,'')    end          
  ,StudentCode=isnull(ind.StudentCode,'')    
 into #InvoiceSummaryFinal    
 from #InvoiceSummary ins    
 left join  #InvoiceParentInfoTuitionFee ind on ins.InvoiceNo=ind.InvoiceNo    
    
 -------------End parent Info    
    
 -------------Start Final Query    
 select           
  ins.InvoiceId ,ins.InvoiceNo ,ins.InvoiceDate ,ins.Status ,ins.PublishedBy   
  ,CreditNo=isnull(ins.CreditNo,'')   
  ,CreditReason=isnull(ins.CreditReason,'')   
  ,CustomerName=isnull(ins.CustomerName,'')  
  ,ins.IqamaNumber ,ins.IsDeleted ,ins.UpdateDate ,ins.UpdateBy ,ins.InvoiceType ,ins.InvoiceRefNo ,ins.InvoiceTypeValue     
  ,ins.ItemSubtotal ,ins.TaxableAmount ,ins.TaxAmount ,ins.PaymentMethod ,ins.PaymentReferenceNumber    
  ,ParentID=cast( isnull(isnull(ins.ParentID  , ind.ParentID)  ,0) as nvarchar(100))              
  ,ParentName=isnull(ins.ParentName  ,ind.ParentName)    
  ,FatherMobile=isnull(ins.FatherMobile  ,ind.FatherMobile)    
  ,ParentCode=isnull(isnull(ins.ParentCode  ,ind.ParentCode),'')  
  ,StudentId=isnull(ins.StudentId  ,ind.StudentId )              
  ,StudentName=case when ins.InvoiceTypeValue like '%Uniform %' then '' else isnull(ind.StudentName  ,'')    end          
  ,StudentCode=isnull(ind.StudentCode,'')    
 into #InvoiceSummaryFinal2    
 from #InvoiceSummaryFinal ins    
 left join  #InvoiceParentInfoUniformFee ind on ins.InvoiceNo=ind.InvoiceNo    
     
 SELECT  
 *   
 FROM #InvoiceSummaryFinal2    
 WHERE           
 --isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END          
 (@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )          
 and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )          
 and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )          
 --AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'            
 --AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'            
 ORDER BY InvoiceNo DESC     
     
 -------------End Final Query    
          
 drop table #InvoiceSummary    
 drop table #InvoiceSummary2    
 drop table #InvoiceDetail        
 drop table #InvoicePayment        
 drop table #InvoiceTypeDetail    
    
 drop table #InvoiceParentInfoTuitionFee    
 drop table #InvoiceParentInfoUniformFee    
 drop table #InvoiceSummaryFinal    
 drop table #InvoiceSummaryFinal2    
END  
GO

DROP PROCEDURE IF EXISTS [SP_MonthlyStatementParentStudent]
GO

CREATE PROCEDURE [dbo].[SP_MonthlyStatementParentStudent]    
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
  
 set @parentName='%'+@parentName+'%'    
 set @StudentName='%'+@StudentName+'%'    
    
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
   OR (@parentId=0 OR invDet.StudentId=@parentId)    
   OR (@AcademicYearId=0 OR invDet.AcademicYear=@parentId)    
   OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)    
   OR ((@StudentName is null OR @StudentName='' ) OR invDet.ParentName like @StudentName)    
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

DROP PROCEDURE IF EXISTS [SP_ParentStudentReport]
GO

CREATE PROC [dbo].[SP_ParentStudentReport]
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
	DROP TABLE IF EXISTS #GeneralTbl; 
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
AS                            
BEGIN      
EXEC SP_ParentStudentReport
		@ParentId
		,@StudentId
		,@AcademicYear
		,@CostCenter
		,@Grade
		,@Gender
END    
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
	SELECT SValue	,SText
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
END     
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


DROP PROCEDURE IF EXISTS [SP_DiscountReport]
GO

CREATE PROC [dbo].[SP_DiscountReport]
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