ALTER proc [dbo].[sp_ApproveNotification]  
 @LoginUserId int=1  
 ,@NotificationIds nvarchar(max)    ='ALL'                  
as                    
begin      
  
 declare @isUpdate int =1  
 BEGIN TRY  
  select distinct isnull(country,nationality) As country into #OpenApplyCountry from [OpenApplyStudents] z                      
                
  insert into #OpenApplyCountry                
  select distinct isnull(country,nationality) from OpenApplyParents z      
      
  delete t                      
  from #OpenApplyCountry t                      
  inner join tblCountryMaster z                      
  on t.country COLLATE SQL_Latin1_General_CP1_CI_AS =z.CountryName                      
                      
  delete from #OpenApplyCountry where country is NULL                      
    
  if exists(select 1 from #OpenApplyCountry)                      
  begin                      
   insert into tblCountryMaster(CountryName,CountryCode,IsActive,IsDeleted,UpdateDate,UpdateBy)                      
   select country, '' , 1,0, getdate(),@LoginUserId from  #OpenApplyCountry                      
  end                      
                       
  ---End: Master Data- Country                    
          
  insert into tblSection (SectionName,IsActive,IsDeleted,UpdateDate,UpdateBy)          
  select           
   distinct status_level,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1           
  from OpenApplyStudents where status_level IS NOT NULL         
  and status_level collate SQL_Latin1_General_CP1256_CI_AS not in (select SectionName from tblSection)        
                  
  create table #ApprovableNotification            
  (            
   NotificationId bigint,          
   RecordId nvarchar(400),            
   RecordType nvarchar(400)            
  )            
            
  if(@NotificationIds ='ALL')            
  begin            
   insert into #ApprovableNotification                 
   select             
    distinct notific.NotificationId, notific.RecordId,notific.RecordType             
   from                        
   [tblNotification] notific              
  end            
  else            
  begin            
   insert into #ApprovableNotification                 
   select             
   distinct notific.NotificationId,  notific.RecordId,notific.RecordType             
   from                        
   [tblNotification] notific                      
   inner join                       
   (                      
    SELECT   
     cast(value as int)as NotificationId                      
    FROM STRING_SPLIT(@NotificationIds, ',')                      
    WHERE RTRIM(value) <> ''                      
   )t                       
   on notific.NotificationId= t.NotificationId                 
  end  
                  
  --Start : Work for Student                      
                      
  select *                       
  into #student  
  from                       
  (                      
  select                      
  distinct                      
  student_id=os.student_id                      
  ,case when gender='Male' then 1 else 2 end GenderId                      
  --,GradeId=gm.GradeId                      
  --,CostCenterId=gm.CostCenterId                      
  ,GradeId=1                      
  ,CostCenterId=1                      
  ,SchoolId=1                      
  ,SectionId=1                      
  ,StudentName = (ltrim(rtrim(os.first_name))+ ' '+ ltrim(rtrim(os.last_name)))                 
  ,StudentArabicName = ltrim(rtrim(os.other_name))              
  ,StudentEmail = ltrim(rtrim( isnull(os.[email],'')))              
  ,DOB = cast(os.birth_date as date)                         
  ,AdmissionDate = cast(os.enrolled_date as date)                      
  ,StudentAddress = os.full_address                      
  ,StudentStatusId =1                 
  ,WithdrawDate = os.withdrawn_date                      
  ,WithdrawYear = datepart(year, cast(os.withdrawn_date as date))                      
  ,AdmissionYear = os.admitted_date                      
  ,IqamaNo=os.IqamaNo  --Update filed when new chnages done                      
  --,NationalityId=isnull(tc.CountryId,1)    --Update filed when new chnages done                      
  ,NationalityId=999999                      
  ,PassportNo=isnull(passport_id,'')  --Update filed when new chnages done                      
  ,PassportExpiry=null  --Update filed when new chnages done                      
  ,Mobile=os.mobile_phone  --Update filed when new chnages done                      
  ,PrinceAccount=os.PrinceAccount  --Update filed when new chnages done                        
                      
  ,os.grade                     
  ,country=isnull(os.country,os.nationality)                
  ,os.p_id_school_parent_id        
  ,os.status_level      
  ,OpenApplyStudentId=os.id  
  from                       
  [dbo].[OpenApplyStudents] os                       
  inner join  #ApprovableNotification  notific                        
  on os.id=notific.RecordId                   
  where notific.RecordType='Student'                       
  and os.id is not null                       
  and os.[status]='enrolled'                      
  and os.student_id is not null                       
  )t                      
                      
  update os                      
  set                      
  os.GradeId=gm.GradeId                      
  ,os.CostCenterId=gm.CostCenterId                      
  from #student os                      
  inner join tblGradeMaster gm on os.grade COLLATE SQL_Latin1_General_CP1_CI_AS=gm.GradeName                      
                      
  update os                      
  set                      
  os.NationalityId=tc.CountryId                      
  from #student os                      
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                      
               
  declare @SectionIDNew int=0          
  select top 1 @SectionIDNew=SectionId from tblSection           
          
  --If somehow record not available then update first sectionid        
  update os          
  set os.SectionId=ISNULL( tc.SectionId,@SectionIDNew)          
  from #student os          
  left join tblSection tc on ltrim(rtrim(os.status_level)) COLLATE SQL_Latin1_General_CP1_CI_AS=ltrim(rtrim(tc.SectionName  ))  
  --End : Work for Student  
  
  --Work for Parent  
  
  select vw.*   
  into #ParentInfo  
  from vw_GetStudentOpenApplyParentInfo vw  
  join #student os  on vw.OpenApplyStudentId=os.OpenApplyStudentId  
  
  ---IF only parent record come for approval  
  insert into #ParentInfo  
  select vw.*  
  from vw_GetStudentOpenApplyParentInfo vw  
  join #ApprovableNotification os  on (vw.OpenApplyFatherId=os.RecordId OR vw.OpenApplyMotherId=os.RecordId)  
   
  select distinct *   
  into #ParentInfo2  
  from #ParentInfo  
       
  insert into #ApprovableNotification                 
  select             
   distinct notific.NotificationId,  notific.RecordId,notific.RecordType             
  from                        
  [tblNotification] notific      
  WHERE RecordId IN       
  (      
   SELECT   
    stuMap.OpenApplyParentId    
   FROM #student  stu   
   inner join [OpenApplyStudentParentMap] stuMap on stuMap.OpenApplyStudentId=stu.OpenApplyStudentId  
  )  
  
  if(@isUpdate =1)  
  begin   
   print 'parent merge started'  
   delete from #ParentInfo2 where StudentCode=''  
  
   select *  
   into #ParentInfo3  
   from   
   (  
   select ROW_NUMBER() over(partition by ParentCode order by OpenApplyFatherId desc)as RN ,* from #ParentInfo2  
   )t  
   where t.RN=1  
  
   MERGE tblParent AS TARGET                      
   USING #ParentInfo3 AS SOURCE                       
   ON                       
   (                      
   ltrim(rtrim(cast( TARGET.ParentCode as nvarchar(100)))) COLLATE SQL_Latin1_General_CP1_CI_AS= ltrim(rtrim(cast(SOURCE.ParentCode as nvarchar(100))))  
   )                 
               
   --When records are matched, update the records if there is any change                      
   WHEN MATCHED --AND TARGET.ProductName <> SOURCE.ProductName OR TARGET.Rate <> SOURCE.Rate                       
   THEN UPDATE                       
   SET                       
   TARGET.ParentImage=      isnull(SOURCE.ParentImage,'')  
   ,TARGET.FatherName=   isnull(SOURCE.FatherName,'')  
   ,TARGET.FatherArabicName=    isnull(SOURCE.FatherArabicName,'')  
   ,TARGET.FatherNationalityId=    isnull(SOURCE.FatherNationalityId,99999)                      
   ,TARGET.FatherMobile=     isnull(SOURCE.FatherMobile,'')  
   ,TARGET.FatherEmail=      isnull(SOURCE.FatherEmail,'')  
   ,TARGET.IsFatherStaff=     isnull(SOURCE.IsFatherStaff,0)                      
                               
   ,TARGET.MotherName=      isnull(SOURCE.MotherName,'')                      
   ,TARGET.MotherArabicName=    isnull(SOURCE.MotherArabicName,'')  
   ,TARGET.MotherNationalityId=    isnull(SOURCE.MotherNationalityId,99999)  
   ,TARGET.MotherMobile=     isnull(SOURCE.MotherMobile,'')  
   ,TARGET.MotherEmail=      isnull(SOURCE.MotherEmail,'')  
   ,TARGET.IsMotherStaff=     isnull(SOURCE.IsMotherStaff,'')  
   ,TARGET.FatherIqamaNo=     isnull(SOURCE.FatherIqamaNo,'')  
   ,TARGET.MotherIqamaNo=     isnull(SOURCE.MotherIqamaNo,'')  
                       
   ,TARGET.OpenApplyFatherId=  cast(isnull(SOURCE.OpenApplyFatherId,0) as bigint)                      
   ,TARGET.OpenApplyMotherId=   cast( isnull(SOURCE.OpenApplyMotherId,0) as bigint)                      
   ,TARGET.OpenApplyStudentId=   cast( isnull(SOURCE.OpenApplyStudentId,0) as bigint)                      
                      
   --When no records are matched, insert the incoming records from source table to target table                      
   WHEN NOT MATCHED BY TARGET                       
                      
   THEN INSERT                       
   (                      
   ParentCode,                      
   ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail,IsFatherStaff                      
   ,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff                      
   ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId,                      
   IsActive,IsDeleted,UpdateDate,UpdateBy                 
   )                       
   VALUES                       
   (                       
   SOURCE.ParentCode                      
   ,isnull(SOURCE.ParentImage,'')  
   ,isnull(SOURCE.FatherName,'')  
   ,isnull(SOURCE.FatherArabicName,'')  
   ,isnull(SOURCE.FatherNationalityId,99999)  
   ,isnull(SOURCE.FatherMobile,'')  
   ,isnull(SOURCE.FatherEmail,'')  
   ,isnull(SOURCE.IsFatherStaff  ,0)  
   ,isnull(SOURCE.MotherName,'')  
   ,isnull(SOURCE.MotherArabicName,'')  
   ,isnull(SOURCE.MotherNationalityId,99999)  
   ,isnull(SOURCE.MotherMobile,'')  
   ,isnull(SOURCE.MotherEmail,'')  
   ,isnull(SOURCE.IsMotherStaff  ,0)  
   ,isnull(SOURCE.FatherIqamaNo,'')  
   ,isnull(SOURCE.MotherIqamaNo,'')  
   ,isnull(SOURCE.OpenApplyFatherId,0)  
   ,isnull(SOURCE.OpenApplyMotherId,0)  
   ,isnull(SOURCE.OpenApplyStudentId,0)  
   ,1,0, getdate(),@LoginUserId                      
   );                      
           
      
   -----Start: Student update       
   print 'student merge started'  
  
   MERGE tblStudent AS TARGET                      
   USING #student AS SOURCE                       
   ON (cast( TARGET.StudentCode as nvarchar(100)) COLLATE SQL_Latin1_General_CP1_CI_AS= cast(SOURCE.student_id as nvarchar(100)))                       
   --When records are matched, update the records if there is any change                      
   WHEN MATCHED --AND TARGET.ProductName <> SOURCE.ProductName OR TARGET.Rate <> SOURCE.Rate                       
   THEN UPDATE                       
   SET                       
   TARGET.StudentName = SOURCE.StudentName,                    
   TARGET.StudentArabicName = SOURCE.StudentArabicName,                      
   TARGET.StudentEmail = isnull(SOURCE.StudentEmail,''),                      
   TARGET.DOB = SOURCE.DOB,                      
   TARGET.GenderId = SOURCE.GenderId,                      
   TARGET.AdmissionDate = isnull(SOURCE.AdmissionDate, getdate()),                      
   TARGET.StudentAddress =isnull( SOURCE.StudentAddress,''),                      
   TARGET.StudentStatusId = SOURCE.StudentStatusId,                      
   TARGET.WithdrawDate =SOURCE.WithdrawDate,                      
   TARGET.WithdrawYear = SOURCE.WithdrawYear,                      
   TARGET.AdmissionYear =SOURCE.AdmissionYear,                      
   TARGET.GradeId =SOURCE.GradeId,                      
   TARGET.CostCenterId =SOURCE.CostCenterId,                      
   TARGET.SectionId =SOURCE.SectionId,                      
   TARGET.IqamaNo =SOURCE.IqamaNo,                      
   TARGET.NationalityId =SOURCE.NationalityId,                      
   TARGET.PassportNo =SOURCE.PassportNo,                      
   TARGET.PassportExpiry =SOURCE.PassportExpiry,                      
   TARGET.Mobile =SOURCE.Mobile,                      
   TARGET.PrinceAccount =SOURCE.PrinceAccount,                      
   TARGET.p_id_school_parent_id =SOURCE.p_id_school_parent_id                
                        
   --When no records are matched, insert the incoming records from source table to target table                      
   WHEN NOT MATCHED BY TARGET                       
                      
   THEN INSERT                       
   (                      
   StudentCode ,StudentName,StudentArabicName,StudentEmail ,DOB ,GenderId ,                      
   AdmissionDate ,StudentAddress ,StudentStatusId ,WithdrawDate ,WithdrawYear,AdmissionYear,                      
   GradeId ,CostCenterId ,SectionId ,IqamaNo ,NationalityId ,PassportNo,PassportExpiry ,                      
   Mobile ,PrinceAccount , p_id_school_parent_id,                     
   IsActive,IsDeleted,UpdateDate,UpdateBy,                      
   IsGPIntegration,TermId                 
   )                       
   VALUES                       
   (                       
   SOURCE.student_id,SOURCE.StudentName,isnull( SOURCE.StudentArabicName,''),isnull(SOURCE.StudentEmail,''),                      
   SOURCE.DOB,SOURCE.GenderId,                      
   isnull(SOURCE.AdmissionDate, getdate()),isnull( SOURCE.StudentAddress,''),SOURCE.StudentStatusId,                      
   SOURCE.WithdrawDate,SOURCE.WithdrawYear,SOURCE.AdmissionYear,                      
   SOURCE.GradeId,SOURCE.CostCenterId,SOURCE.SectionId,SOURCE.IqamaNo,SOURCE.NationalityId,SOURCE.PassportNo,SOURCE.PassportExpiry,                      
   SOURCE.Mobile,SOURCE.PrinceAccount,      source.p_id_school_parent_id,                
   1,0, getdate(),@LoginUserId,                      
   0,1                      
   );                      
   ---End: Student Update                      
           
   ----------UPdate parent Id            
        
   update stu                      
   set                      
   stu.ParentId=par.ParentId                      
   from tblStudent stu                      
   inner join tblParent par                      
   on stu.p_id_school_parent_id COLLATE SQL_Latin1_General_CP1_CI_AS=cast(par.ParentCode    as nvarchar(500))  
  
   --Update selected notification as approved                      
                      
   --update notific                      
   --set       
   --IsApproved=1                      
   --from                        
   --[tblNotification] notific                     
   --inner join #ApprovableNotification app                      
   --on notific.NotificationId=app.NotificationId               
                
   delete notific               
   from [tblNotification] notific                      
   inner join #ApprovableNotification app                      
   on notific.NotificationId=app.NotificationId   
     
   delete notific               
   from tblNotificationGroupDetail notific                      
   inner join #ApprovableNotification app                      
   on notific.TableRecordId=app.NotificationId       
                      
   select notific.NotificationGroupId, NotificationTypeId,NotificationAction,count(1) as NotificationGroupCount    
   into #notificationGroupDetail  
   from tblNotificationGroupDetail notific  
   group by notific.NotificationGroupId       ,NotificationTypeId,NotificationAction  
     
   update t               
   set              
   t.NotificationCount=isnull(t2.NotificationGroupCount,0)              
   from tblNotificationGroup t              
   inner join #notificationGroupDetail t2 on   
   t.NotificationTypeId=t2.NotificationTypeId  
   and t.NotificationAction=t2.NotificationAction  
  
  end  
    
  IF OBJECT_ID('tempdb.dbo.#ApprovableNotification', 'U') IS NOT NULL                      
  DROP TABLE #ApprovableNotification;                       
                      
  IF OBJECT_ID('tempdb.dbo.#student', 'U') IS NOT NULL                      
  DROP TABLE #student;                       
                      
  IF OBJECT_ID('tempdb.dbo.#OpenApplyCountry', 'U') IS NOT NULL                      
  DROP TABLE #OpenApplyCountry;                       
                      
  IF OBJECT_ID('tempdb.dbo.#student', 'U') IS NOT NULL                      
  DROP TABLE #student;                       
                      
  IF OBJECT_ID('tempdb.dbo.#ParentInfo', 'U') IS NOT NULL                      
  DROP TABLE #ParentInfo;                       
                      
  IF OBJECT_ID('tempdb.dbo.#ParentFather', 'U') IS NOT NULL                      
  DROP TABLE #ParentFather;                       
                      
  IF OBJECT_ID('tempdb.dbo.#ParentFatherOther', 'U') IS NOT NULL                      
  DROP TABLE #ParentFatherOther;                       
         
  IF OBJECT_ID('tempdb.dbo.#ParentMother', 'U') IS NOT NULL                      
  DROP TABLE #ParentMother;                       
                        
  IF OBJECT_ID('tempdb.dbo.#ParentMotherOther', 'U') IS NOT NULL                      
  DROP TABLE #ParentMotherOther;                       
                     
  IF OBJECT_ID('tempdb.dbo.#ParentInfo2', 'U') IS NOT NULL                      
  DROP TABLE #ParentInfo2;              
     
  IF OBJECT_ID('tempdb.dbo.#notificationGroupDetail', 'U') IS NOT NULL                      
  DROP TABLE #notificationGroupDetail;                       
  
  ---Start: Master Data- Country                 
             
  SELECT 0 AS Result, 'Saved' AS Response        
  END TRY                        
                        
  BEGIN CATCH                        
                   
  DECLARE @ErrorMessage NVARCHAR(4000);                  
  DECLARE @ErrorSeverity INT;                  
  DECLARE @ErrorState INT;                  
                  
  SELECT                   
   @ErrorMessage = ERROR_MESSAGE() + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)),                  
   @ErrorSeverity = ERROR_SEVERITY(),                
   @ErrorState = ERROR_STATE();                  
                  
  RAISERROR (@ErrorMessage, -- Message text.                  
   @ErrorSeverity, -- Severity.                  
   @ErrorState -- State.                  
  );                  
                  
  SELECT -1 AS Result, 'Error!' AS Response                        
  EXEC usp_SaveErrorDetail                        
  RETURN                        
  END CATCH                        
