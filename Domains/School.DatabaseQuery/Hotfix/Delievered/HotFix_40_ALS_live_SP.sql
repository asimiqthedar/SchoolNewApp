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
  select ParentId=isnull(ParentId,0) ,TotalFeeAmount=sum(FeeAmount) ,TotalPaidAmount=sum(PaidAmount)     
  from tblFeeStatement    
  where ParentId = @ParentId     
  group by ParentId    
 )t    
end    
Go

DROP PROCEDURE IF EXISTS [sp_SaveInvoiceToStatement]
GO

CREATE PROCEDURE  [dbo].[sp_SaveInvoiceToStatement]          
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
 join
 (
	select *from 
	(
		select ROW_NUMBER() over(partition by  InvoiceNo order by PaymentAmount desc) as RN, * from INV_InvoicePayment 
	)t
	where t.rn=1
 )invpay on invpay.InvoiceNo=invSum.InvoiceNo              

 where invSum.invoiceno=@InvoiceNo                    
 and invDet.InvoiceType like '%TUITION%'              
          
 select 0 result            
 end TRY            
 begin catch            
             
 select -1 result            
 end catch            
            
END   
GO

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
  ,FeeAmount= ISNULL(@TotalFeeAmount,0)  
  ,PaidAmount= ISNULL(@TotalPaidAmount,0)  
  ,TaxAmount=0
  ,BalanceAmount=0        
    ,StudentCode =''      
    ,GradeName=''      
 UNION ALL          
 SELECT fs.StudentId          
  ,ts.StudentName          
  ,fs.InvoiceNo          
  ,PaymentMethod          
  ,sa.AcademicYear          
  ,fs.UpdateDate AS RecordDate  
  ,FeeTypeName= CASE WHEN isnull(invs.InvoiceNo ,0)=0
  THEN FeeStatementType  ELSE isnull(invs.InvoiceType  COLLATE SQL_Latin1_General_CP1256_CI_AS,'') END
  ,FeeAmount          
  ,PaidAmount          
  ,TaxAmount= CASE WHEN isnull(invs.InvoiceType COLLATE SQL_Latin1_General_CP1256_CI_AS,'')='Invoice' then isnull(invs.TaxAmount,0) 
			  WHEN isnull(invs.InvoiceType COLLATE SQL_Latin1_General_CP1256_CI_AS,'')='Return' then isnull(invs.TaxAmount,0) *-1
			  else isnull(invs.TaxAmount,0)  end
  --,TaxAmount=0
  ,0 AS BalanceAmount        
    ,ts.StudentCode       
    ,gm.GradeName      
 FROM tblFeeStatement fs          
 INNER JOIN tblSchoolAcademic sa ON sa.SchoolAcademicId=fs.AcademicYearId          
 INNER JOIN tblStudent ts      on fs.StudentId=ts.StudentId      
  join tblGradeMaster gm on ts.GradeId=gm.GradeId 
  left join INV_InvoiceSummary invs on fs.InvoiceNo=invs.InvoiceNo
 WHERE fs.StudentId in (SELECT StudentId from #StudentTable)             
 AND (@AcademicYearId=0 OR fs.AcademicYearId IN (@AcademicYearId))        
 AND fs.IsActive=1             
 AND fs.IsDeleted=0         
        
 DROP TABLE #Previous_tblSchoolAcademic            
 DROP TABLE #StudentTable            
 DROP TABLE #StudentOpeningFeesBalance            
END     
GO

DROP PROCEDURE IF EXISTS [sp_CSVInvoiceExport]
GO

CREATE PROCEDURE [dbo].[sp_CSVInvoiceExport]        
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
         
     --select  @ParentCode            
 select           
  t.InvoiceNo, t.ParentID,t.ParentName,t.FatherMobile,t.ParentCode,t.StudentId,t.StudentName,t.StudentCode,t.InvoiceTypeValue,            
  ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo) as RN              
 into #INDMobile              
 from              
 (              
  select distinct               
   ins.InvoiceNo            
   ,ParentID= case when tp.ParentID is null then ind.ParentID  else tp.ParentID end            
   ,ParentName= case when tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.ParentName  else tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  end            
   ,FatherMobile= case when tp.FatherMobile is null then ind.FatherMobile  else tp.FatherMobile end            
   ,ParentCode= case when tp.ParentCode is null then ''  else tp.ParentCode end            
                  
   ,StudentId= case when ts.StudentId is null then ind.StudentId  else ts.StudentId end            
   ,StudentName=case when ind.InvoiceType like '%Uniform%' then '' else      
  case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName        
  else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS       
  end           
 end      
   ,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end              
               
   ,InvoiceTypeValue=        
   (select REPLACE(STUFF(CAST((              
    SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))              
     FROM (               
     SELECT distinct scm.InvoiceType                  
    FROM INV_InvoiceDetail AS scm                    
    WHERE scm.InvoiceNo = ins.InvoiceNo            
           
   ) c              
  FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')      
 )      
 from               
 #InvoiceSummary ins              
 join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo              
 LEFT JOIN tblParent tp ON ind.ParentID = tp.ParentId              
 AND tp.ParentCode=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN tp.ParentCode ELSE @ParentCode END          
 AND ind.FatherMobile=CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN ind.FatherMobile ELSE @FatherMobile END          
 AND tp.FatherName like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN tp.FatherName ELSE @ParentName END +'%'          
 LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId            
            
 where ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0              
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
      
END    
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
 
 ,ItemSubtotal= case when ins.InvoiceType='Return' then ins.ItemSubtotal *-1 else ins.ItemSubtotal end
  ,TaxableAmount= case when ins.InvoiceType='Return' then ins.TaxableAmount*-1 else ins.TaxableAmount end 
  ,TaxAmount= case when ins.InvoiceType='Return' then ins.TaxAmount *-1 else ins.TaxAmount end

  ,ins.PaymentMethod ,ins.PaymentReferenceNumber      
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

  
DROP PROCEDURE IF EXISTS [sp_ProcessGP]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP]    
  @invoiceno bigint=0   ,          
  @DestinationDB nvarchar(50) = ''               
AS          
BEGIN          
 declare @Result int=-1  
        
 ----Process GP integration    
 if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%Uniform%')  
 begin  
  set @Result =0  
  exec [sp_ProcessGP_UniformInvoice] @invoiceno,@DestinationDB    
 end  
  
 if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%entrance%')  
 begin  
  set @Result =0  
  exec [sp_ProcessGP_EntranceInvoice] @invoiceno,@DestinationDB    
 end  
   
 if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%Tuition%')  
 begin  
  set @Result =0  
  exec [sp_ProcessGP_TuitionInvoice] @invoiceno,@DestinationDB    
 end   
  
 if(@Result =-1)  
  select 0 result  
end  
GO

  
DROP PROCEDURE IF EXISTS [sp_ProcessGP_UniformInvoice]
GO

CREATE PROCEDURE  [dbo].[sp_ProcessGP_UniformInvoice]          
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
 declare @SOPReturnType int=4  
 declare @DocID nvarchar(50)='STDINV'                    
 declare @IntegrationStatus int=0                    
                    
 Declare @InvoiceTypeCount int=0                    
 declare @totalPayableAmount decimal(18,4)=0  
 
 declare @InvoiceType nvarchar(50)  
  declare @InvoiceDate  datetime  
   
   select top 1 @InvoiceType=InvoiceType,@InvoiceDate=InvoiceDate from INV_InvoiceSummary where invoiceno=@invoiceno  

 if exists( select 1 from INV_InvoiceSummary where InvoiceNo=@invoiceno and InvoiceType='Return')  
 begin  
  set @SOPType=4;  
 end  
        
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
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,(ItemSubtotal/Quantity),IntegrationStatus,Error                    
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
   ,CreditCardNumber                       ,AuthorizationCode                    
   ,ExpirationDate                    
   ,IntegrationStatus                    
   ,Error                    
  from                     
  (                    
   select top 1                     
    SeqNum=1                    
    ,SOPNumber=invoiceno      
    ,SOPType=@SOPType  
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
    ,SOPType=@SOPType  
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
  ,SOPType=@SOPType  
  ,DistType=1            
  ,AccountNumber=@UniformCreditAccount            
  ,DebitAmount= case when @InvoiceType='Invoice' then 0 else @TotalTaxableAmount end 
  ,CreditAmount=case when @InvoiceType='Invoice' then @TotalTaxableAmount else 0 end
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
  ,SOPType=@SOPType  
  ,DistType=1            
  ,AccountNumber=@VATCreditAccount           
  ,DebitAmount=case when @InvoiceType='Invoice' then 0 else @TotalTaxAmount end
  ,CreditAmount=case when @InvoiceType='Invoice' then @TotalTaxAmount else 0 end
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
  ,SOPType=@SOPType  
  ,DistType=3            
  ,AccountNumber=pm.CreditAccount            
  ,DebitAmount=case when @InvoiceType='Invoice' then PaymentAmount else 0 end
  ,CreditAmount=case when @InvoiceType='Invoice' then 0 else PaymentAmount end
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))            
  ,IntegrationStatus=0                    
  ,Error=null            
 from INV_InvoicePayment tp            
 join tblPaymentMethod pm            
 on tp.PaymentMethod=pm.PaymentMethodName       
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
     
        
 end TRY                  
 begin catch          
  SELECT -1 AS Result, 'Error!' AS Response              
  EXEC usp_SaveErrorDetail              
  select* from tblErrors                  
  end catch          
end     
GO

  
DROP PROCEDURE IF EXISTS [sp_ProcessGP_TuitionInvoice]
GO

CREATE PROCEDURE[dbo].[sp_ProcessGP_TuitionInvoice]      
(                
  @invoiceno bigint=0   ,            
  @DestinationDB nvarchar(50) = ''            
)                 
AS                
BEGIN           
  BEGIN TRY  
   
 declare @invoicenoString nvarchar(100)= cast(@invoiceno as nvarchar(100))  
   
  --Update database      
  DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'         
                
  -----------sales detail processing                
  declare @SOPType int=3                
  declare @DocID nvarchar(50)='STDINV'                
  declare @IntegrationStatus int=0                
                
  Declare @InvoiceTypeCount int=0                
  declare @totalPayableAmount decimal(18,4)=0   
  
  declare @AcademicYear bigint  
    
  declare @parentcode nvarchar(50)  
  declare @AcademicYearName nvarchar(50)  
    
  declare @InvoiceType nvarchar(50)  
  declare @InvoiceDate  datetime  
  declare @PaymentMethod nvarchar(50)   
  
  select top 1 @PaymentMethod=PaymentMethod from INV_InvoicePayment where invoiceno=@invoiceno order by PaymentAmount desc  
  
  select top 1 @InvoiceType=InvoiceType,@InvoiceDate=InvoiceDate from INV_InvoiceSummary where invoiceno=@invoiceno  
  
  select top 1 @AcademicYear =AcademicYear  from INV_InvoiceDetail where invoiceno=@invoiceno  
  select top 1 * into #INV_InvoiceDetail from INV_InvoiceDetail where invoiceno=@invoiceno  
  select top 1 *,invoiceno=@invoiceno into #tblSchoolAcademic from tblSchoolAcademic where SchoolAcademicId=@AcademicYear  
  
  select top 1 @AcademicYearName=AcademicYear from #tblSchoolAcademic  
    
 declare @CurrentAcademicYearEndDate datetime  
 select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1   
  
 declare @IsAdvance int=0  
 if exists(select * from tblSchoolAcademic where cast(PeriodFrom as date)> cast(@CurrentAcademicYearEndDate as date) and SchoolAcademicId=@AcademicYear)  
 begin  
  set @IsAdvance =1;  
 end  
  
 select top 1  @parentcode=parentcode from #INV_InvoiceDetail  
  
 select        
  RN=ROW_NUMBER() over(partition by invoiceno order by PaymentAmount asc)          
  ,SOPNumber=invoiceno        
  ,SOPType=3        
  ,DistType=3        
  ,AccountNumber=pm.CreditAccount    
  ,CreditAccount=pm.CreditAccount  
  ,DebitAccount=pm.DebitAccount  
  ,DebitAmount=PaymentAmount        
  ,CreditAmount=0  
  ,IntegrationStatus=0                
  ,Error=null    
  ,PaymentMethod=pm.PaymentMethodName  
  ,PaymentReferenceNumber  
  ,invoiceno  
  ,AcademicYear=@AcademicYear  
 into #INV_InvoicePayment  
 from INV_InvoicePayment tp        
 join tblPaymentMethod pm        
 on tp.PaymentMethod=pm.PaymentMethodName   
 where invoiceno=@invoiceno  
  
 declare @TuitionDebitAccount nvarchar(50)=''        
 declare @TuitionCreditAccount nvarchar(50)=''        
        
 declare @VATDebitAccount nvarchar(50)=''        
 declare @VATCreditAccount nvarchar(50)=''        
        
 select top 1        
  @VATDebitAccount=vat.DebitAccount,        
  @VATCreditAccount=vat.CreditAccount         
 from tblVatMaster vat        
 inner join tblFeeTypeMaster fee         
 on vat.FeeTypeId=fee.FeeTypeId        
 where vat.IsActive=1 and vat.IsDeleted=0        
 and FeeTypeName like '%Tuition%'        
        
 select top 1         
  @TuitionDebitAccount=DebitAccount,        
  @TuitionCreditAccount=CreditAccount         
 from tblFeeTypeMaster        
 where FeeTypeName like '%Tuition%'    
  
 select  top 0  
  SeqNum=1  
  ,Reference='T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end  
  ,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)  
  ,CreditAmount=cast(0 as decimal(18,2))
  ,DebitAmount=invd.DebitAmount  
  ,IntegrationStatus=0  
  ,Error=null  
 into #INT_GLSourceTable  
 from  
 #INV_InvoicePayment invD  
  
