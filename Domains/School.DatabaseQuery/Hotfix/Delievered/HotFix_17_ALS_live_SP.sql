

ALTER proc [dbo].[sp_ReportStudentStatement]    
 @AcademicYearId int  =0
 ,@ParentId int  
 ,@StudentId int  
as    
begin    
    
 declare @AcademicYear_PeriodFrom datetime    

 declare @AcademicYear nvarchar(500)    
 select top 1     
	@AcademicYear_PeriodFrom=PeriodFrom 
 from tblSchoolAcademic where (@AcademicYearId = 0 OR SchoolAcademicId=@AcademicYearId   )
 order by PeriodFrom asc

 if(@AcademicYearId=0)
	set @AcademicYear_PeriodFrom= cast('1/1/1990' as datetime)

 select * into #Previous_tblSchoolAcademic from tblSchoolAcademic where cast(PeriodTo as date)<cast(@AcademicYear_PeriodFrom as date) 
 and IsActive=1 and IsDeleted=0

 select top 1 @AcademicYear=AcademicYear from #Previous_tblSchoolAcademic order by PeriodTo desc
    
 select StudentId into #StudentTable from tblStudent where (StudentId =@StudentId OR(@StudentId=0 and ParentId=@ParentId))    


 ---- Student Opening Fees Balance    
 select     
 StudentId, RecordDate, FeeTypeName,FeeAmount=SUM(ISNULL(FeeAmount,0)),PaidAmount=SUM(ISNULL(PaidAmount,0))    
 into #StudentOpeningFeesBalance   
 from    
 (    
 select     
 StudentId, null as RecordDate, 'TUITION FEE -OPENING BALANCE' as FeeTypeName, ISNULL(FeeAmount,0) AS FeeAmount, ISNULL(PaidAmount,0) AS PaidAmount  
 from tblFeeStatement  
 where StudentId in (select StudentId from #StudentTable)     
 and AcademicYearId in (select SchoolAcademicId from #Previous_tblSchoolAcademic)     
 and IsActive=1     
 and IsDeleted=0    
 )t    
 group by  StudentId, RecordDate, FeeTypeName  
 
 --if(@AcademicYearId=0)
 --begin 
	--delete from #StudentOpeningFeesBalance
	
	--insert into #StudentOpeningFeesBalance(StudentId, RecordDate, FeeTypeName,FeeAmount,PaidAmount  )
	--select     
	--	@StudentId as StudentId, null as RecordDate, 'TUITION FEE -OPENING BALANCE' as FeeTypeName, 0 AS FeeAmount, 0 AS PaidAmount 		
 --end  
  
 declare @OpeningBalance decimal(18,2)=0    
 declare @TotalFeeAmount decimal(18,2)=0    
 declare @TotalPaidAmount decimal(18,2)=0    
    
 select @TotalFeeAmount=sum(FeeAmount) from #StudentOpeningFeesBalance   
 select @TotalPaidAmount=sum(PaidAmount) from #StudentOpeningFeesBalance    
    
 set @OpeningBalance=@TotalFeeAmount-@TotalPaidAmount    

 declare @StudentName nvarchar(100)
 select top 1 @StudentName= StudentName from tblStudent where StudentId= @StudentId
 select 
 @StudentId as StudentId,ISNULL(@StudentName,'') as StudentName
 ,'' AS InvoiceNo  
,'' AS PaymentMethod  
,@AcademicYear AS AcademicYear  
, null as RecordDate, 
'TUITION FEE -OPENING BALANCE' as FeeTypeName
,FeeAmount= case when @OpeningBalance>0 then @OpeningBalance else 0 end
,PaidAmount= case when @OpeningBalance< 0 then @OpeningBalance else 0 end
,BalanceAmount=0

-- SELECT 
--	sofb.StudentId  
--	,ts.StudentName COLLATE SQL_Latin1_General_CP1_CI_AS AS StudentName  
--	,'' AS InvoiceNo  
--	,'' AS PaymentMethod  
--	,@AcademicYear AS AcademicYear  
--	,RecordDate  
--	, FeeTypeName  
--	,FeeAmount  
--	,PaidAmount  
--	,0 AS BalanceAmount  
--FROM #StudentOpeningFeesBalance sofb  
-- INNER JOIN tblStudent ts ON ts.StudentId=sofb.StudentId  

 UNION ALL  
 SELECT 
	 StudentId  
	  ,StudentName  
	  ,InvoiceNo  
	  ,PaymentMethod  
	  ,sa.AcademicYear  
	  ,fs.UpdateDate AS RecordDate  
	  ,FeeStatementType AS FeeTypeName  
	  ,FeeAmount  
	  ,PaidAmount  
	  ,0 AS BalanceAmount  
 FROM tblFeeStatement fs  
 INNER JOIN tblSchoolAcademic sa ON sa.SchoolAcademicId=fs.AcademicYearId  
 WHERE StudentId in (SELECT StudentId from #StudentTable)     
  AND (@AcademicYearId=0 OR fs.AcademicYearId in (@AcademicYearId)     )
  AND fs.IsActive=1     
  AND fs.IsDeleted=0    

 DROP TABLE #Previous_tblSchoolAcademic    
 DROP TABLE #StudentTable    
 DROP TABLE #StudentOpeningFeesBalance    
END
GO
--exec [SP_ItemCodeRecords]     'two'  
ALTER PROCEDURE [dbo].[SP_ItemCodeRecords]       
 @UniformDB nvarchar(100)    
as        
begin        
    
 DECLARE @Query nvarchar(max)    
 --DECLARE @ParmDefinition NVARCHAR(500);    
    
 --/* Build the SQL string once */    
 --SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,      
 -- isnull(nullif(ltrim(rtrim(LOCNCODE)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription      
 -- from '+@UniformDB+'.[dbo].IV00102 where LOCNCODE=''''' ;    
 ----SET @ParmDefinition = N'@UniformDBinput nvarchar(500)';    
 --/* Execute the string with the first parameter value. */    
  
   --Production   
   SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,      
  isnull(nullif(ltrim(rtrim(ITEMDESC)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription      
   ,isnull(nullif(ltrim(rtrim(ITEMDESC)),''''),ltrim(rtrim(ITEMNMBR))) as Description  
  from '+@UniformDB+'.[dbo].IV00101 where LOCNCODE=''''' ;    
                                                                                         
  --select * from two.dbo.IV00101  
 EXECUTE sp_executesql @Query;   
    
end
GO
ALTER PROCEDURE [dbo].[sp_GetInvoice]    
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
 SET NOCOUNT ON;                             
                  
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
  ,invDet.TaxableAmount  
  ,invDet.TaxAmount  
  ,invDet.ItemSubtotal  
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
ALTER proc [dbo].[sp_ProcessGP_UniformInvoice]        
(        
  @invoiceno bigint=0   ,    
  @DestinationDB nvarchar(50) = ''    
)        
as        
begin        
        
  begin try      
        
 --SeqNum, SOPNumber and SOPType are the Primary Keys.        
--SOPType = 3 for Invoice and 4 for Return.        
--DocID should be the value which is already available in GP, example is “STDINV”.        
--DocDate, CustomerNumber and ItemNumber are mandatory.        
 -- IntegrationStatus = 0, always insert value 0. 0 = New, 1 = Integrated To GP and 2 = Failed.        
 --declare @invoiceno int=6633        
         
truncate table INT_SalesInvoiceSourceTable    
truncate table INT_SalesPaymentSourceTable  
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
   ,UnitPrice=invDet.UnitPrice        
   ,ItemSubtotal=invDet.ItemSubtotal        
   ,IntegrationStatus=@IntegrationStatus        
   ,Error=0        
   ,invDet.InvoiceType        
  into #INT_SalesInvoiceSourceTable        
  from INV_InvoiceDetail invDet        
  join INV_InvoiceSummary invSum        
  on invDet.InvoiceNo=invSum.InvoiceNo        
  where invDet.InvoiceType like '%Uniform%'        
  and invSum.invoiceno=@invoiceno        
        
  insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)        
  select         
   SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error        
  from #INT_SalesInvoiceSourceTable        
        
  -----------payment processing        
  --If uniform available with other invoice type then we need to process a signle payment record which ever is first in our payment table        
  -- If Uniform invoice type only available in detail then we need to process all record from our payment table        
         
  select @InvoiceTypeCount=count(InvoiceType) from #INT_SalesInvoiceSourceTable         
  select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_SalesInvoiceSourceTable        
        
  --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.        
  --Bank Transfer =5        
  --Check=5        
  --Cash=4        
  --Visa=6        
          
  if(@InvoiceTypeCount>1)        
  begin        
   insert into INT_SalesPaymentSourceTable        
   (        
    SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CardName,CheckNumber,CreditCardNumber,        
    AuthorizationCode,ExpirationDate,IntegrationStatus,Error        
   )        
   select         
  SeqNum        
  ,SOPNumber        
  ,SOPType        
  ,PaymentType        
  ,PaymentAmount        
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
    SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CardName,CheckNumber,CreditCardNumber,        
    AuthorizationCode,ExpirationDate,IntegrationStatus,Error        
   )        
   select         
    SeqNum        
    ,SOPNumber        
    ,SOPType        
    ,PaymentType        
    ,PaymentAmount        
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
    
  declare @FromDateRange Datetime = '01/01/1900'    
  declare @ToDateRange Datetime = '01/01/1900'        
    
 --exec INT_CreateSalesInvoiceInGP @CallFrom=1, @SourceDB='als_live',@DestDB= @DestinationDB,@FromDate = @FromDateRange ,@ToDate = @ToDateRange    
    
  select @FromDateRange= InvoiceDate,@ToDateRange= InvoiceDate 
 from INV_InvoiceSummary invSum        
 where invSum.invoiceno=@invoiceno  
 
 select @FromDateRange,@ToDateRange      
    
 DECLARE @sql AS NVARCHAR(MAX)    
    
 /*    
 Use sp_executesql to dynamically pass in the db and stored procedure    
 to execute while also defining the values and assigning to local variables.    
 */    
 SET @sql = N'EXEC ' + @DestinationDB + '.dbo.[INT_CreateSalesInvoiceInGP] @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'    
 EXEC sp_executesql @sql    
    , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '    
    , @CallFrom = 0    
    , @SourceDB = 'als_live'    
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
		SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyEntranceRevenue,
		SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyUniformRevenue,
		SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyTuitionRevenue
	FROM INV_InvoiceDetail
	WHERE DATEPART(YEAR, CAST(UpdateDate AS DATE)) = DATEPART(YEAR, CAST(GETDATE() AS DATE))
		AND DATEPART(MONTH, CAST(UpdateDate AS DATE)) = DATEPART(MONTH, CAST(GETDATE() AS DATE))


	--exec [sp_getInvoiceData]
	--select AdmissionYear, AdmissionDate ,DATEPART(year, cast(AdmissionDate as date)) from tblStudent

	--update tblStudent
	--set AdmissionYear=DATEPART(year, cast(AdmissionDate as date))

end
GO
ALTER PROCEDURE [dbo].[sp_UpdateGenerateSiblingDiscount]
	@LoginUserId int
	,@SiblingDiscountId int	
	,@ActionId int --2 Applied-Pending for Approval,3 Applied,4 Rejected,6 Deleted
AS
BEGIN
	--1	Generate
	--2	Applied-Pending for Approval
	--3	Applied
	--4	Rejected
	--5	Regenerate
	--6 Deleted
	SET NOCOUNT ON;	
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF(@ActionId=2)
		BEGIN
			UPDATE tblSiblingDiscount SET GenerateStatus=2 WHERE SiblingDiscountId=@SiblingDiscountId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblSiblingDiscount'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,1)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=3)
		BEGIN
			 UPDATE tblSiblingDiscount SET GenerateStatus=3 WHERE SiblingDiscountId=@SiblingDiscountId 
			-- Copy tblFeeGenerateDetail date to student fee table 		
			 --Synchronize the target table with refreshed data from source table
			MERGE tblStudentSiblingDiscountDetail AS TARGET
			USING tblSiblingDiscountDetail AS SOURCE 
			ON (TARGET.StudentId = SOURCE.StudentId AND TARGET.AcademicYearId = SOURCE.SchoolAcademicId 
			AND TARGET.GradeId = SOURCE.GradeId
			AND TARGET.FeeTypeId = SOURCE.FeeTypeId 
			AND SOURCE.SiblingDiscountId=@SiblingDiscountId )
			--When records are matched, update the records if there is any change
			WHEN MATCHED 
			THEN UPDATE SET 
				TARGET.DiscountPercent = SOURCE.DiscountPercent,
				TARGET.IsActive =1,
				TARGET.IsDeleted =0,
				TARGET.UpdateDate =GETDATE(),
				TARGET.UpdateBy =@LoginUserId
			--When no records are matched, insert the incoming records from source table to target table
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (StudentId,AcademicYearId,GradeId,FeeTypeId,DiscountPercent,
			IsActive,IsDeleted,UpdateDate,UpdateBy) 
			VALUES (SOURCE.StudentId,SOURCE.SchoolAcademicId,SOURCE.GradeId,SOURCE.FeeTypeId,SOURCE.DiscountPercent,
			1,0,GETDATE(),@LoginUserId)
			--When there is a row that exists in target and same record does not exist in source then delete this record target
			WHEN NOT MATCHED BY SOURCE 
			THEN DELETE;
			
			DECLARE @FeeTypeId INT =3;
			DECLARE @GradeId int=0;
			SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'	
			DECLARE @FeeStatementType NVARCHAR(50)='Discount Applied'		

			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT
				FeeStatementType=@FeeStatementType 		
				,FeeType=@FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(decimal(18,4),(sfd.FeeAmount*sblDiscount.DiscountPercent)/100)
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.ParentId
				,AcademicYearId=sfd.AcademicYearId
				,GradeId=sfd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentFeeDetail sfd	
			join tblSiblingDiscountDetail sblDiscount  
			on sfd.StudentId=sblDiscount.StudentId and sfd.AcademicYearId=sblDiscount.SchoolAcademicId and sfd.GradeId=sblDiscount.GradeId
			JOIN tblStudent stu on stu.StudentId=sfd.StudentId
			JOIN tblParent par on stu.ParentId=par.ParentId
			WHERE sblDiscount.SiblingDiscountId=@SiblingDiscountId AND sblDiscount.DiscountPercent>0
			--WHERE sfd.StudentId=@StudentId AND sfd.AcademicYearId=@AcademicYearId AND sfd.FeeTypeId=@FeeTypeId NAD SiblingDiscountId=@SiblingDiscountId

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblSiblingDiscount'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=4)
		BEGIN
			UPDATE tblSiblingDiscount SET GenerateStatus=4 WHERE SiblingDiscountId=@SiblingDiscountId 
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblSiblingDiscount'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=6)
		BEGIN
			DELETE FROM tblSiblingDiscount WHERE SiblingDiscountId=@SiblingDiscountId
			DELETE FROM tblSiblingDiscountDetail WHERE SiblingDiscountId=@SiblingDiscountId
		END
	COMMIT TRAN TRANS1
	SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
ALTER PROCEDURE [dbo].[SP_GetFeeAmount]          
 @AcademicYearId bigint          
 ,@StudentId bigint,          
 @InvoiceTypeName nvarchar(50)          
as          
        
begin          
 declare @IsStaffMember bit=0;          
 declare @GradeId int=0;        
 declare @TotalAcademicYearPaid decimal(18,2)=0      
 declare @InvoiceTypeId bigint=2008
    
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

  declare @discountPercent decimal(18,2)=0
  declare @ManagementDiscount  decimal(18,2)=0

	select top 
		1 @discountPercent=isnull(sum(DiscountPercent),0) 
	from
	tblStudentSiblingDiscountDetail ssdd    
	where ssdd.StudentId=@StudentId  and ssdd.AcademicYearId=@AcademicYearId     
	and ssdd.IsActive=1 and ssdd.IsDeleted=0

	select top 
		1 @ManagementDiscount=isnull(sum(DiscountAmount),0) 
	from
	tblStudentOtherDiscountDetail ssdd    
	where ssdd.StudentId=@StudentId  and ssdd.AcademicYearId=@AcademicYearId     
	and ssdd.IsActive=1 and ssdd.IsDeleted=0    
 
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
   ,FinalFeeAmount=inv.FeeAmount - (inv.FeeAmount*ISNULL(@discountPercent,0)/100 )- ISNULL(@ManagementDiscount,0) -  @TotalAcademicYearPaid
   ,DiscountPercent    =@discountPercent
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
GO
ALTER PROCEDURE [dbo].[sp_CSVInvoiceExport]    
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
  ,invDet.TaxableAmount  
  ,invDet.TaxAmount  
  ,invDet.ItemSubtotal  
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
ALTER proc [dbo].[SP_MonthlyStatementParentStudent]
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
	--order by ParentId	,ParentName	,NameMonth	,NameYear 
	group by ParentId	,ParentName	,NameMonth	,NameYear 


	--select DATENAME(year, getdate())

end
GO
ALTER PROCEDURE [dbo].[sp_UpdateSchoolLogoImage]  
 @LoginUserId int  
 ,@SchoolId bigint  
 ,@ImageUrl nvarchar(500)  
 ,@LogoName nvarchar(200)
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1      
  BEGIN 
   --DECLARE @LogoName NVARCHAR(50)='logo_'   
   --SELECT @LogoName=@LogoName+CAST((COUNT(SchoolId)+1) AS nvarchar) FROM tblSchoolLogo WHERE SchoolId=@SchoolId AND IsActive=1 AND IsDeleted=0
   INSERT INTO [dbo].[tblSchoolLogo]
           ([SchoolId]
           ,[LogoName]
           ,[LogoPath]
           ,[IsActive]
           ,[IsDeleted]
           ,[UpdateDate]
           ,[UpdateBy])
     VALUES
           (@SchoolId
           ,@LogoName
           ,@ImageUrl  
           ,1
           ,0
           ,GETDATE() 
           ,@LoginUserId)   
   END      
  COMMIT TRAN TRANS1  
  SELECT 0 AS Result, 'Saved' AS Response  
 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1  
   SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END
GO
ALTER PROCEDURE [dbo].[sp_UpdateGenerateFee]
	@LoginUserId int
	,@FeeGenerateId int	
	,@ActionId int --2 Applied-Pending for Approval,3 Applied,4 Rejected,6 Deleted
AS
BEGIN
	--1	Generate
	--2	Applied-Pending for Approval
	--3	Applied
	--4	Rejected
	--5	Regenerate
	--6 Deleted
	SET NOCOUNT ON;	
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF(@ActionId=2)
		BEGIN
			UPDATE tblFeeGenerate SET GenerateStatus=2 WHERE FeeGenerateId=@FeeGenerateId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,1)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=3)
		BEGIN
			 UPDATE tblFeeGenerate SET GenerateStatus=3 WHERE FeeGenerateId=@FeeGenerateId 
			-- Copy tblFeeGenerateDetail date to student fee table 		
			 --Synchronize the target table with refreshed data from source table
			MERGE [tblStudentFeeDetail] AS TARGET
			USING tblFeeGenerateDetail AS SOURCE 
			ON (TARGET.StudentId = SOURCE.StudentId AND TARGET.AcademicYearId = SOURCE.SchoolAcademicId 
			AND TARGET.GradeId = SOURCE.GradeId
			AND TARGET.FeeTypeId = SOURCE.FeeTypeId) 
			--When records are matched, update the records if there is any change
			WHEN MATCHED 
			THEN UPDATE SET 
				TARGET.FeeAmount = SOURCE.FeeAmount,
				TARGET.IsActive =1,
				TARGET.IsDeleted =0,
				TARGET.UpdateDate =GETDATE(),
				TARGET.UpdateBy =@LoginUserId
			--When no records are matched, insert the incoming records from source table to target table
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (	StudentId,AcademicYearId,GradeId,FeeTypeId,FeeAmount,
			IsActive,IsDeleted,UpdateDate,UpdateBy) 
			VALUES (SOURCE.StudentId,SOURCE.SchoolAcademicId,SOURCE.GradeId,SOURCE.FeeTypeId,SOURCE.FeeAmount,
			1,0,GETDATE(),@LoginUserId)
			--When there is a row that exists in target and same record does not exist in source then delete this record target
			WHEN NOT MATCHED BY SOURCE 
			THEN DELETE;
			
			DECLARE @FeeTypeId INT =3;
			DECLARE @GradeId int=0;
			SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'	
			DECLARE @FeeStatementType NVARCHAR(50)='Fee Applied'		

			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT
				FeeStatementType=@FeeStatementType 		
				,FeeType=@FeeTypeId
				,FeeAmount=fgd.FeeAmount
				,PaidAmount=0
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.ParentId
				,AcademicYearId=sfd.AcademicYearId
				,GradeId=sfd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentFeeDetail sfd	
			join tblFeeGenerateDetail fgd  
			on sfd.StudentId=fgd.StudentId and sfd.AcademicYearId=fgd.SchoolAcademicId and sfd.GradeId=fgd.GradeId
			JOIN tblStudent stu on stu.StudentId=sfd.StudentId
			JOIN tblParent par on stu.ParentId=par.ParentId
			WHERE fgd.FeeGenerateId=@FeeGenerateId

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

		END
		ELSE IF(@ActionId=4)
		BEGIN
			UPDATE tblFeeGenerate SET GenerateStatus=4 WHERE FeeGenerateId=@FeeGenerateId 
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=6)
		BEGIN
			DELETE FROM tblFeeGenerate WHERE FeeGenerateId=@FeeGenerateId
			DELETE FROM tblFeeGenerateDetail WHERE FeeGenerateId=@FeeGenerateId
		END
	COMMIT TRAN TRANS1
	SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
ALTER PROCEDURE [dbo].[sp_SaveStudentFeeDetail]  
	@LoginUserId int  
	,@StudentFeeDetailId bigint
	,@StudentId bigint  
	,@AcademicYearId bigint
	,@GradeId bigint
	,@FeeTypeId bigint
	,@FeeAmount decimal(18,2)
AS  
BEGIN  
	SET NOCOUNT ON;  
	IF EXISTS(	SELECT 1 FROM tblStudentFeeDetail 
				WHERE StudentId = @StudentId 
					AND AcademicYearId=@AcademicYearId AND GradeId=@GradeId
					AND FeeTypeId =@FeeTypeId
					AND StudentFeeDetailId <> @StudentFeeDetailId 
					AND IsActive = 1 AND IsDeleted = 0)  
	BEGIN  
		SELECT -2 AS Result, 'Fee already exists!' AS Response  
		RETURN;  
	END 
	IF EXISTS(	SELECT 1 FROM tblFeeStatement 
				WHERE StudentId = @StudentId 
					AND AcademicYearId=@AcademicYearId AND GradeId=@GradeId					
					AND IsActive = 1 AND IsDeleted = 0
					AND FeeStatementType='Discount Applied')  
	BEGIN  
		SELECT -3 AS Result, 'Discount already applied!' AS Response  
		RETURN;  
	END 	
		SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'			
		SELECT TOP 1  @GradeId=ISNULL(GradeId,0) FROM tblStudent WHERE  StudentId=@StudentId	
       
	   DECLARE @FeeStatementType NVARCHAR(50)='Fee Applied'
	BEGIN TRY  
	BEGIN TRANSACTION TRANS1  
		IF(@StudentFeeDetailId = 0)  
		BEGIN  
			INSERT INTO tblStudentFeeDetail  
				(StudentId  
				,AcademicYearId  
				,GradeId  
				,FeeTypeId
				,FeeAmount
				,IsActive  
				,IsDeleted  
				,UpdateDate  
				,UpdateBy)  
			VALUES  
				(@StudentId
				,@AcademicYearId
				,@GradeId
				,@FeeTypeId
				,@FeeAmount
				,1   
				,0  
				,GETDATE()  
				,@LoginUserId)  

				--Insert discount Applied entry in statement		

			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType=@FeeStatementType 		
				,FeeType=@FeeTypeId
				,FeeAmount=FeeAmount
				,PaidAmount=0
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.ParentId				
				,AcademicYearId=@AcademicYearId
				,GradeId=@GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentFeeDetail sfd		
			JOIN tblStudent stu on stu.StudentId=sfd.StudentId
			JOIN tblParent par on stu.ParentId=par.ParentId
			WHERE sfd.StudentId=@StudentId AND sfd.AcademicYearId=@AcademicYearId AND sfd.FeeTypeId=@FeeTypeId
		END  
		ELSE  
		BEGIN  
			UPDATE tblStudentFeeDetail  
				SET FeeAmount = @FeeAmount
					,UpdateDate = GETDATE()  
					,UpdateBy = @LoginUserId  
			WHERE StudentFeeDetailId = @StudentFeeDetailId  


			UPDATE  fee	SET FeeAmount=@FeeAmount
			FROM tblFeeStatement fee
			
			WHERE FeeStatementType=@FeeStatementType
			AND StudentId=@StudentId
			AND AcademicYearId= @AcademicYearId
			AND GradeId = @GradeId
		END      
	COMMIT TRAN TRANS1  
	SELECT 0 AS Result, 'Saved' AS Response  
	END TRY
	BEGIN CATCH  
		ROLLBACK TRAN TRANS1  
		SELECT -1 AS Result, 'Error!' AS Response  
		EXEC usp_SaveErrorDetail  
		RETURN  
	END CATCH  
END
GO
ALTER PROCEDURE [dbo].[sp_DeleteStudentFeeDetail] 
	@LoginUserId int
   ,@StudentFeeDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblFeeStatement fs 
			INNER JOIN tblStudentFeeDetail sfd
				ON sfd.StudentId=fs.StudentId 
				AND sfd.AcademicYearId=fs.AcademicYearId
				AND sfd.GradeId=fs.GradeId
			WHERE fs.IsActive = 1 AND fs.IsDeleted = 0
				AND fs.FeeStatementType='Discount Applied'
				AND sfd.StudentFeeDetailId = @StudentFeeDetailId)  
	BEGIN  
		SELECT -3 AS Result, 'Discount already applied!' AS Response  
		RETURN;  
	END 
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentFeeDetail
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentFeeDetailId = @StudentFeeDetailId	

		DELETE fs FROM tblFeeStatement  fs
		INNER JOIN tblStudentFeeDetail sfd
			ON sfd.StudentId=fs.StudentId AND sfd.AcademicYearId=fs.AcademicYearId 
		where sfd.StudentFeeDetailId=@StudentFeeDetailId

		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
CREATE PROCEDURE [dbo].[sp_GetInvoiceDataMonthly]
AS
BEGIN
    SELECT
        InvoiceYear,
        InvoiceMonth,
        InvoiceMonthName,
        Discount = SUM(Discount),
        TaxableAmount = SUM(TaxableAmount),
        TaxAmount = SUM(TaxAmount),
        ItemSubtotal = SUM(ItemSubtotal)
    FROM (
       SELECT
            YEAR(ts.InvoiceDate) AS InvoiceYear,
            MONTH(ts.InvoiceDate) AS InvoiceMonth,
            DATENAME(month, ts.InvoiceDate) AS InvoiceMonthName,

            Discount = CASE 
                          WHEN ts.InvoiceType = 'Return' THEN (ISNULL(td.Discount, 0) * -1) 
                          ELSE ISNULL(td.Discount, 0) 
                       END,
            TaxableAmount = CASE 
                               WHEN ts.InvoiceType = 'Return' THEN (ISNULL(td.TaxableAmount, 0) * -1) 
                               ELSE ISNULL(td.TaxableAmount, 0) 
                            END,
            TaxAmount = CASE 
                           WHEN ts.InvoiceType = 'Return' THEN (ISNULL(td.TaxAmount, 0) * -1) 
                           ELSE ISNULL(td.TaxAmount, 0) 
                        END,
            ItemSubtotal = CASE 
                              WHEN ts.InvoiceType = 'Return' THEN (ISNULL(td.ItemSubtotal, 0) * -1) 
                              ELSE ISNULL(td.ItemSubtotal, 0) 
                           END
        FROM INV_InvoiceDetail td
        INNER JOIN INV_InvoiceSummary ts ON td.InvoiceNo = ts.InvoiceNo
        --WHERE Status = 'Posted'
    ) t
    GROUP BY t.InvoiceYear, t.InvoiceMonth, t.InvoiceMonthName;
END
GO
CREATE PROCEDURE [dbo].[sp_GetOtherDiscountDetail]
    @StudentId bigint
AS
BEGIN
    SELECT
	   tsdd.StudentOtherDiscountDetailId,
        tsdd.StudentId,
		ts.StudentName,
        tsdd.AcademicYearId,
		tsa.AcademicYear,
        tsdd.GradeId,
		tgm.GradeName,
		tsdd.DiscountName,
        tsdd.DiscountAmount
    FROM 
        tblStudentOtherDiscountDetail AS tsdd
    JOIN 
        tblGradeMaster AS tgm ON tsdd.GradeId = tgm.GradeId
    JOIN 
        tblSchoolAcademic AS tsa ON tsdd.AcademicYearId = tsa.SchoolAcademicId
    JOIN 
        tblStudent AS ts ON tsdd.StudentId = ts.StudentId
    WHERE 
        tsdd.StudentId = @StudentId
		AND tsdd.IsActive=1 AND tsdd.IsDeleted=0
END
GO
CREATE PROCEDURE [dbo].[sp_CSVAdvanceFeeRevenueExport]    
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
CREATE PROCEDURE [dbo].[sp_CSVEntranceRevenueExport]    
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
EXEC SP_EntranceFeesReport    
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
CREATE PROCEDURE [dbo].[sp_CSVTuitionRevenueExport]    
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
EXEC SP_TuitionFeeReport    
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
CREATE PROCEDURE [dbo].[sp_CSVUniformRevenueExport]    
    @ItemCode nvarchar(100)=null
   ,@InvoiceNo bigint = 0
   ,@ParentName nvarchar(100)=null
   ,@FatherMobile nvarchar(100)=null
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
   ,@PaymentReferenceNumber       
   ,@StartDate
   ,@EndDate     
END
GO
CREATE PROCEDURE [dbo].[sp_SaveInvoiceToStatement]    
 @InvoiceNo bigint    
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
Create proc [dbo].[SP_DiscountReport]
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
	 ParentId
	,ParentName
	,FatherMobile
	,IqamaNumber
	,StudentId
	,StudentName
	,Description = ''
	,GradeName
	,CostCenter=0
	,AcademicYear
	,IsStaff
	,InvoiceDate
	,DiscountApplied = ''
	,DiscountCancelled = ''
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
			,invPay.InvoiceRefNo
		from INV_InvoiceSummary invSum
		join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
		where 
		(
		     (invDet.InvoiceType = 'Tuition Fee' )
			 AND(
			 (@parentId=0 OR invDet.ParentId=@parentId)
			OR (@parentId=0 OR invDet.StudentId=@parentId)
			OR (@AcademicYearId=0 OR invDet.AcademicYear=@parentId)
			OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)
			OR ((@StudentName is null OR @StudentName='' ) OR invDet.ParentName like @StudentName)
		 )
			
		)
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
		,InvoiceRefNo
end
GO
CREATE PROCEDURE [dbo].[sp_SaveSiblingDiscountDetail]
	@LoginUserId int,
	@StudentSiblingDiscountDetailId bigint,
    @StudentId bigint,   
	@AcademicYearId int,
    @DiscountPercent decimal(5, 2)
AS
BEGIN
    SET NOCOUNT ON;
	
    BEGIN TRY
        BEGIN
 TRANSACTION TRANS1
		DECLARE @FeeTypeId INT =3;
		DECLARE @GradeId int=0;
		SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'			
		SELECT TOP 1  @GradeId=ISNULL(GradeId,0) FROM tblStudent WHERE  StudentId=@StudentId	
       
	   DECLARE @FeeStatementType NVARCHAR(50)='Discount Applied'
	   IF(@StudentSiblingDiscountDetailId = 0)
        BEGIN
			INSERT INTO [dbo].[tblStudentSiblingDiscountDetail]
			([StudentId],[AcademicYearId],[GradeId],[FeeTypeId],[DiscountPercent],[IsActive],[IsDeleted],[UpdateDate],[UpdateBy])
			 VALUES
			(@StudentId,@AcademicYearId,@GradeId,@FeeTypeId,@DiscountPercent,1,0,GETDATE(),@LoginUserId )
		
			--Insert discount Applied entry in statement		

			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType=@FeeStatementType 		
				,FeeType=@FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(decimal(18,4),(sfd.FeeAmount*@DiscountPercent)/100)
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.ParentId				
				,AcademicYearId=@AcademicYearId
				,GradeId=@GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentFeeDetail sfd		
			JOIN tblStudent stu on stu.StudentId=sfd.StudentId
			JOIN tblParent par on stu.ParentId=par.ParentId
			WHERE sfd.StudentId=@StudentId AND sfd.AcademicYearId=@AcademicYearId AND sfd.FeeTypeId=@FeeTypeId
        END
        ELSE
        BEGIN
            UPDATE tblStudentSiblingDiscountDetail
                SET DiscountPercent = @DiscountPercent,
                    UpdateDate = GETDATE(),
                    UpdateBy = @LoginUserId -- Replace '1' with a valid user ID or use @LoginUserId if available
            WHERE StudentSiblingDiscountDetailId = @StudentSiblingDiscountDetailId

			DECLARE @FeeAmount DECIMAL(18,2)=0
			SELECT TOP 1  
				@FeeAmount =FeeAmount 
			FROM tblStudentFeeDetail sfd
			WHERE  StudentId=@StudentId
			AND AcademicYearId= @AcademicYearId
			AND GradeId = @GradeId

			UPDATE  fee	SET PaidAmount= CONVERT(DECIMAL(18,4),(@FeeAmount*@DiscountPercent)/100)
			FROM tblFeeStatement fee
			
			WHERE FeeStatementType=@FeeStatementType
			AND StudentId=@StudentId
			AND AcademicYearId= @AcademicYearId
			AND GradeId = @GradeId

        END

        COMMIT TRAN TRANS1
    
 
   SELECT 0 AS Result, 'Saved' AS Response
    END TRY

    BEGIN CATCH
        ROLLBACK TRAN TRANS1
        SELECT -1 AS Result, 'Error!' AS Response
        EXEC usp_SaveErrorDetail
        RETURN;
    END CATCH
END
GO
CREATE proc [dbo].[SP_AdvanceFeeReport]
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
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
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
CREATE proc [dbo].[SP_EntranceFeesReport]
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
	,CostCenter = 0
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
             invDet.ParentName
			,invDet.FatherMobile
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
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
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
end
GO
CREATE proc [dbo].[SP_TuitionFeeReport]
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
	,PaymentReferenceNumber
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
		join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId
		join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId
		join INV_InvoicePayment as invPay on invDet.InvoiceNo = invPay.InvoiceNo
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
end
GO
CREATE proc [dbo].[SP_UniformSalesReport]
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

	select 
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

	from
	(
		select 
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
end
GO
CREATE proc [dbo].[sp_ProcessOpenApplyRecordToNotification_old]          
as          
begin          
  --1- added          
  --2- updated           
 BEGIN TRY        
   BEGIN TRANSACTION TRANS1        
   --NotificationAction 1- Add, 2-Edit, 3-deleted    
    
   ----Delete previous record    
   delete from [tblNotification]    
    
   delete t    
 from tblNotificationGroupDetail t    
 inner join tblNotificationTypeMaster  tm on t.NotificationTypeId=tm.NotificationTypeId    
 where tm.ActionTable in ('tblStudent','tblParent')    
    
    delete t    
 from tblNotificationGroup t    
 inner join tblNotificationTypeMaster  tm on t.NotificationTypeId=tm.NotificationTypeId    
 where tm.ActionTable in ('tblStudent','tblParent')    
    
 delete from tblNotificationTypeMaster  where ActionTable in ('tblStudent','tblParent')    
    
-- select * from tblNotificationTypeMaster    
--select * from tblNotificationGroup    
--select * from tblNotificationGroupDetail    
    
 -- alter table [tblNotification] add [student_id] nvarchar(100)        
  --alter table [tblNotification] add OldValueJson nvarchar(max)        
  --alter table [tblNotification] add NewValueJson nvarchar(max)        
    
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id as RecordId,          
  case when [StudentCode] is null then 1 else 2 end RecordStatus,            
  0 as IsApproved,          
  'Student' as RecordType,          
  Getdate(),    
  0 ,        
  student_id    
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
  select       
   stu.[StudentCode],      
   os.id  ,      
   os.[student_id]      
    
   , NewValueJson= (SELECT * FROM [OpenApplyStudents] jc where jc.[student_id] = os.[student_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
   , OldValueJson= (SELECT * FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
   ,case     
   when ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
   then 1 else 0 end NameUpdated    
        
   ,case when ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))     
   then 1 else 0 end  ArabicNameUpdated    
    
   ,case when ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
   then 1 else 0 end  EmailUpdated    
  
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated    
    
  from [dbo].[OpenApplyStudents] os          
  left join [dbo].[tblStudent] stu          
  on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]          
         
  AND           
  (          
   (          
    (ltrim(rtrim(os.first_name))+ ' '+ ltrim(rtrim(os.last_name))) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
    OR ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))       
    OR ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))  
  OR ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))  
    --OR os.[status] <>stu.[StudentStatusId]          
    --enrolled          
   )          
   OR          
   1=1          
  )    
 )t      
 where t.NameUpdated=1 OR t.ArabicNameUpdated=1 OR t.EmailUpdated=1   OR t.IqamaNoUpdated=1  
          
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id,          
  case when [ParentCode] is null then 1 else 2 end RecordStatus,  --added/updated        
  --cast(0 as bit) as          
  0 as IsApproved,          
  'Mother' as RecordType,          
  Getdate(),0 ,        
  student_id     
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
  select     
   ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,      
   stu.[ParentCode],      
   os.id  ,      
   os.[student_id]      
       
   ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
   then 1 else 0 end  NameUpdated    
        
   ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
   then 1 else 0 end  EmailUpdated    
  
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.MotherIqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated    
       
   ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
   , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
  from [dbo].[OpenApplyParents] os          
  left join [dbo].[tblParent] stu          
  on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
  and os.gender='Female'        
  AND           
  (          
   (          
    (ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name]))) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
    OR     
    ltrim(rtrim(os.[email])) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail    
 OR     
    ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherIqamaNo    
   )          
   OR          
   1=1          
  )       
 )t         
 where t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1    
        
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id,          
  case when [ParentCode] is null then 1 else 2 end RecordStatus,          
  --cast(0 as bit) as          
  0 as IsApproved,          
  'Father' as RecordType,          
  Getdate(),    
  0  ,        
  student_id      
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
 select     
  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,       
  stu.[ParentCode],      
  os.id  ,      
  os.[student_id]     
       
  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
     then 1 else 0 end  NameUpdated    
        
  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
   then 1 else 0 end  EmailUpdated   
     
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.FatherIqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated   
    
  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
    
 from [dbo].[OpenApplyParents] os          
 left join [dbo].[tblParent] stu          
 on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 and os.gender='male'        
 AND           
  (          
   (          
    (ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name]))) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
    OR ltrim(rtrim(os.[email])) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]   
 OR     
    ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.FatherIqamaNo    
   )          
   OR          
   1=1          
  )       
 )t         
 where t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1       
    
    
 ---Process final table to notification table    
    
 ----insert into master record : tblNotificationTypeMaster    
 if not exists(select top 1 * from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblStudent')    
 begin     
  insert into tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)    
  select  'OpenApplyRecordProcessing', 'tblStudent', 'Student #N record #Action' ,1    
 end    
    
 if not exists(select top 1 * from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblParent')    
 begin     
  insert into tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)    
  select  'OpenApplyRecordProcessing', 'tblParent', 'Parent #N record #Action' ,1    
 end    
    
 declare @NotificationTypeId int=0;    
    
 --------------Start: Student record    
     
 select top 1 @NotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblStudent'    
    
 --Added new record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=1  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1    
 end    
     
     
  declare @NotificationGroupId int=0;    
  select top 1 @NotificationGroupId=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1    
    
  declare @NotificationCount int=0    
  select @NotificationCount=count(1)     
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1     
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount    
  where  NotificationGroupId=@NotificationGroupId    
      
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId,@NotificationTypeId as NotificationTypeId,NotificationAction=1,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1    
     
    
 --add updated record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=2  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
 end    
     
     
  declare @NotificationGroupId1 int=0;    
  select top 1 @NotificationGroupId1=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount1 int=0    
  select @NotificationCount1=count(1)     
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount1    
  where  NotificationGroupId=@NotificationGroupId1    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId1,@NotificationTypeId as NotificationTypeId,NotificationAction=2,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
     
     
 --------------End: Student record    
    
 --------------Start: parent record    
     
 select top 1 @NotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblParent'    
    
 --Added new record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=1  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
 end    
     
     
  declare @NotificationGroupId2 int=0;    
  select top 1 @NotificationGroupId2=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount2 int=0    
  select @NotificationCount2=count(1)     
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount2    
  where  NotificationGroupId=@NotificationGroupId2    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId2,@NotificationTypeId as NotificationTypeId,NotificationAction=1,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
     
    
 --add updated record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=2  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
 end    
     
    
     
  declare @NotificationGroupId3 int=0;    
  select top 1 @NotificationGroupId3=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount3 int=0    
  select @NotificationCount3=count(1)     
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount3    
  where  NotificationGroupId=@NotificationGroupId3    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId3,@NotificationTypeId as NotificationTypeId,NotificationAction=2,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
     
     
 --------------End: parent record    
    
          
  COMMIT TRAN TRANS1        
  SELECT 0 AS Result, 'Saved' AS Response      
 END TRY        
 BEGIN CATCH        
     ROLLBACK TRAN TRANS1           
     SELECT -1 AS Result, 'Error!' AS Response        
     EXEC usp_SaveErrorDetail        
     RETURN        
 END CATCH       
     
    
    
    
    
    
    
   --------------Start: Student ------------    
 --select           
 --  --  id as RecordId,          
 --  --  case when [StudentCode] is null then 1 else 2 end RecordStatus,            
 --  --  0 as IsApproved,          
 --  --  'Student' as RecordType,          
--  --  Getdate(),0 ,        
 --  --  student_id  ,    
 --  --NewValueJson,OldValueJson    
 --  LoginUserId=0    
 --  ,ActionTable='tblStudent'    
 --  ,NotificationAction= case when [StudentCode] is null then 1 else 2 end    
 --  ,TableRecordId=isnull(StudentId,0)    
 --  ,OldValueJson=OldValueJson    
 --  ,NewValueJson=NewValueJson    
 --  from           
 --  (          
 -- select       
 --  stu.StudentId,      
 --  stu.[StudentCode],      
 --  os.id  ,      
 --  os.[student_id]  ,    
       
 --  NewValueJson= (SELECT * FROM [OpenApplyStudents] jc where jc.[student_id] = os.[student_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson=     
 --  (    
 --  SELECT     
 --   StudentId    
 --   ,StudentCode    
 --   ,StudentImage    
 --   ,ParentId    
 --   ,StudentName    
 --   ,StudentArabicName    
 --   ,StudentEmail    
 --   ,DOB    
 --   ,IqamaNo    
 --   ,NationalityId    
 --   ,GenderId    
 --   ,AdmissionDate    
 --   ,GradeId    
 --   ,CostCenterId    
 --   ,SectionId    
 --   ,PassportNo    
 --   ,PassportExpiry    
 --   ,Mobile    
 --   ,StudentAddress    
 --   ,StudentStatusId    
 --   ,WithdrawDate    
 --   ,WithdrawAt    
 --   ,WithdrawYear    
 --   ,Fees    
 --   ,IsGPIntegration    
 --   ,TermId    
 --   ,AdmissionYear    
 --   ,PrinceAccount    
 --   ,IsActive    
 --   ,IsDeleted    
 --   ,UpdateDate    
 --   ,UpdateBy    
 --   ,p_id_school_parent_id    
 --  FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 --  ,os.[name] ,stu.[StudentName]         
 --  ,os.[other_name]  ,stu.[StudentArabicName]          
 --  ,os.[email]  ,stu.[StudentEmail]      
     
 --  ,case     
 --  when ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
 --  then 1 else 0 end NameUpdated    
        
 --  ,case when ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))     
 --  then 1 else 0 end  ArabicNameUpdated    
    
 --  ,case when ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
 --  then 1 else 0 end  EmailUpdated    
    
 --  --,case when   ltrim(rtrim(os.IqamaNo))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(stu.IqamaNo))    
 --  --then 1 else 0 end  IqamaNoUpdated    
    
 -- from [dbo].[OpenApplyStudents] os          
 -- left join [dbo].[tblStudent] stu          
 -- on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]          
         
 -- AND           
 -- (          
 --  (          
 --   ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
 --   OR ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))       
 --   OR ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
 --   --OR  ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(stu.IqamaNo))    
 --   --OR os.[status] <>stu.[StudentStatusId]          
 --   --enrolled          
 --  )          
 --  OR          
 --  1=1    
 -- )         
 --  )t     
 --  where NameUpdated=1 OR ArabicNameUpdated=1 OR EmailUpdated=1 --OR IqamaNoUpdated=1    
 --------------End: Student ------------    
    
 --------------Start: Mother------------    
 --select     
 -- LoginUserId=0    
 -- ,ActionTable='tblParent'    
 -- ,NotificationAction= case when [ParentCode] is null then 1 else 2 end    
 -- ,TableRecordId=isnull(ParentId,0)    
 -- ,OldValueJson=OldValueJson    
 -- ,NewValueJson=NewValueJson    
 -- --id,          
 -- --case when [ParentCode] is null then 1 else 2 end RecordStatus,  --added/updated        
 -- ----cast(0 as bit) as          
 -- --0 as IsApproved,          
 -- --'Mother' as RecordType,          
 -- --Getdate(),0 ,        
 -- --student_id     
 -- --*    
 --from           
 --(          
 -- select     
 --  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN    
 --  ,stu.ParentId    
 --  ,stu.[ParentCode]    
 --  ,os.id      
 --  ,os.[student_id]    
       
 --  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
 --   then 1 else 0 end  NameUpdated    
        
 --  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
 --   then 1 else 0 end  EmailUpdated    
       
 --  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 -- from [dbo].[OpenApplyParents] os          
 -- left join [dbo].[tblParent] stu          
 -- on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 -- and os.gender='Female'        
 -- AND           
 -- (          
 --  (          
 --   (os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
 --   OR     
 --   os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
 --  )          
 --  OR          
 --  1=1          
 -- )      
 --)t         
 --where t.RN=1   and t.NameUpdated=1 and t.EmailUpdated=1      
 --------------End: Mother------------      
      
 --------------Start: Father------------    
 --select     
 -- LoginUserId=0    
 -- ,ActionTable='tblParent'    
 -- ,NotificationAction= case when [ParentCode] is null then 1 else 2 end    
 -- ,TableRecordId=isnull(ParentId,0)    
 -- ,OldValueJson=OldValueJson    
 -- ,NewValueJson=NewValueJson    
    
 -- --id,          
 -- --case when [ParentCode] is null then 1 else 2 end RecordStatus,          
 -- ----cast(0 as bit) as          
 -- --0 as IsApproved,          
 -- --'Father' as RecordType,          
 -- --Getdate(),0  ,        
 -- --student_id        
 -- --*    
 --from           
 --(          
 -- select     
 --  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN    
 --  ,stu.ParentId    
 --  ,stu.[ParentCode]    
 --  ,os.id      
 --  ,os.[student_id]    
       
 --  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
 --   then 1 else 0 end  NameUpdated    
        
 --  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
 --   then 1 else 0 end  EmailUpdated    
    
 --  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 -- from [dbo].[OpenApplyParents] os          
 -- left join [dbo].[tblParent] stu          
 -- on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 -- and os.gender='male'        
 -- AND           
 -- (          
 --  (          
 --   (os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
 --   OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
 --  )          
 --  OR          
 --  1=1          
 -- )      
 --)t         
 --where t.RN=1   and t.NameUpdated=1 and t.EmailUpdated=1      
 --------------End: Father------------    
    
END
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudentSiblingDiscountDetail] 
	@LoginUserId int
   ,@StudentSiblingDiscountDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentSiblingDiscountDetail
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentSiblingDiscountDetailId = @StudentSiblingDiscountDetailId		
		
		
		--Insert discount cancled entry in statement
		DECLARE @FeeStatementType NVARCHAR(50)='Discount Cancelled'

		INSERT INTO [dbo].[tblFeeStatement]
		(
			[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
			,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
		)
		SELECT top 1
			FeeStatementType=@FeeStatementType 		
			,FeeType=ssdd.FeeTypeId
			,FeeAmount=0
			,PaidAmount=Convert(decimal(18,4),(sfd.FeeAmount*ssdd.DiscountPercent)/100)*-1
			,StudentId=stu.StudentId
			,ParentId=stu.ParentId
			,StudentName=stu.StudentName
			,ParentName=par.ParentId
			,AcademicYearId=ssdd.AcademicYearId
			,GradeId=ssdd.GradeId
			,IsActive=1
			,IsDeleted=0
			,UpdateDate=GETDATE()
			,UpdateBy=0
		FROM tblStudentFeeDetail sfd
		INNER JOIN tblStudentSiblingDiscountDetail ssdd  
		ON ssdd.StudentId=sfd.StudentId AND ssdd.AcademicYearId=sfd.AcademicYearId AND ssdd.FeeTypeId=sfd.FeeTypeId 
		join tblStudent stu on ssdd.StudentId=stu.StudentId
		join tblParent par on stu.ParentId=par.ParentId
		WHERE ssdd.StudentSiblingDiscountDetailId = @StudentSiblingDiscountDetailId 
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
CREATE PROCEDURE [dbo].[sp_SaveOtherDiscountDetail]
	@LoginUserId int,
	@StudentOtherDiscountDetailId bigint,
    @StudentId bigint,   
	@AcademicYearId int,
    @DiscountName nvarchar(250),
    @DiscountAmount decimal(18, 4)
AS
BEGIN
    SET NOCOUNT ON;
	
    BEGIN TRY
        BEGIN
 TRANSACTION TRANS1
		DECLARE @FeeTypeId INT =3;
		DECLARE @GradeId int=0;
		SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'			
		SELECT TOP 1  @GradeId=ISNULL(GradeId,0) FROM tblStudent WHERE  StudentId=@StudentId	
       
	   DECLARE @FeeStatementType NVARCHAR(50)=@DiscountName +' Discount Applied'
	   IF(@StudentOtherDiscountDetailId = 0)
        BEGIN
			INSERT INTO [dbo].[tblStudentOtherDiscountDetail]
			([StudentId],[AcademicYearId],[GradeId],[FeeTypeId],[DiscountName],[DiscountAmount],[IsActive],[IsDeleted],[UpdateDate],[UpdateBy])
			 VALUES
			(@StudentId,@AcademicYearId,@GradeId,@FeeTypeId,@DiscountName,Convert(DECIMAL(18,4),@DiscountAmount),1,0,GETDATE(),@LoginUserId )
		
			--Insert discount Applied entry in statement		

			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType=@FeeStatementType 		
				,FeeType=@FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(DECIMAL(18,2),@DiscountAmount)
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.ParentId				
				,AcademicYearId=@AcademicYearId
				,GradeId=@GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudent stu
			JOIN tblParent par on stu.ParentId=par.ParentId
			WHERE stu.StudentId=@StudentId
        END
        ELSE
        BEGIN
            UPDATE tblStudentOtherDiscountDetail
                SET DiscountAmount = Convert(DECIMAL(18,4),@DiscountAmount),
					DiscountName = @DiscountName,
                    UpdateDate = GETDATE(),
                    UpdateBy = @LoginUserId -- Replace '1' with a valid user ID or use @LoginUserId if available
            WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId

			UPDATE  fee	SET PaidAmount= Convert(DECIMAL(18,2),@DiscountAmount)			
			FROM tblFeeStatement fee			
			WHERE FeeStatementType=@FeeStatementType
			AND StudentId=@StudentId
			AND AcademicYearId= @AcademicYearId
			AND GradeId = @GradeId
			AND IsActive = 1
			AND IsDeleted = 0

        END

        COMMIT TRAN TRANS1
    
 
   SELECT 0 AS Result, 'Saved' AS Response
    END TRY

    BEGIN CATCH
        ROLLBACK TRAN TRANS1
        SELECT -1 AS Result, 'Error!' AS Response
        EXEC usp_SaveErrorDetail
        RETURN;
    END CATCH
END
GO
CREATE PROCEDURE [dbo].[sp_GetSiblingDiscountDetail]
    @StudentId bigint
AS
BEGIN
    SELECT
	   tsdd.StudentSiblingDiscountDetailId,
        tsdd.StudentId,
		ts.StudentName,
        tsdd.AcademicYearId,
		tsa.AcademicYear,
        tsdd.GradeId,
		tgm.GradeName,
        tsdd.DiscountPercent
    FROM 
        tblStudentSiblingDiscountDetail AS tsdd
    JOIN 
        tblGradeMaster AS tgm ON tsdd.GradeId = tgm.GradeId
    JOIN 
        tblSchoolAcademic AS tsa ON tsdd.AcademicYearId = tsa.SchoolAcademicId
    JOIN 
        tblStudent AS ts ON tsdd.StudentId = ts.StudentId
    WHERE 
        tsdd.StudentId = @StudentId
		AND tsdd.IsActive=1 AND tsdd.IsDeleted=0
END
GO
create proc [dbo].[sp_processOpenapplyInsertFirstTime]
as
begin

	 BEGIN TRY          
 BEGIN TRANSACTION TRANS1      
	truncate table tblStudent
	delete from   tblSection
	delete from tblparent

	insert into tblSection (SectionName,IsActive,IsDeleted,UpdateDate,UpdateBy)
	select 
		distinct status_level,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1 
	from OpenApplyStudents where status_level IS NOT NULL

	--Update Grade test
	update [OpenApplyStudents]
	set grade='KG 1' 
	where grade='KG1' 

	update [OpenApplyStudents]
	set grade='KG 2' 
	where grade='KG2'

	declare @SchoolId	int
	select top 1 @SchoolId	=SchoolId from tblSchoolMaster where IsActive=1 and IsDeleted=0

	declare 
		@StudentOpenApplyId	 int
		,@student_id	nvarchar(100)		
		,@GenderId	 int
		,@grade	nvarchar(100)	
		,@GradeId	int
		,@CostCenterId	int
		,@SectionId	int
		,@StudentName	nvarchar(100)	
		,@StudentArabicName	nvarchar(100)	
		,@StudentEmail	nvarchar(100)	
		,@DOB	datetime
		,@AdmissionDate	datetime
		,@StudentAddress	nvarchar(500)	
		,@StudentStatusId	int
		,@WithdrawDate	datetime
		,@WithdrawYear	datetime
		,@AdmissionYear	datetime

		,@IqamaNo	nvarchar(100)
		,@PassportNo	nvarchar(100)
		,@PassportExpiry	nvarchar(100)
		,@Mobile	nvarchar(100)
		,@PrinceAccount	bit

		,@country	nvarchar(100)
		,@NationalityId	bigint
		,@p_id_school_parent_id nvarchar(100)

	SELECT
		distinct 
			StudentOpenApplyId=os.id    
			,student_id=os.student_id                
			,GenderId=case when gender='Male' then 1 else 2 end
    
			,os.grade
			,GradeId=0--isnull(gm.GradeId, 0)     --default value, updating in next query           
			,CostCenterId=0--isnull(gm.CostCenterId, 0)                 --default value, updating in next query
			,SchoolId=@SchoolId                --default value, updating in next query           
			,SectionId=1                 --default value, updating in next query           
 
			,StudentName = (ltrim(rtrim(os.first_name))+ ' '+ ltrim(rtrim(os.last_name)))           
			,StudentArabicName = ltrim(rtrim(os.other_name))        
			,StudentEmail = ltrim(rtrim( isnull(os.[email],'')))        
			,DOB =case when os.birth_date is null then  cast( '1/1/1900' as date) else  cast(os.birth_date as date)   end                
			,AdmissionDate =case when os.enrolled_date is null then  cast( '1/1/1900' as date) else  cast( os.enrolled_date as date) end
			,StudentAddress =ltrim(rtrim( isnull(os.full_address,'')))              
			,StudentStatusId =1        
		
			,WithdrawDate = os.withdrawn_date                
			,WithdrawYear = datepart(year, cast(os.withdrawn_date as date))                
			,AdmissionYear = os.admitted_date                

			,IqamaNo=os.IqamaNo  --Update filed when new chnages done
			,PassportNo=isnull(passport_id,'')  --Update filed when new chnages done                
			,PassportExpiry=null  --Update filed when new chnages done                
			,Mobile=os.mobile_phone  --Update filed when new chnages done                
			,PrinceAccount=os.PrinceAccount  --Update filed when new chnages done
		
			,country=isnull(os.country,os.nationality)   
			,NationalityId=0--isnull(tc.CountryId, 999999)  
			,p_id_school_parent_id=os.p_id_school_parent_id
			,status_level
			into #OpenApplyStudentsTemp
		FROM                  
		[dbo].[OpenApplyStudents] os 
		--left join tblGradeMaster gm on (os.grade COLLATE SQL_Latin1_General_CP1_CI_AS=gm.GradeName )
		--left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName  
		where os.student_id  is not null

	--Update Grade Id
	update os
	set 
		os.GradeId=ISNULL( gm.GradeId,0)
		,os.CostCenterId=ISNULL( gm.CostCenterId,0)
	from #OpenApplyStudentsTemp os
	left join tblGradeMaster gm on (ltrim(rtrim(os.grade)) COLLATE SQL_Latin1_General_CP1_CI_AS=ltrim(rtrim(gm.GradeName)) )

	update os
	set os.NationalityId=ISNULL( tc.CountryId,0)
	from #OpenApplyStudentsTemp os
	left join tblCountryMaster tc on ltrim(rtrim(os.country)) COLLATE SQL_Latin1_General_CP1_CI_AS=ltrim(rtrim(tc.CountryName  ))

	declare @SectionIDNew int=0
	select top 1 @SectionIDNew=SectionId from tblSection 

	update os
	set os.SectionId=ISNULL( tc.SectionId,@SectionIDNew)
	from #OpenApplyStudentsTemp os
	left join tblSection tc on ltrim(rtrim(os.status_level)) COLLATE SQL_Latin1_General_CP1_CI_AS=ltrim(rtrim(tc.SectionName  ))
	
	DECLARE cur_emp CURSOR FOR
 
	 SELECT
		distinct 
			StudentOpenApplyId=os.StudentOpenApplyId    
			,student_id=os.student_id                
			,GenderId=os.GenderId    
			,Grade=os.grade
			,GradeId=os.GradeId     --default value, updating in next query           
			,CostCenterId=os.CostCenterId                --default value, updating in next query
			,SchoolId=os.SchoolId                  --default value, updating in next query           
			,SectionId=os.SectionId                 --default value, updating in next query           
 
			,StudentName = os.StudentName             
			,StudentArabicName = os.StudentArabicName       
			,StudentEmail =os.StudentEmail     
			,DOB =os.DOB
			,AdmissionDate =os.AdmissionDate
			,StudentAddress =os.StudentAddress
			,StudentStatusId =os.StudentStatusId       
		
			,WithdrawDate = os.WithdrawDate           
			,WithdrawYear = os.WithdrawYear               
			,AdmissionYear =os.AdmissionYear               

			,IqamaNo=os.IqamaNo  --Update filed when new chnages done
			,PassportNo=os.PassportNo  --Update filed when new chnages done                
			,PassportExpiry=os.PassportExpiry  --Update filed when new chnages done                
			,Mobile=os.Mobile  --Update filed when new chnages done                
			,PrinceAccount=os.PrinceAccount  --Update filed when new chnages done
		
			,country=os.country   
			,NationalityId=os.NationalityId  
			,p_id_school_parent_id=os.p_id_school_parent_id
		FROM                  
		#OpenApplyStudentsTemp os

	OPEN cur_emp
	IF @@CURSOR_ROWS > 0
	BEGIN 
		FETCH NEXT FROM cur_emp 
		
		INTO @StudentOpenApplyId,@student_id,@GenderId,@grade,@GradeId	,@CostCenterId	,@SchoolId	,@SectionId
				,@StudentName,@StudentArabicName,@StudentEmail,@DOB,@AdmissionDate,@StudentAddress,@StudentStatusId
				,@WithdrawDate,@WithdrawYear,@AdmissionYear
				,@IqamaNo,@PassportNo,@PassportExpiry,@Mobile,@PrinceAccount
				,@country,@NationalityId,@p_id_school_parent_id

		WHILE @@Fetch_status = 0
		BEGIN

			--PRINT 'student_id : '+ convert(varchar(20),@student_id)+' , GenderId : '+convert(varchar(20),@GenderId)+',grade : '+convert(varchar(20),@grade)+',GradeId : '+convert(varchar(20),@GradeId)+',CostCenterId : '+convert(varchar(20),@CostCenterId)+',SchoolId : '+convert(varchar(20),@SchoolId)+',SectionId : '+convert(varchar(20),@SectionId)

			---parent table column
			declare @ParentId	bigint =0;
			declare @ParentCode	nvarchar(100)=@p_id_school_parent_id;
			declare @ParentImage	nvarchar(100)='';
			
			declare @FatherName	nvarchar(100)='';
			declare @FatherArabicName	nvarchar(100)='';
			declare @FatherNationalityId	int=0;
			declare @FatherMobile	nvarchar(100)='';
			declare @FatherEmail	nvarchar(100)='';
			declare @IsFatherStaff	bit=0;
			
			declare @MotherName	nvarchar(100)='';
			declare @MotherArabicName	nvarchar(100)='';
			declare @MotherNationalityId	int=0;
			declare @MotherMobile	nvarchar(100)='';
			declare @MotherEmail	nvarchar(100)='';
			declare @IsMotherStaff	bit=0;
			
			declare @FatherIqamaNo	nvarchar(100)=''
			declare @MotherIqamaNo	nvarchar(100)=''
			
			declare @OpenApplyFatherId	bigint=0
			declare @OpenApplyMotherId	bigint=0
			declare @OpenApplyStudentId bigint=0

			select top 1
				@ParentImage	=''
				,@FatherName	=(ltrim(rtrim(isnull([first_name],'')))+' '+ltrim(rtrim(isnull([last_name],''))))
				,@FatherArabicName	=isnull([other_name],'')
				,@FatherNationalityId	=isnull(CountryId, 0)  
				,@FatherMobile	=isnull(mobile_phone,'')
				,@FatherEmail	=ltrim(rtrim(isnull([email],'')))
				,@IsFatherStaff	=0
				,@FatherIqamaNo=IqamaNo
				,@OpenApplyFatherId =id                    
				,@OpenApplyStudentId=isnull(isnull(@OpenApplyStudentId,@student_id),student_id)
			from
			(
				select top 1 
					ROW_NUMBER() over(partition by stuParent.id order by id desc) as FatherRowNo
					,stuParent.*,CountryId=isnull(tc.CountryId ,0)
					from 
					[OpenApplyStudentParentMap] stuMap					
					inner join OpenApplyparents stuParent
					on stumap.OpenApplyParentId=stuParent.id
					left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName  
					where stuParent.gender='Male'
					and stuMap.OpenApplyStudentId=@StudentOpenApplyId
			)tFather

			select top 1
				@ParentImage	=''
				,@MotherName	=(ltrim(rtrim([first_name]))+' '+ltrim(rtrim([last_name])))
				,@MotherArabicName	=[other_name]
				,@MotherNationalityId	=isnull(CountryId, 0)  
				,@MotherMobile	=mobile_phone
				,@MotherEmail	=ltrim(rtrim([email]))
				,@IsMotherStaff	=0
				,@MotherIqamaNo=IqamaNo
				,@OpenApplyMotherId =id                    
				,@OpenApplyStudentId=isnull(isnull(@OpenApplyStudentId,@student_id),student_id)
			from
			(
				select top 1 
					ROW_NUMBER() over(partition by stuParent.id order by id desc) as FatherRowNo
					,stuParent.*,CountryId=isnull(tc.CountryId ,0)
					from 
					[OpenApplyStudentParentMap] stuMap 
					inner join OpenApplyparents stuParent on stumap.OpenApplyParentId=stuParent.id
					left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName  
					where stuParent.gender='Female'
					and stuMap.OpenApplyStudentId=@StudentOpenApplyId
			)tMother

			---father info not exist then copy mother info as father
			--if @FatherName is null
			--begin
			--	set @FatherName	=@MotherName
			--	set @FatherArabicName	=@MotherArabicName
			--	set @FatherNationalityId	=@MotherNationalityId
			--	set @FatherMobile	=@MotherMobile
			--	set @FatherEmail	=@MotherMobile
			--end

			---mother info not exist then copy father info as mother
			--if @MotherName is null
			--begin
			--	set @MotherName	=@FatherName
			--	set @MotherArabicName	=@FatherArabicName
			--	set @MotherNationalityId	=@FatherNationalityId
			--	set @MotherMobile	=@FatherMobile
			--	set @MotherEmail	=@FatherEmail
			--end

			declare @NewParentId bigint=0;

			if not exists(select 1 from tblParent where ParentCode=@ParentCode)
			begin
				insert into tblParent
				(
					ParentCode,ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail,IsFatherStaff
					,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff
					,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId
					,IsActive,IsDeleted,UpdateDate,UpdateBy
				)
				select 
					@ParentCode,@ParentImage,@FatherName,@FatherArabicName,@FatherNationalityId,@FatherMobile,@FatherEmail,@IsFatherStaff
					,@MotherName,@MotherArabicName,@MotherNationalityId,@MotherMobile,@MotherEmail,@IsMotherStaff 
					,@FatherIqamaNo,@MotherIqamaNo,@OpenApplyFatherId,@OpenApplyMotherId,@OpenApplyStudentId
					,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1

				select @NewParentId =scope_identity();
			end
			else
			begin
				select top 1  @NewParentId=ParentId from tblParent where ParentCode=@ParentCode				
			end

				insert into tblstudent
				(
					StudentCode,StudentImage,ParentId,
					StudentName,StudentArabicName,StudentEmail,
					DOB,IqamaNo,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId
					,PassportNo,PassportExpiry,Mobile
					,StudentAddress,StudentStatusId,WithdrawDate
					,WithdrawAt,WithdrawYear
					,Fees,IsGPIntegration,TermId,AdmissionYear,PrinceAccount,p_id_school_parent_id
					,IsActive,IsDeleted,UpdateDate,UpdateBy
				)
				select 
					StudentCode=@student_id,StudentImage=''	,ParentId=@NewParentId
					,@StudentName,@StudentArabicName,@StudentEmail
					,@DOB,@IqamaNo,@NationalityId,@GenderId,@AdmissionDate,@GradeId	,@CostCenterId,@SectionId
					,@PassportNo,@PassportExpiry,@Mobile
					,@StudentAddress,@StudentStatusId,@WithdrawDate
					,WithdrawAt=null,@WithdrawYear
					,Fees=0,IsGPIntegration=0,TermId=1
					,@AdmissionYear,@PrinceAccount,@p_id_school_parent_id				
					,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1

			FETCH NEXT FROM cur_emp INTO @StudentOpenApplyId,@student_id,@GenderId,@grade,@GradeId	,@CostCenterId	,@SchoolId	,@SectionId
				,@StudentName,@StudentArabicName,@StudentEmail,@DOB,@AdmissionDate,@StudentAddress,@StudentStatusId
				,@WithdrawDate,@WithdrawYear,@AdmissionYear
				,@IqamaNo,@PassportNo,@PassportExpiry,@Mobile,@PrinceAccount
				,@country,@NationalityId,@p_id_school_parent_id
		END
	END
	
	CLOSE cur_emp;
	DEALLOCATE cur_emp;

   drop table #OpenApplyStudentsTemp

    COMMIT TRAN TRANS1          
	 SELECT 0 AS Result, 'Saved' AS Response        
  END TRY          
  BEGIN CATCH          
   ROLLBACK TRAN TRANS1             
   SELECT -1 AS Result, 'Error!' AS Response          
   EXEC usp_SaveErrorDetail          
   RETURN          
  END CATCH          
end
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudentOtherDiscountDetail] 
	@LoginUserId int
   ,@StudentOtherDiscountDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentOtherDiscountDetail
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId		
		
		DECLARE @DiscountName NVARCHAR(250)
		DECLARE @DiscountAmount DECIMAL(18,4)
		SELECT TOP 1 @DiscountName=DiscountName,@DiscountAmount=DiscountAmount from tblStudentOtherDiscountDetail WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId 	
		--Insert discount cancled entry in statement
		DECLARE @FeeStatementType NVARCHAR(50)=@DiscountName +' Discount Cancelled'

		INSERT INTO [dbo].[tblFeeStatement]
		(
			[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
			,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
		)
		SELECT top 1
			FeeStatementType=@FeeStatementType 		
			,FeeType=ssdd.FeeTypeId
			,FeeAmount=0
			,PaidAmount=ssdd.DiscountAmount*-1
			,StudentId=stu.StudentId
			,ParentId=stu.ParentId
			,StudentName=stu.StudentName
			,ParentName=par.ParentId
			,AcademicYearId=ssdd.AcademicYearId
			,GradeId=ssdd.GradeId
			,IsActive=1
			,IsDeleted=0
			,UpdateDate=GETDATE()
			,UpdateBy=0
		FROM tblStudentOtherDiscountDetail ssdd  		
		join tblStudent stu on ssdd.StudentId=stu.StudentId
		join tblParent par on stu.ParentId=par.ParentId
		WHERE ssdd.StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId  
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