END 
GO

ALTER PROC [dbo].[sp_ApproveNotifications]      
@LoginUserId int=0      
,@NotificationGroupDetailIds nvarchar(max)=''    
,@NotificationGroupId int= 0    
,@NotificationTypeId int=0    
AS      
BEGIN      
 BEGIN TRY      
 BEGIN TRANSACTION TRANS1      
     
 if(@NotificationGroupDetailIds = '')      
 begin      
  SELECT -1 AS Result, 'Error!' AS Response      
 end      
 else      
 begin      
 if exists( select * from tblNotificationTypeMaster where NotificationTypeId=@NotificationTypeId and NotificationType='OpenApplyRecordProcessing')    
 begin  
  exec sp_ApproveNotification @LoginUserId,@NotificationGroupDetailIds      
 end    
 else    
 begin    
        
  select       
   ngd.* , nt.NotificationType             
  into #ApprovableNotificationList               
  from                
  tblNotificationGroupDetail ngd          
  INNER JOIN tblNotificationTypeMaster nt      
  ON ngd.NotificationTypeId=nt.NotificationTypeId      
  inner join               
  (              
   SELECT cast(value as int)as NotificationGroupDetailId              
   FROM STRING_SPLIT(@NotificationGroupDetailIds, ',')              
   WHERE RTRIM(value) <> ''              
  )t               
  on ngd.NotificationGroupDetailId= t.NotificationGroupDetailId    
    
   DECLARE @NotificationGroupDetailId INT, @TableRecordId INT, @NotificationType NVARCHAR(100), @NotificationIds nvarchar(max)      
   set @NotificationIds=''      
      
   --Declare a cursor        
   DECLARE PrintCustomers CURSOR        
   FOR        
 SELECT NotificationGroupDetailId, NotificationType, TableRecordId       
 FROM #ApprovableNotificationList        
      
   --Open cursor        
   OPEN PrintCustomers        
      
   --Fetch the record into the variables.        
   FETCH NEXT FROM PrintCustomers INTO        
   @NotificationGroupDetailId, @NotificationType ,@TableRecordId      
      
   WHILE @@FETCH_STATUS = 0        
   BEGIN        
    IF (@NotificationType = 'OpenApplyRecordProcessing'  )      
    BEGIN      
      
  if(@NotificationIds = '')      
  begin      
   set @NotificationIds =@NotificationIds+ cast(@TableRecordId as nvarchar(50))      
  end      
  else      
  begin      
   set @NotificationIds=@NotificationIds+','+cast(@TableRecordId as nvarchar(50))      
  end      
    
    END        
    else      
    begin       
  exec sp_ApproveNotificationById @LoginUserId,  @NotificationGroupDetailId      
    end      
         
    --Fetch the next record into the variables.        
    FETCH NEXT FROM PrintCustomers INTO        
    @NotificationGroupDetailId, @NotificationType ,@TableRecordId      
   END       
      
   --Close the cursor        
   CLOSE PrintCustomers        
        
   --Deallocate the cursor        
   DEALLOCATE PrintCustomers        
      
   --In the end call- sp_ApproveNotification      
   if(@NotificationIds !='' )      
   begin    
    set @NotificationIds=REVERSE(SUBSTRING(  REVERSE(@NotificationIds),    PATINDEX('%[A-Za-z0-9]%',REVERSE(@NotificationIds)),      
   LEN(@NotificationIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@NotificationIds)) - 1)   ) )         
   print @NotificationIds     
     exec sp_ApproveNotification @LoginUserId,@NotificationIds      
   end    
   else if(@NotificationGroupDetailIds='ALL')    
   begin    
  print @NotificationIds +'ALL'    
  exec sp_ApproveNotification @LoginUserId,'ALL'    
    
   end    
  end    
  end    
  COMMIT TRAN TRANS1              
  SELECT 0 AS Result, 'Saved' AS Response      
 END TRY      
 BEGIN CATCH      
 DECLARE @ErrorMessage NVARCHAR(4000);                
  DECLARE @ErrorSeverity INT;                
  DECLARE @ErrorState INT;                
                
  SELECT                 
     @ErrorMessage = ERROR_MESSAGE() + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)),                
     @ErrorSeverity = ERROR_SEVERITY(),              
     @ErrorState = ERROR_STATE();                
                
  RAISERROR (@ErrorMessage, -- Message text.                
     @ErrorSeverity, -- Severity.                
    @ErrorState -- State.                
  );                
                
                
   ROLLBACK TRAN TRANS1                      
   SELECT -1 AS Result, 'Error!' AS Response                      
   EXEC usp_SaveErrorDetail                      
   RETURN                      
    
 END CATCH      
     
END      
GO

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
	end TRY        
	begin catch
		SELECT -1 AS Result, 'Error!' AS Response    
		EXEC usp_SaveErrorDetail    
		select* from tblErrors        
		end catch
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

 ----Process GP integration
 exec [sp_ProcessGP_UniformInvoice] @invoiceno,@DestinationDB
    
 select 0 result  
 end TRY  
 begin catch  
   
 select -1 result  
 end catch  
  
END  