if(@IsAdvance=0)  
begin  
 --Row 1- Debit record  
  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=1  
  ,Reference=case when @InvoiceType='Invoice' then 'T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName 
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end 
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)   END
  ,CreditAmount=case when @InvoiceType='Invoice' then cast(0 as decimal(18,2)) else invd.DebitAmount end
  ,DebitAmount=case when @InvoiceType='Invoice' then invd.DebitAmount  else cast(0 as decimal(18,2)) end
  ,IntegrationStatus=0  
  ,Error=null  
   
 from  
 #INV_InvoicePayment invD  
  
 --Row-2: credit record- VAT record if VAT available  
  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=2  
  ,Reference=case when @InvoiceType='Invoice' then 'T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when @InvoiceType='Invoice' then @VATCreditAccount else @VATCreditAccount end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)   END
  ,CreditAmount=case when @InvoiceType='Invoice' then cast(invd.TaxAmount   as decimal(18,0)) else cast(0 as decimal(18,2)) end
  ,DebitAmount=case when @InvoiceType='Invoice' then cast(0 as decimal(18,2))  else cast(invd.TaxAmount   as decimal(18,0)) end
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo   
 and invD.TaxAmount>0  
  where invD.invoiceno=@invoiceno  
  
 --Row-3: credit record- Tuition Fee  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=3  
  ,Reference=case when @InvoiceType='Invoice' then 'T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when invS.InvoiceType='Invoice' then parA.ReceivableAccount else parA.AdvanceAccount end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)   END
  ,CreditAmount=case when @InvoiceType='Invoice' then invd.ItemSubtotal-invd.TaxAmount  + (cast(invd.TaxAmount   as decimal(18,2))- cast(invd.TaxAmount   as decimal(18,0)))
  else cast(0 as decimal(18,2)) end
  ,DebitAmount=case when @InvoiceType='Invoice' then cast(0 as decimal(18,2)) else 
  invd.ItemSubtotal-invd.TaxAmount  + (cast(invd.TaxAmount   as decimal(18,2))- cast(invd.TaxAmount   as decimal(18,0))) end
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo  
 join tblParent par on invD.ParentId=par.ParentId  
 join tblParentAccount parA on par.ParentId=parA.ParentId  
 where invD.invoiceno=@invoiceno   


end  
else  
  
begin  
	
 ---Case 2 Start:- When Advance available:  
 --Row 1- Debit record  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=4  
  ,Reference=case when @InvoiceType='Invoice' then 'ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end
   ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)   END
  ,CreditAmount=case when @InvoiceType='Invoice' then cast(0 as decimal(18,2))  else invd.DebitAmount  end
  ,DebitAmount=case when @InvoiceType='Invoice' then invd.DebitAmount  else cast(0 as decimal(18,2))  end
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 #INV_InvoicePayment invD  
  
 --Row-2: credit record- VAT record if VAT available  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=5
  ,Reference=case when @InvoiceType='Invoice' then 'ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=case when invS.InvoiceType='Invoice' then @VATCreditAccount else @VATDebitAccount end  
   ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)   END
  ,CreditAmount=invd.TaxAmount  
  ,DebitAmount=cast(0 as decimal(18,2))   
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo   
 and invD.TaxAmount>0  
  where invD.invoiceno=@invoiceno  
  
 --Row-3: credit record- Tuition Fee  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=6  
  ,Reference=case when @InvoiceType='Invoice' then 'ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName  
  else 'REFUND CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName end
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=@InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber= case when invS.InvoiceType='Invoice' then parA.AdvanceAccount else parA.ReceivableAccount end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ELSE 'REFUND PID#'+@parentcode+' CRN'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)   END
  ,CreditAmount=case when @InvoiceType='Invoice' then 
  invd.ItemSubtotal-invd.TaxAmount  + (cast(invd.TaxAmount   as decimal(18,2))- cast(invd.TaxAmount   as decimal(18,0)))
  else cast(0 as decimal(18,2)) end
  ,DebitAmount=case when @InvoiceType='Invoice' then cast(0 as decimal(18,2))   else
  invd.ItemSubtotal-invd.TaxAmount  + (cast(invd.TaxAmount   as decimal(18,2))- cast(invd.TaxAmount   as decimal(18,0))) end
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo  
 join tblParent par on invD.ParentId=par.ParentId  
 join tblParentAccount parA on par.ParentId=parA.ParentId  
 where invD.invoiceno=@invoiceno   
  
end  
 ---Case 2 End:- When Advance available:  

 insert into INT_GLSourceTable  
 (  
  SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber  
  ,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error  
 )  
 select  
  SeqNum=ROW_NUMBER() over(order by SeqNum),Reference ,JournalNumber ,TransactionType ,TransactionDate ,ReversingDate ,AccountNumber   
  ,DistributionRef ,CreditAmount =sum(CreditAmount),DebitAmount =sum(DebitAmount),IntegrationStatus ,Error  
 from  
 (  
  select   
   SeqNum,Reference ,JournalNumber ,TransactionType ,TransactionDate ,ReversingDate ,AccountNumber ,DistributionRef   
   ,CreditAmount ,DebitAmount ,IntegrationStatus ,Error  
  from #INT_GLSourceTable  
 )t  
 group by   
 SeqNum,Reference,JournalNumber ,TransactionType ,TransactionDate ,ReversingDate ,AccountNumber   
 ,DistributionRef ,IntegrationStatus ,Error  
     
  -----------payment processing   
  
  declare @FromDateRange Datetime = '01/01/1900'            
  declare @ToDateRange Datetime = '01/01/1900'                
     
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
  
  SET @sql = N'EXEC ' + @DestinationDB + '.dbo.INT_CreateGLInGP @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'            
  EXEC sp_executesql @sql            
  , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '            
  , @CallFrom = 0            
  , @SourceDB = @SourceDBName            
  , @DestDB = @DestinationDB            
  , @FromDate = @FromDateRange            
  , @ToDate = @ToDateRange            
            
  print @sql           
         
 select 0 result    
    
  DROP TABLE #INV_InvoicePayment  
  DROP TABLE #INT_GLSourceTable  
  DROP TABLE #INV_InvoiceDetail  
  DROP TABLE #tblSchoolAcademic  
   
  --select * from INT_GLSourceTable  
  
  truncate table tblerrors  
  
 end TRY              
 begin catch      
   SELECT -1 AS Result, 'Error!' AS Response          
   EXEC usp_SaveErrorDetail          
   select* from tblErrors              
  end catch      
end    
GO