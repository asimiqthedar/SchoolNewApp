CREATE PROC [dbo].[sp_ApproveNotifications]    
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

CREATE proc [dbo].[sp_processOpenapplyInsertFirstTime]      
as      
begin      
      
  BEGIN TRY                
 BEGIN TRANSACTION TRANS1            
      
 insert into tblSection (SectionName,IsActive,IsDeleted,UpdateDate,UpdateBy)      
 select       
  distinct status_level,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1       
 from OpenApplyStudents where status_level IS NOT NULL     
 and status_level collate SQL_Latin1_General_CP1256_CI_AS not in (select SectionName from tblSection)    
  
 --Update Grade test      
 update [OpenApplyStudents]      
 set grade='KG 1'       
 where grade='KG1'       
      
 update [OpenApplyStudents]      
 set grade='KG 2'       
 where grade='KG2'      
      
 declare @SchoolId int      
 select top 1 @SchoolId =SchoolId from tblSchoolMaster where IsActive=1 and IsDeleted=0      
      
 declare       
  @StudentOpenApplyId  int      
  ,@student_id nvarchar(100)        
  ,@GenderId  int      
  ,@grade nvarchar(100)       
  ,@GradeId int      
  ,@CostCenterId int      
  ,@SectionId int      
  ,@StudentName nvarchar(100)       
  ,@StudentArabicName nvarchar(100)       
  ,@StudentEmail nvarchar(100)       
  ,@DOB datetime      
  ,@AdmissionDate datetime      
  ,@StudentAddress nvarchar(500)       
  ,@StudentStatusId int      
  ,@WithdrawDate datetime      
  ,@WithdrawYear datetime      
  ,@AdmissionYear datetime      
      
  ,@IqamaNo nvarchar(100)      
  ,@PassportNo nvarchar(100)      
  ,@PassportExpiry nvarchar(100)      
  ,@Mobile nvarchar(100)      
  ,@PrinceAccount bit      
      
  ,@country nvarchar(100)      
  ,@NationalityId bigint      
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
   ,AdmissionYear =datepart(year, cast(os.admitted_date as date))
      
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
      
  --If somehow record not available then update first sectionid    
 update os      
 set os.SectionId=ISNULL( tc.SectionId,@SectionIDNew)      
 from #OpenApplyStudentsTemp os      
 left join tblSection tc on ltrim(rtrim(os.status_level)) COLLATE SQL_Latin1_General_CP1_CI_AS=ltrim(rtrim(tc.SectionName  ))      
       
--update tblStudent set IsActive=0, IsDeleted=1  
--update tblParent set IsActive=0, IsDeleted=1  
  
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
        
  INTO @StudentOpenApplyId,@student_id,@GenderId,@grade,@GradeId ,@CostCenterId ,@SchoolId ,@SectionId      
    ,@StudentName,@StudentArabicName,@StudentEmail,@DOB,@AdmissionDate,@StudentAddress,@StudentStatusId      
    ,@WithdrawDate,@WithdrawYear,@AdmissionYear      
    ,@IqamaNo,@PassportNo,@PassportExpiry,@Mobile,@PrinceAccount      
    ,@country,@NationalityId,@p_id_school_parent_id      
      
  WHILE @@Fetch_status = 0      
  BEGIN      
      
  declare @ParentCode nvarchar(100)=@p_id_school_parent_id;      
    
  --------Start: student Not exists    
    
   ---parent table column      
   declare @ParentId bigint =0;      
       
   declare @ParentImage nvarchar(100)='';      
         
   declare @FatherName nvarchar(100)='';      
   declare @FatherArabicName nvarchar(100)='';      
   declare @FatherNationalityId int=0;      
   declare @FatherMobile nvarchar(100)='';      
   declare @FatherEmail nvarchar(100)='';      
   declare @IsFatherStaff bit=0;      
         
   declare @MotherName nvarchar(100)='';      
   declare @MotherArabicName nvarchar(100)='';      
   declare @MotherNationalityId int=0;      
   declare @MotherMobile nvarchar(100)='';      
   declare @MotherEmail nvarchar(100)='';      
   declare @IsMotherStaff bit=0;      
         
   declare @FatherIqamaNo nvarchar(100)=''      
   declare @MotherIqamaNo nvarchar(100)=''      
         
   declare @OpenApplyFatherId bigint=0      
   declare @OpenApplyMotherId bigint=0      
   declare @OpenApplyStudentId bigint=0    
    
   select top 1      
    @ParentImage =''      
    ,@FatherName =(ltrim(rtrim(isnull([first_name],'')))+' '+ltrim(rtrim(isnull([last_name],''))))      
    ,@FatherArabicName =isnull([other_name],'')      
    ,@FatherNationalityId =isnull(CountryId, 0)        
    ,@FatherMobile =isnull(mobile_phone,'')      
    ,@FatherEmail =ltrim(rtrim(isnull([email],'')))      
    ,@IsFatherStaff =0      
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
    @ParentImage =''      
    ,@MotherName =(ltrim(rtrim([first_name]))+' '+ltrim(rtrim([last_name])))      
    ,@MotherArabicName =[other_name]      
    ,@MotherNationalityId =isnull(CountryId, 0)        
    ,@MotherMobile =mobile_phone      
    ,@MotherEmail =ltrim(rtrim([email]))      
    ,@IsMotherStaff =0      
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
       
 declare @NewParentId bigint=0;      
 select top 1  @NewParentId=isnull(ParentId,0) from tblParent where ParentCode=@ParentCode          
    
 ---Insert if student not exists else update    
 if not exists(select 1 from tblStudent where StudentCode=@student_id)    
 begin    
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
  StudentCode=@student_id,StudentImage='' ,ParentId=@NewParentId      
  ,@StudentName,@StudentArabicName,@StudentEmail      
  ,@DOB,@IqamaNo,@NationalityId,@GenderId,@AdmissionDate,@GradeId ,@CostCenterId,@SectionId      
  ,@PassportNo,@PassportExpiry,@Mobile      
  ,@StudentAddress,@StudentStatusId,@WithdrawDate      
  ,WithdrawAt=null,@WithdrawYear      
  ,Fees=0,IsGPIntegration=0,TermId=1      
  ,@AdmissionYear,@PrinceAccount,@p_id_school_parent_id          
  ,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1      
 end    
 else  if(ltrim(rtrim(@student_id)) !='')  
 begin    
  --update student    
  update tblstudent    
  set    
   StudentImage=''     
   ----,ParentId=@NewParentId  -- parentalready available so no need to update    
   ,StudentName=@StudentName    
   ,StudentArabicName=@StudentArabicName    
   ,StudentEmail=@StudentEmail      
   ,DOB=@DOB    
   ,IqamaNo=@IqamaNo    
   ,NationalityId=@NationalityId    
   ,GenderId=@GenderId    
   ,AdmissionDate=@AdmissionDate    
   ,GradeId=@GradeId     
   ,CostCenterId=@CostCenterId    
   ,SectionId=@SectionId      
   ,PassportNo=@PassportNo    
   ,PassportExpiry=@PassportExpiry    
   ,Mobile=@Mobile      
   ,StudentAddress=@StudentAddress    
   ,StudentStatusId=@StudentStatusId    
   ,WithdrawDate=@WithdrawDate      
   ,WithdrawAt=null    
   ,WithdrawYear=@WithdrawYear      
   ,Fees=0,IsGPIntegration=0,TermId=1      
   ,AdmissionYear=@AdmissionYear    
   ,PrinceAccount=@PrinceAccount    
   ,p_id_school_parent_id=@p_id_school_parent_id          
   ,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1     
  where StudentCode=@student_id    
      
  update tblParent    
  set    
   ParentImage=@ParentImage    
   ,FatherName=@FatherName    
   ,FatherArabicName=@FatherArabicName    
   ,FatherNationalityId=@FatherNationalityId    
   ,FatherMobile=@FatherMobile    
   ,FatherEmail=@FatherEmail    
   ,IsFatherStaff=@IsFatherStaff    
   ,MotherName=@MotherName    
   ,MotherArabicName=@MotherArabicName    
   ,MotherNationalityId=@MotherNationalityId    
   ,MotherMobile=@MotherMobile    
   ,MotherEmail=@MotherEmail    
   ,IsMotherStaff=@IsMotherStaff    
   ,FatherIqamaNo=@FatherIqamaNo    
   ,MotherIqamaNo=@MotherIqamaNo    
   ,OpenApplyFatherId=@OpenApplyFatherId    
   ,OpenApplyMotherId=@OpenApplyMotherId    
   ,OpenApplyStudentId=@OpenApplyStudentId      
   ,IsActive=1,IsDeleted=0,UpdateDate=getdate(),UpdateBy=1    
  where ParentCode=@p_id_school_parent_id    
 end    
  --------END: Of student Not exists    
    
   FETCH NEXT FROM cur_emp INTO @StudentOpenApplyId,@student_id,@GenderId,@grade,@GradeId ,@CostCenterId ,@SchoolId ,@SectionId      
    ,@StudentName,@StudentArabicName,@StudentEmail,@DOB,@AdmissionDate,@StudentAddress,@StudentStatusId      
    ,@WithdrawDate,@WithdrawYear,@AdmissionYear      
    ,@IqamaNo,@PassportNo,@PassportExpiry,@Mobile,@PrinceAccount      
    ,@country,@NationalityId,@p_id_school_parent_id      
  END      
 END      
       
 CLOSE cur_emp;      
 DEALLOCATE cur_emp;      
  
 --Mark All student Inactive  
 update tSub  
 set tsub.IsActive=0, tsub.IsDeleted=1  
 from tblStudent tSub  
  
 update tSub  
 set tsub.IsActive=1, tsub.IsDeleted=0  
 from tblStudent tSub  
 join  
 (  
 select ROW_NUMBER() over(partition by StudentCode order by UpdateDate asc) as RowNum,  
 StudentCode, StudentId  
 from tblStudent  
 )t  
 on t.StudentCode=tSub.StudentCode and t.StudentId=tSub.StudentId   
 where t.RowNum=1  
      
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

CREATE PROCEDURE [dbo].[sp_SavePaymentMethod]  
 @PaymentMethodId bigint  
 ,@PaymentMethodCategoryId bigint  
 ,@PaymentMethodName nvarchar(200)  
 ,@DebitAccount nvarchar(200)  
 ,@CreditAccount nvarchar(200)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblPaymentMethod WHERE PaymentMethodName = @PaymentMethodName  
   AND PaymentMethodId <> @PaymentMethodId AND IsActive = 1)  
 BEGIN  
  SELECT -2 AS Result, 'Payment Method already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@PaymentMethodId = 0)  
   BEGIN  
    INSERT INTO tblPaymentMethod  
        (PaymentMethodCategoryId  
        ,PaymentMethodName  
        ,DebitAccount  
        ,CreditAccount  
      ,IsActive  
      ,IsDeleted  
      ,UpdateDate  
      ,UpdateBy)  
    VALUES  
        (@PaymentMethodCategoryId  
        ,@PaymentMethodName  
        ,@DebitAccount  
        ,@CreditAccount  
        ,1  
        ,0  
        ,GETDATE()  
        ,1)  
          
   END  
   ELSE  
   BEGIN  
    UPDATE tblPaymentMethod  
      SET PaymentMethodCategoryId = @PaymentMethodCategoryId  
      , PaymentMethodName = @PaymentMethodName  
      ,DebitAccount = @DebitAccount  
      ,CreditAccount = @CreditAccount  
       ,IsActive = 1    
       ,UpdateDate = GETDATE()  
       ,UpdateBy = 1  
    WHERE PaymentMethodId = @PaymentMethodId  
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

CREATE PROCEDURE [dbo].[sp_GetPaymentMethod]  
@PaymentMethodId bigint = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 Select PaymentMethodId, tpm.PaymentMethodCategoryId ,tpmc.CategoryName, PaymentMethodName, DebitAccount, CreditAccount, tpm.IsActive  
 from tblPaymentMethod as tpm  
 Join tblPaymentMethodCategory as tpmc on tpm.PaymentMethodCategoryId = tpmc.PaymentMethodCategoryId   
 WHERE PaymentMethodId = CASE WHEN @PaymentMethodId > 0 THEN @PaymentMethodId ELSE PaymentMethodId END  
 END  
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
  SELECT tp.ParentId AS SValue      
   ,tp.ParentCode+' - '+tp.FatherName  AS SText      
  FROM tblParent tp        
  WHERE tp.IsActive = 1 AND tp.IsDeleted = 0         
  ORDER BY tp.ParentCode      
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

CREATE PROCEDURE [dbo].[sp_DeletePaymentMethod]   
   @PaymentMethodId bigint  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
  DELETE FROM tblPaymentMethod WHERE PaymentMethodId = @PaymentMethodId  
  --UPDATE tblBranchMaster  
  -- SET IsActive = 0  
  --  ,IsDeleted = 1  
  --  ,UpdateBy = @LoginUserId  
  --  ,UpdateDate = GETDATE()  
  --WHERE BranchId = @BranchId  
       
  COMMIT TRAN TRANS1  
  SELECT 0 AS Result, 'Saved' AS Response  
 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1  
   SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response  
   --SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END  
GO
  
CREATE PROCEDURE [dbo].[sp_GetPaymentMethodCategory]  
@PaymentMethodCategoryId bigint = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 Select PaymentMethodCategoryId, CategoryName, IsActive  
 from tblPaymentMethodCategory  
 WHERE PaymentMethodCategoryId = CASE WHEN @PaymentMethodCategoryId > 0 THEN @PaymentMethodCategoryId ELSE PaymentMethodCategoryId END  
 END  
 GO

 CREATE PROCEDURE [dbo].[sp_SavePaymentMethodCategory]  
    @PaymentMethodCategoryId bigint,  
    @CategoryName nvarchar(200),  
    @IsActive bit  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
        BEGIN TRANSACTION TRANS1;  
  
        IF EXISTS (SELECT 1 FROM tblPaymentMethodCategory WHERE PaymentMethodCategoryId <> @PaymentMethodCategoryId AND IsActive = 1)  
        BEGIN  
            IF (@PaymentMethodCategoryId > 0)  
            BEGIN  
                UPDATE tblPaymentMethodCategory  
                SET   
                    CategoryName = @CategoryName,  
                    IsActive = @IsActive,  
                    UpdateDate = GETDATE(),  
                    UpdateBy = 1  
                WHERE   
                    PaymentMethodCategoryId = @PaymentMethodCategoryId;  
            END  
        END  
  
        COMMIT TRANSACTION TRANS1;  
        SELECT 0 AS Result, 'Saved' AS Response;  
    END TRY  
    BEGIN CATCH  
        ROLLBACK TRANSACTION TRANS1;  
        SELECT -1 AS Result, 'Error!' AS Response;  
        EXEC usp_SaveErrorDetail;  
    END CATCH  
END  
GO





CREATE FUNCTION [dbo].[uf_ReportStudentStatement](
    @AcademicYearId INT = 0,
    @ParentId INT,
    @StudentId INT
)
RETURNS TABLE
AS
RETURN
(
    WITH AcademicYearCTE AS (
        SELECT TOP 1 PeriodFrom, AcademicYear
        FROM tblSchoolAcademic
        WHERE @AcademicYearId = 0 OR SchoolAcademicId = @AcademicYearId
        ORDER BY PeriodFrom ASC
    ),
    PreviousAcademicYearCTE AS (
        SELECT AcademicYear
        FROM tblSchoolAcademic
        WHERE CAST(PeriodTo AS DATE) < 
              (SELECT ISNULL(PeriodFrom, CAST('1990-01-01' AS DATE))
               FROM AcademicYearCTE)
          AND IsActive = 1
          AND IsDeleted = 0
        --ORDER BY PeriodTo DESC
    ),
    StudentTableCTE AS (
        SELECT StudentId
        FROM tblStudent
        WHERE StudentId = @StudentId
           OR (@StudentId = 0 AND ParentId = @ParentId)
    ),
    StudentOpeningFeesBalanceCTE AS (
        SELECT StudentId,
               NULL AS RecordDate,
               'TUITION FEE - OPENING BALANCE' AS FeeTypeName,
               SUM(ISNULL(FeeAmount, 0)) AS FeeAmount,
               SUM(ISNULL(PaidAmount, 0)) AS PaidAmount
        FROM tblFeeStatement
        WHERE StudentId IN (SELECT StudentId FROM StudentTableCTE)
          AND AcademicYearId IN (SELECT AcademicYearId FROM PreviousAcademicYearCTE)
          AND IsActive = 1
          AND IsDeleted = 0
        GROUP BY StudentId
    ),
    OpeningBalanceCTE AS (
        SELECT st.StudentId,
               ISNULL(s.StudentName, '') AS StudentName,
               SUM(ISNULL(ofb.FeeAmount, 0)) - SUM(ISNULL(ofb.PaidAmount, 0)) AS OpeningBalance
        FROM StudentTableCTE st
        LEFT JOIN tblStudent s ON st.StudentId = s.StudentId
        LEFT JOIN StudentOpeningFeesBalanceCTE ofb ON st.StudentId = ofb.StudentId
        GROUP BY st.StudentId, s.StudentName
    )
    SELECT StudentId,
           StudentName,
           '' AS InvoiceNo,
           '' AS PaymentMethod,
           (SELECT TOP 1 AcademicYear FROM PreviousAcademicYearCTE) AS AcademicYear,
           NULL AS RecordDate,
           'TUITION FEE - OPENING BALANCE' AS FeeTypeName,
           CASE WHEN OpeningBalance > 0 THEN OpeningBalance ELSE 0 END AS FeeAmount,
           CASE WHEN OpeningBalance < 0 THEN OpeningBalance ELSE 0 END AS PaidAmount,
           0 AS BalanceAmount
    FROM OpeningBalanceCTE
    UNION ALL
    SELECT fs.StudentId,
           s.StudentName,
           fs.InvoiceNo,
           fs.PaymentMethod,
           sa.AcademicYear,
           fs.UpdateDate AS RecordDate,
           fs.FeeStatementType AS FeeTypeName,
           fs.FeeAmount,
           fs.PaidAmount,
           0 AS BalanceAmount
    FROM tblFeeStatement fs
    INNER JOIN tblSchoolAcademic sa ON sa.SchoolAcademicId = fs.AcademicYearId
    INNER JOIN tblStudent s ON fs.StudentId = s.StudentId
    WHERE fs.StudentId IN (SELECT StudentId FROM StudentTableCTE)
      AND (@AcademicYearId = 0 OR fs.AcademicYearId = @AcademicYearId)
      AND fs.IsActive = 1
      AND fs.IsDeleted = 0
);
GO

ALTER proc [dbo].[sp_ReportStudentStatement]    
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
	UNION ALL  
	SELECT StudentId  
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
	AND (@AcademicYearId=0 OR fs.AcademicYearId IN (@AcademicYearId))
	AND fs.IsActive=1     
	AND fs.IsDeleted=0 

	DROP TABLE #Previous_tblSchoolAcademic    
	DROP TABLE #StudentTable    
	DROP TABLE #StudentOpeningFeesBalance    
END
GO


ALTER PROCEDURE [dbo].[sp_DeleteStudentOtherDiscountDetail] 
	@LoginUserId int
   ,@StudentOtherDiscountDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentOtherDiscountDetail
			SET DiscountStatus=0
				,IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId		
		
		--DECLARE @DiscountName NVARCHAR(250)
		--DECLARE @DiscountAmount DECIMAL(18,4)
		--SELECT TOP 1 @DiscountName=DiscountName,@DiscountAmount=DiscountAmount from tblStudentOtherDiscountDetail WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId 	
		----Insert discount cancled entry in statement
		--DECLARE @FeeStatementType NVARCHAR(50)=@DiscountName +' Discount Cancelled'

		--INSERT INTO [dbo].[tblFeeStatement]
		--(
		--	[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
		--	,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
		--)
		--SELECT top 1
		--	FeeStatementType=@FeeStatementType 		
		--	,FeeType=ssdd.FeeTypeId
		--	,FeeAmount=0
		--	,PaidAmount=ssdd.DiscountAmount*-1
		--	,StudentId=stu.StudentId
		--	,ParentId=stu.ParentId
		--	,StudentName=stu.StudentName
		--	,ParentName=par.ParentId
		--	,AcademicYearId=ssdd.AcademicYearId
		--	,GradeId=ssdd.GradeId
		--	,IsActive=1
		--	,IsDeleted=0
		--	,UpdateDate=GETDATE()
		--	,UpdateBy=0
		--FROM tblStudentOtherDiscountDetail ssdd  		
		--join tblStudent stu on ssdd.StudentId=stu.StudentId
		--join tblParent par on stu.ParentId=par.ParentId
		--WHERE ssdd.StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId  
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
ALTER PROCEDURE [dbo].[sp_SaveOtherDiscountDetail]
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
       
		--DECLARE @FeeStatementType NVARCHAR(50)=@DiscountName +' Discount Applied'
		IF(@StudentOtherDiscountDetailId = 0)
        BEGIN
			INSERT INTO [dbo].[tblStudentOtherDiscountDetail]
			([StudentId],[AcademicYearId],[GradeId],[FeeTypeId],[DiscountName],[DiscountAmount],[DiscountStatus],[IsActive],[IsDeleted],[UpdateDate],[UpdateBy])
			 VALUES
			(@StudentId,@AcademicYearId,@GradeId,@FeeTypeId,@DiscountName,Convert(DECIMAL(18,4),@DiscountAmount),1,1,0,GETDATE(),@LoginUserId )	
        END
        ELSE
        BEGIN
            UPDATE tblStudentOtherDiscountDetail
                SET DiscountAmount = Convert(DECIMAL(18,4),@DiscountAmount),
					DiscountName = @DiscountName,
                    UpdateDate = GETDATE(),
                    UpdateBy = @LoginUserId -- Replace '1' with a valid user ID or use @LoginUserId if available
            WHERE StudentOtherDiscountDetailId = @StudentOtherDiscountDetailId
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
ALTER PROCEDURE [dbo].[sp_DeleteStudentSiblingDiscountDetail] 
	@LoginUserId int
   ,@StudentSiblingDiscountDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentSiblingDiscountDetail
			SET DiscountStatus=0
				,IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentSiblingDiscountDetailId = @StudentSiblingDiscountDetailId	
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
ALTER PROCEDURE [dbo].[sp_SaveSiblingDiscountDetail]
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

		IF(@StudentSiblingDiscountDetailId = 0)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblStudentSiblingDiscountDetail 
					WHERE StudentId=@StudentId 
						AND AcademicYearId=@AcademicYearId AND GradeId=@GradeId AND FeeTypeId=@FeeTypeId
						AND DiscountStatus<>6
						AND IsDeleted=0 AND IsActive=1)
			BEGIN
				SELECT -2 AS Result, 'Data already exists' AS Response
				COMMIT TRAN TRANS1 
				RETURN;
			END
			INSERT INTO [dbo].[tblStudentSiblingDiscountDetail]
			([StudentId],[AcademicYearId],[GradeId],[FeeTypeId],[DiscountPercent],[DiscountStatus],[IsActive],[IsDeleted],[UpdateDate],[UpdateBy])
			VALUES
			(@StudentId,@AcademicYearId,@GradeId,@FeeTypeId,@DiscountPercent,1,1,0,GETDATE(),@LoginUserId )
		END
		ELSE
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail
			SET DiscountPercent = @DiscountPercent,
			UpdateDate = GETDATE(),
			UpdateBy = @LoginUserId
			WHERE StudentSiblingDiscountDetailId = @StudentSiblingDiscountDetailId
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
ALTER PROCEDURE [dbo].[sp_GetOtherDiscountDetail]
    @StudentId bigint
AS
BEGIN
    SELECT
	   tsdd.StudentOtherDiscountDetailId
        ,tsdd.StudentId
		,ts.StudentName
        ,tsdd.AcademicYearId
		,tsa.AcademicYear
        ,tsdd.GradeId
		,tgm.GradeName
		,tsdd.DiscountName
        ,tsdd.DiscountAmount
		,tsdd.DiscountStatus
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
ALTER PROCEDURE [dbo].[sp_GetSiblingDiscountDetail]
    @StudentId bigint
AS
BEGIN
    SELECT
		tsdd.StudentSiblingDiscountDetailId
		,tsdd.StudentId
		,ts.StudentName
		,tsdd.AcademicYearId
		,tsa.AcademicYear
		,tsdd.GradeId
		,tgm.GradeName
		,tsdd.DiscountPercent
		,tsdd.DiscountStatus
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
		AND tsdd.IsActive=1 AND tsdd.IsDeleted=0 AND tsdd.DiscountStatus<>0
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
	and ssdd.IsActive=1 and ssdd.IsDeleted=0 AND DiscountStatus in (3,7)

	select top 
		1 @ManagementDiscount=isnull(sum(DiscountAmount),0) 
	from
	tblStudentOtherDiscountDetail ssdd    
	where ssdd.StudentId=@StudentId  and ssdd.AcademicYearId=@AcademicYearId     
	and ssdd.IsActive=1 and ssdd.IsDeleted=0 AND DiscountStatus in (3,7)
 
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
  SELECT tp.ParentId AS SValue    
   ,tp.ParentCode+' - '+tp.FatherName  AS SText    
  FROM tblParent tp      
  WHERE tp.IsActive = 1 AND tp.IsDeleted = 0       
  ORDER BY tp.ParentCode    
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
			DECLARE @FeeStatementType NVARCHAR(50)='Sibling Discount Applied'		

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
				,ParentName=par.FatherName	
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
  
  select 'somendra my SP'  
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
ALTER proc [dbo].[sp_ApproveNotification]                  
 @LoginUserId int                    
 ,@NotificationIds nvarchar(max)    ='ALL'              
as                
begin                  
 BEGIN TRY                    
    
  
  select distinct isnull(country,nationality) As country into #OpenApplyCountry from [OpenApplyStudents] z                  
            
  insert into #OpenApplyCountry            
  select distinct isnull(country,nationality) from OpenApplyParents z  
  
  delete t                  
  from #OpenApplyCountry t                  
  inner join tblCountryMaster z                  
  on t.country COLLATE SQL_Latin1_General_CP1_CI_AS =z.CountryName                  
                  
  delete from #OpenApplyCountry where country is NULL                  
                    
 --select '#OpenApplyCountry' as AA, * from #OpenApplyCountry                  
                    
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
    SELECT cast(value as int)as NotificationId                  
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
                  
 --Start : Work for Father                  
                  
   select *             
   into #ParentInfo              
   from (            
    select                  
     distinct                  
     --ParentId                   
     ParentCode =cast( os.p_id_school_parent_id as nvarchar(100))                  
     ,ParentImage =cast( '' as nvarchar(100))                  
     ,FatherName =cast( '' as nvarchar(100))                  
     ,FatherArabicName =cast( '' as nvarchar(100))                  
     ,FatherNationalityId=999999                  
     ,FatherMobile =cast( '' as nvarchar(50))                  
     ,FatherEmail=cast( '' as nvarchar(100))                  
     ,IsFatherStaff =0                    
                   
     ,MotherName =cast( '' as nvarchar(100))                  
     ,MotherArabicName =cast( '' as nvarchar(100))                  
     ,MotherNationalityId =999999                  
     ,MotherMobile =cast( '' as nvarchar(50))                  
     ,MotherEmail =cast( '' as nvarchar(100))                  
     ,IsMotherStaff =0                   
     ,FatherIqamaNo =cast( '' as nvarchar(100))                  
     ,MotherIqamaNo =cast( '' as nvarchar(100))                  
     ,OpenApplyFatherId =cast( '' as nvarchar(100))                  
     ,OpenApplyMotherId =cast( '' as nvarchar(100))                  
     ,OpenApplyStudentId=os.student_id                  
                     
     ,country=cast( '' as nvarchar(100))                   
                 
    from               
     #student os                
   )t            
            
  --If more than 1 student for a oarent then delete duplicate       
    
 insert into #ApprovableNotification             
   select         
    distinct notific.NotificationId,  notific.RecordId,notific.RecordType         
   from                    
   [tblNotification] notific  
   WHERE RecordId IN   
   (  
   SELECT OpenApplyParents.id  FROM #ParentInfo  
   JOIN OpenApplyParents ON #ParentInfo.ParentCode=OpenApplyParents.parent_id  
   )  
   AND RecordType IN ('Mother','Father')  
            
  select *                   
  into #ParentFather                  
  from                  
  (                  
  select                  
   distinct                  
   --ParentId                   
   ParentCode =os.id                  
   ,            
   ParentImage =''                  
   ,FatherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))             
   ,FatherArabicName =os.[other_name]                  
                     
   ,FatherMobile =os.mobile_phone                  
   ,FatherEmail=ltrim(rtrim(os.[email]))          
   ,IsFatherStaff =0                   
                  
   ,FatherIqamaNo =os.IqamaNo                     
   ,OpenApplyFatherId =os.id                      
   ,OpenApplyStudentId=os.student_id                  
                     
   ,country=isnull(os.country,os.nationality)             
                   
  from                   
  [OpenApplyParents] os                    
  inner join  #ApprovableNotification  notific  on os.id=notific.RecordId                   
  inner join #student stu on os.student_id=stu.student_id                   
  --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
  where notific.RecordType='Father'            
  and os.id is not null                   
  )t               
              
  ---------------                  
                  
  update os                  
  set                  
   --os.ParentCode =tc.ParentCode                  
 --,            
   os.ParentImage =tc.ParentImage                  
   ,os.FatherName =tc.FatherName                  
   ,os.FatherArabicName =tc.FatherArabicName                  
   ,os.FatherMobile =tc.FatherMobile                  
   ,os.FatherEmail=tc.FatherEmail                  
   ,os.IsFatherStaff =tc.IsFatherStaff                   
                     
   ,FatherIqamaNo =tc.FatherIqamaNo                     
   ,OpenApplyFatherId =tc.OpenApplyFatherId                      
   ,OpenApplyStudentId=os.OpenApplyStudentId               
   ,country=tc.country            
                  
  from #ParentInfo os                  
  inner join #ParentFather tc on os.OpenApplyStudentId =tc.OpenApplyStudentId                  
              
  update os                  
  set                  
   os.FatherNationalityId=tc.CountryId                  
  from #ParentInfo os                  
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                
              
  ---Update Father record if father record is not available                  
                   
  select *                   
  into #ParentFatherOther                  
  from                   
  (                  
   select                   
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,                  
   * from                   
   (                  
    select                    
     ParentCode =os.id                  
     ,ParentImage =''                  
     ,FatherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))                 
     ,FatherArabicName =os.[other_name]                  
     ,FatherMobile =os.mobile_phone                  
     ,FatherEmail=ltrim(rtrim(os.[email]))                  
     ,IsFatherStaff =0                    
                      
     ,FatherIqamaNo =os.IqamaNo                     
     ,OpenApplyFatherId =os.id                      
     ,OpenApplyStudentId=os.student_id                  
                     
     ,country=isnull(os.country,os.nationality)            
    from                   
    [OpenApplyParents] os                    
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId                   
   inner join #student stu on os.student_id=stu.student_id                   
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
    where notific.RecordType in                   
    (                  
     'Brother', 'Consultant/recruiter','Grandfather','Legal guardian','Other guardian','Stepfather','Uncle'                  
    )                      
   )t                  
  )z                  
  where z.RN=1 -- get only 1 record                   
                  
  update os                  
  set                  
   --os.ParentCode =tc.ParentCode                  
   --,            
   os.ParentImage =tc.ParentImage                  
   ,os.FatherName =tc.FatherName          
   ,os.FatherArabicName =tc.FatherArabicName                  
   ,os.FatherMobile =tc.FatherMobile                  
   ,os.FatherEmail=tc.FatherEmail                  
   ,os.IsFatherStaff =tc.IsFatherStaff                   
                     
   ,FatherIqamaNo =tc.FatherIqamaNo                     
   ,OpenApplyFatherId =tc.OpenApplyFatherId                      
   ,OpenApplyStudentId=os.OpenApplyStudentId                  
 ,country=tc.country            
            
  from #ParentInfo os                  
  inner join #ParentFatherOther tc on os.OpenApplyStudentId =tc.OpenApplyStudentId                  
  where os.OpenApplyFatherId is null                  
                  
  update os                  
  set                  
   os.FatherNationalityId=tc.CountryId                  
  from #ParentInfo os                  
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
                  
               
  --------------Get mother information                  
                  
  select *                   
   into #ParentMother                  
  from                   
  (            
   select                   
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,                  
   * from                   
   (                  
    select                    
     ParentCode =os.id                  
     ,ParentImage =''                      
                  
     ,MotherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))                  
     ,MotherArabicName =os.[other_name]                       
     ,MotherMobile =os.mobile_phone                  
     ,MotherEmail =ltrim(rtrim(os.[email]))            
     ,IsMotherStaff =0                   
     ,MotherIqamaNo =os.IqamaNo                     
     ,OpenApplyMotherId =os.id                  
     ,OpenApplyStudentId=os.student_id                  
     ,country=isnull(os.country,os.nationality)            
                  
    from                   
    [OpenApplyParents] os                    
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId                  
    inner join #student stu on os.student_id=stu.student_id                   
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
    where notific.RecordType in                   
    (                  
     'Mother'                  
    )                  
   )t                  
  )z                  
  where z.RN=1 -- get only 1 record                   
                 
  update os                  
  set                  
   --os.ParentCode =tc.ParentCode                  
   --,            
   os.ParentImage =tc.ParentImage                  
                  
   ,os.MotherName =tc.MotherName                  
   ,os.MotherArabicName =tc.MotherArabicName          
   ,os.MotherMobile =tc.MotherMobile                  
   ,os.MotherEmail=tc.MotherEmail                  
   ,os.IsMotherStaff =tc.IsMotherStaff                   
                     
   ,MotherIqamaNo =tc.MotherIqamaNo                     
   ,OpenApplyMotherId =tc.OpenApplyMotherId                      
   ,OpenApplyStudentId=os.OpenApplyStudentId             
   ,country=tc.country            
                  
  from #ParentInfo os                  
  inner join #ParentMother tc on os.OpenApplyStudentId =tc.OpenApplyStudentId                  
                    
  update os                  
  set                  
   os.MotherNationalityId=tc.CountryId                  
  from #ParentInfo os                  
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
                  
  --------------Get mother reference information other than mother                  
                  
  select *                   
   into #ParentMotherOther                  
  from                   
  (                  
   select                   
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,                  
   * from                   
   (                  
    select                    
     ParentCode =os.id                  
     ,ParentImage =''                      
                  
     ,MotherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))                  
     ,MotherArabicName =os.[other_name]                  
                      
     ,MotherMobile =os.mobile_phone                  
     ,MotherEmail =ltrim(rtrim(os.[email]))                    
     ,IsMotherStaff =0                   
     ,MotherIqamaNo =os.IqamaNo                     
     ,OpenApplyMotherId =os.id                  
     ,OpenApplyStudentId=os.student_id                  
     ,country=isnull(os.country,os.nationality)            
    from                   
    [OpenApplyParents] os                    
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId                   
    inner join #student stu on os.student_id=stu.student_id                
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
    where notific.RecordType in                   
    (                  
     'Aunt','Consultant/recruiter','Grandmother','Legal guardian','Other guardian','Sister','Stepmother'                  
    )                  
    and os.id is not null                   
   )t                  
  )z                  
  where z.RN=1 -- get only 1 record               
              
  update os                  
  set                  
   --os.ParentCode =tc.ParentCode                  
   --,            
   os.ParentImage =tc.ParentImage                  
                  
   ,os.MotherName =tc.MotherName                  
   ,os.MotherArabicName =tc.MotherArabicName                  
   ,os.MotherMobile =tc.MotherMobile                  
   ,os.MotherEmail=tc.MotherEmail            
   ,os.IsMotherStaff =tc.IsMotherStaff                   
                     
   ,MotherIqamaNo =tc.MotherIqamaNo                     
   ,OpenApplyMotherId =tc.OpenApplyMotherId                      
   ,OpenApplyStudentId=os.OpenApplyStudentId             
   ,country=tc.country            
                  
  from #ParentInfo os                  
  inner join #ParentMotherOther tc on os.OpenApplyStudentId =tc.OpenApplyStudentId                  
  where os.OpenApplyMotherId is null                  
                    
  update os                  
  set                  
   os.MotherNationalityId=tc.CountryId                  
  from #ParentInfo os                  
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName                  
                  
  -----------------------                  
             
  delete from #ParentInfo where ltrim(rtrim( ParentCode))=''      
              
  delete from #ParentInfo where ltrim(rtrim( ParentCode))<>''             
 and   ltrim(rtrim( FatherName))=''            
 and   ltrim(rtrim( MotherName))=''            
              
  --select '#ParentInfo' as AA, * from #ParentInfo            
            
 select *             
 into #ParentInfo2            
 from   
 (            
  select * from             
  (            
  select ROW_NUMBER() over(partition by ParentCode order by ParentCode)as RN2, * from   #ParentInfo            
            
  )t            
  where RN2=1            
 )z            
           
  MERGE tblParent AS TARGET                  
  USING #ParentInfo2 AS SOURCE                   
  ON                   
  (                  
 cast( TARGET.ParentCode as nvarchar(100)) COLLATE SQL_Latin1_General_CP1_CI_AS= cast(SOURCE.ParentCode as nvarchar(100))                  
  --and TARGET.OpenApplyStudentId=   cast( SOURCE.OpenApplyStudentId as bigint)                  
  )                   
                   
  --When records are matched, update the records if there is any change                  
  WHEN MATCHED --AND TARGET.ProductName <> SOURCE.ProductName OR TARGET.Rate <> SOURCE.Rate                   
  THEN UPDATE                   
  SET                   
                   
  --TARGET.ParentCode=      SOURCE.ParentCode ,                  
  TARGET.ParentImage=      SOURCE.ParentImage                  
  ,TARGET.FatherName=      SOURCE.FatherName                  
  ,TARGET.FatherArabicName=    SOURCE.FatherArabicName                  
  ,TARGET.FatherNationalityId=    SOURCE.FatherNationalityId                  
  ,TARGET.FatherMobile=     SOURCE.FatherMobile                
  ,TARGET.FatherEmail=      SOURCE.FatherEmail                  
  ,TARGET.IsFatherStaff=     SOURCE.IsFatherStaff                  
                           
  ,TARGET.MotherName=      SOURCE.MotherName                  
  ,TARGET.MotherArabicName=    SOURCE.MotherArabicName                  
  ,TARGET.MotherNationalityId=    SOURCE.MotherNationalityId                  
  ,TARGET.MotherMobile=     SOURCE.MotherMobile                  
  ,TARGET.MotherEmail=      SOURCE.MotherEmail                  
  ,TARGET.IsMotherStaff=     SOURCE.IsMotherStaff                  
  ,TARGET.FatherIqamaNo=     SOURCE.FatherIqamaNo                  
  ,TARGET.MotherIqamaNo=     SOURCE.MotherIqamaNo                  
                   
  ,TARGET.OpenApplyFatherId=  cast(SOURCE.OpenApplyFatherId as bigint)                  
  ,TARGET.OpenApplyMotherId=   cast( SOURCE.OpenApplyMotherId as bigint)                  
  ,TARGET.OpenApplyStudentId=   cast( SOURCE.OpenApplyStudentId as bigint)                  
                  
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
   ,SOURCE.ParentImage,SOURCE.FatherName,SOURCE.FatherArabicName,SOURCE.FatherNationalityId,SOURCE.FatherMobile,SOURCE.FatherEmail,SOURCE.IsFatherStaff                  
   ,SOURCE.MotherName,SOURCE.MotherArabicName,SOURCE.MotherNationalityId,SOURCE.MotherMobile,SOURCE.MotherEmail,SOURCE.IsMotherStaff                  
   ,SOURCE.FatherIqamaNo,SOURCE.MotherIqamaNo,SOURCE.OpenApplyFatherId,SOURCE.OpenApplyMotherId,SOURCE.OpenApplyStudentId                  
   ,1,0, getdate(),@LoginUserId                  
  );                  
       
  
   -----Start: Student update                  
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
                  
 update notific                  
 set   
  IsApproved=1                  
 from                    
 [tblNotification] notific                 
 inner join #ApprovableNotification app                  
 on notific.NotificationId=app.NotificationId           
            
  delete notific           
  from [tblNotification] notific                  
  inner join #ApprovableNotification app                  
  on notific.NotificationId=app.NotificationId               
                  
  select notific.NotificationGroupId, count(1) as NotificationGroupCount  into #notificationGroupDetail          
  from tblNotificationGroupDetail notific                  
  inner join #ApprovableNotification app                  
  on notific.TableRecordId=app.NotificationId            
  group by notific.NotificationGroupId          
          
  update t           
  set          
   t.NotificationCount=t.NotificationCount-isnull(t2.NotificationGroupCount,0)          
  from tblNotificationGroup t          
  inner join #notificationGroupDetail t2 on t.NotificationGroupId=t2.NotificationGroupId          
          
  delete notific           
  from tblNotificationGroupDetail notific                  
  inner join #ApprovableNotification app                  
  on notific.TableRecordId=app.NotificationId            
                   
  
            
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
              
              
   ROLLBACK TRAN TRANS2                    
   SELECT -1 AS Result, 'Error!' AS Response                    
   EXEC usp_SaveErrorDetail                    
   RETURN                    
 END CATCH                    
END
GO
ALTER PROC [dbo].[sp_GetNotificationGroup]
	@LoginUserId int=0
AS
BEGIN
	SELECT 
		ng.NotificationGroupId
		,ng.NotificationTypeId
		,ng.NotificationCount
		,ng.NotificationAction
		,nt.NotificationType
		,nt.ActionTable
		,nt.NotificationActionTable
		,REPLACE(REPLACE(nt.NotificationMsg,'#N',ng.NotificationCount),'#Action',CASE WHEN NotificationAction=1 THEN 'Added' WHEN NotificationAction=2 THEN 'Updated' WHEN NotificationAction=3 THEN 'Deleted'  WHEN NotificationAction=4 THEN 'Rejected'  WHEN NotificationAction=5 THEN 'Cancelled' ELSE '' END) AS NotificationMsg
	from tblNotificationGroup ng
	INNER JOIN tblNotificationTypeMaster nt
		ON nt.NotificationTypeId=ng.NotificationTypeId
END
GO
CREATE PROCEDURE [dbo].[sp_GetNotificationSiblingDiscount]
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT
	   tsdd.StudentSiblingDiscountDetailId
        ,tsdd.StudentId
		,ts.StudentName
        ,tsdd.AcademicYearId
		,tsa.AcademicYear
        ,tsdd.GradeId
		,tgm.GradeName
        ,tsdd.DiscountPercent
		,tsdd.DiscountStatus
    FROM 
        tblStudentSiblingDiscountDetail AS tsdd
    JOIN 
        tblGradeMaster AS tgm ON tsdd.GradeId = tgm.GradeId
    JOIN 
        tblSchoolAcademic AS tsa ON tsdd.AcademicYearId = tsa.SchoolAcademicId
    JOIN 
        tblStudent AS ts ON tsdd.StudentId = ts.StudentId
    WHERE tsdd.IsActive=1 
		AND tsdd.IsDeleted=0
		AND tsdd.DiscountStatus IN (2,5)
END
GO
CREATE PROCEDURE [dbo].[sp_UpdateSiblingDiscountStatus]
	@LoginUserId int
	,@StudentSiblingDiscountDetailId bigint	
	,@ActionId int
AS
BEGIN
	--1- Added
	--2- Pending for Approval
	--3- Approved (Discount Applied)
	--4- Rejected
	--5- Discount Cancel (Pending for Approval)
	--6- Discount Cancelled
	--7- Discount Cancel: Rejected	

	SET NOCOUNT ON;	
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF (@ActionId=3)
		BEGIN
			SELECT  @ActionId= CASE WHEN DiscountStatus=2 THEN 3  WHEN  DiscountStatus=5 THEN 6 END
			FROM tblStudentSiblingDiscountDetail
			WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 
		END
		IF (@ActionId=4)
		BEGIN
			SELECT  @ActionId= CASE WHEN DiscountStatus=2 THEN 4  WHEN  DiscountStatus=5 THEN 7 END
			FROM tblStudentSiblingDiscountDetail
			WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 
		END

		IF(@ActionId=2)
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=2 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
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
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=3 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId  
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

			--Insert discount Applied entry in statement	
			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType='Sibling Discount Applied' 		
				,FeeType=sodd.FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(decimal(18,4),(sfd.FeeAmount*sodd.DiscountPercent)/100)
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.FatherName				
				,AcademicYearId=sodd.AcademicYearId
				,GradeId=sodd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentSiblingDiscountDetail sodd
			INNER JOIN tblStudentFeeDetail sfd
				ON sodd.StudentId=sodd.StudentId
			INNER JOIN tblStudent stu
				ON sodd.StudentId=stu.StudentId
			INNER JOIN tblParent par 
				ON stu.ParentId=par.ParentId
			WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId
			
		END
		ELSE IF(@ActionId=4)
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=4 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 
			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		IF(@ActionId=5)
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=5 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,5)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END

		ELSE IF(@ActionId=6)
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=6 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

			--Insert discount Applied entry in statement	
			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType='Sibling Discount Cancelled' 		
				,FeeType=sodd.FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(decimal(18,4),(sfd.FeeAmount*sodd.DiscountPercent)/100)*-1
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.FatherName					
				,AcademicYearId=sodd.AcademicYearId
				,GradeId=sodd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentSiblingDiscountDetail sodd
			INNER JOIN tblStudentFeeDetail sfd
				ON sodd.StudentId=sodd.StudentId
			INNER JOIN tblStudent stu
				ON sodd.StudentId=stu.StudentId
			INNER JOIN tblParent par 
				ON stu.ParentId=par.ParentId
			WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId

		END
		ELSE IF(@ActionId=7)
		BEGIN
			UPDATE tblStudentSiblingDiscountDetail SET DiscountStatus=7 WHERE StudentSiblingDiscountDetailId=@StudentSiblingDiscountDetailId 
			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentSiblingDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
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
CREATE PROCEDURE [dbo].[sp_GetNotificationOtherDiscount]
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT
	   tsdd.StudentOtherDiscountDetailId
        ,tsdd.StudentId
		,ts.StudentName
        ,tsdd.AcademicYearId
		,tsa.AcademicYear
        ,tsdd.GradeId
		,tgm.GradeName
		,tsdd.DiscountName
        ,tsdd.DiscountAmount
		,tsdd.DiscountStatus
    FROM 
        tblStudentOtherDiscountDetail AS tsdd
    JOIN 
        tblGradeMaster AS tgm ON tsdd.GradeId = tgm.GradeId
    JOIN 
        tblSchoolAcademic AS tsa ON tsdd.AcademicYearId = tsa.SchoolAcademicId
    JOIN 
        tblStudent AS ts ON tsdd.StudentId = ts.StudentId
    WHERE tsdd.IsActive=1 
		AND tsdd.IsDeleted=0
		AND tsdd.DiscountStatus IN (2,5)
END
GO
CREATE PROCEDURE [dbo].[sp_UpdateOtherDiscountStatus]
	@LoginUserId int
	,@StudentOtherDiscountDetailId bigint	
	,@ActionId int
AS
BEGIN
	--1- Added
	--2- Pending for Approval
	--3- Approved (Discount Applied)
	--4- Rejected
	--5- Discount Cancel (Pending for Approval)
	--6- Discount Canceled
	--7- Discount Cancel: Rejected

	
	SET NOCOUNT ON;	
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF (@ActionId=3)
		BEGIN
			SELECT  @ActionId= CASE WHEN DiscountStatus=2 THEN 3  WHEN  DiscountStatus=5 THEN 6 END
			FROM tblStudentOtherDiscountDetail
			WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 
		END
		IF (@ActionId=4)
		BEGIN
			SELECT  @ActionId= CASE WHEN DiscountStatus=2 THEN 4  WHEN  DiscountStatus=5 THEN 7 END
			FROM tblStudentOtherDiscountDetail
			WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 
		END

		IF(@ActionId=2)
		BEGIN
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=2 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
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
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=3 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId  
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

			--Insert discount Applied entry in statement	
			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType=sodd.DiscountName +' Discount Applied' 		
				,FeeType=sodd.FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(DECIMAL(18,2),sodd.DiscountAmount)
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.FatherName					
				,AcademicYearId=sodd.AcademicYearId
				,GradeId=sodd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentOtherDiscountDetail sodd
			INNER JOIN tblStudent stu
				ON sodd.StudentId=stu.StudentId
			INNER JOIN tblParent par 
				ON stu.ParentId=par.ParentId
			WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId
			
		END
		ELSE IF(@ActionId=4)
		BEGIN
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=4 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 
			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		IF(@ActionId=5)
		BEGIN
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=5 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,5)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END

		ELSE IF(@ActionId=6)
		BEGIN
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=6 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

			--Insert discount Applied entry in statement	
			INSERT INTO [dbo].[tblFeeStatement]
			(
				[FeeStatementType],[FeeType],[FeeAmount],[PaidAmount],[StudentId],[ParentId],[StudentName],[ParentName],[AcademicYearId],[GradeId]
				,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy]
			)
			SELECT top 1
				FeeStatementType=sodd.DiscountName +' Discount Cancelled' 		
				,FeeType=sodd.FeeTypeId
				,FeeAmount=0
				,PaidAmount=Convert(DECIMAL(18,2),sodd.DiscountAmount)*-1
				,StudentId=stu.StudentId
				,ParentId=stu.ParentId
				,StudentName=stu.StudentName
				,ParentName=par.FatherName				
				,AcademicYearId=sodd.AcademicYearId
				,GradeId=sodd.GradeId
				,IsActive=1
				,IsDeleted=0
				,UpdateDate=GETDATE()
				,UpdateBy=0
			FROM tblStudentOtherDiscountDetail sodd
			INNER JOIN tblStudent stu
				ON sodd.StudentId=stu.StudentId
			INNER JOIN tblParent par 
				ON stu.ParentId=par.ParentId
			WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId

		END
		ELSE IF(@ActionId=7)
		BEGIN
			UPDATE tblStudentOtherDiscountDetail SET DiscountStatus=7 WHERE StudentOtherDiscountDetailId=@StudentOtherDiscountDetailId 
			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblStudentOtherDiscountDetail'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=5
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
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
CREATE PROCEDURE [dbo].[sp_SavePaymentMethodCategory]
    @PaymentMethodCategoryId bigint,
    @CategoryName nvarchar(200),
    @IsActive bit
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION TRANS1;

        IF EXISTS (SELECT 1 FROM tblPaymentMethodCategory WHERE PaymentMethodCategoryId <> @PaymentMethodCategoryId AND IsActive = 1)
        BEGIN
            IF (@PaymentMethodCategoryId > 0)
            BEGIN
                UPDATE tblPaymentMethodCategory
                SET 
                    CategoryName = @CategoryName,
                    IsActive = @IsActive,
                    UpdateDate = GETDATE(),
                    UpdateBy = 1
                WHERE 
                    PaymentMethodCategoryId = @PaymentMethodCategoryId;
            END
        END

        COMMIT TRANSACTION TRANS1;
        SELECT 0 AS Result, 'Saved' AS Response;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION TRANS1;
        SELECT -1 AS Result, 'Error!' AS Response;
        EXEC usp_SaveErrorDetail;
    END CATCH
END
GO
CREATE PROCEDURE [dbo].[sp_SavePaymentMethod]
	@PaymentMethodId bigint
	,@PaymentMethodCategoryId bigint
	,@PaymentMethodName nvarchar(200)
	,@DebitAccount nvarchar(200)
	,@CreditAccount nvarchar(200)
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblPaymentMethod WHERE PaymentMethodName = @PaymentMethodName
			AND PaymentMethodId <> @PaymentMethodId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Payment Method already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@PaymentMethodId = 0)
			BEGIN
				INSERT INTO tblPaymentMethod
					   (PaymentMethodCategoryId
					   ,PaymentMethodName
					   ,DebitAccount
					   ,CreditAccount
						,IsActive
						,IsDeleted
						,UpdateDate
						,UpdateBy)
				VALUES
					   (@PaymentMethodCategoryId
					   ,@PaymentMethodName
					   ,@DebitAccount
					   ,@CreditAccount
					   ,1
					   ,0
					   ,GETDATE()
					   ,1)
					   
			END
			ELSE
			BEGIN
				UPDATE tblPaymentMethod
						SET PaymentMethodCategoryId = @PaymentMethodCategoryId
						, PaymentMethodName = @PaymentMethodName
						,DebitAccount = @DebitAccount
						,CreditAccount = @CreditAccount
							,IsActive = 1		
							,UpdateDate = GETDATE()
							,UpdateBy = 1
				WHERE PaymentMethodId = @PaymentMethodId
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
CREATE PROCEDURE [dbo].[sp_GetPaymentMethodCategory]
@PaymentMethodCategoryId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	Select PaymentMethodCategoryId, CategoryName, IsActive
	from tblPaymentMethodCategory
	WHERE PaymentMethodCategoryId = CASE WHEN @PaymentMethodCategoryId > 0 THEN @PaymentMethodCategoryId ELSE PaymentMethodCategoryId END
	END
GO
--exec sp_GetSiblingDiscountDetailForCancle 2008
CREATE PROCEDURE [dbo].[sp_GetSiblingDiscountDetailForCancle]
    @AcademicYearId int
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
		tsdd.DiscountPercent,
		tsdd.DiscountStatus
		--,SUM(fuc.FeeAmount) AS TotalFeeAmount
		--,SUM(fuc.PaidAmount) AS TotalPaidAmount
	FROM 
		tblStudentSiblingDiscountDetail AS tsdd
	JOIN 
		tblGradeMaster AS tgm ON tsdd.GradeId = tgm.GradeId
	JOIN 
		tblSchoolAcademic AS tsa ON tsdd.AcademicYearId = tsa.SchoolAcademicId
	JOIN 
		tblStudent AS ts ON tsdd.StudentId = ts.StudentId
	CROSS APPLY 
		uf_ReportStudentStatement(@AcademicYearId, 0, tsdd.StudentId) AS fuc
	WHERE 
		tsdd.AcademicYearId = @AcademicYearId
		AND tsdd.IsActive = 1
		AND tsdd.IsDeleted = 0
		--AND tsdd.DiscountStatus <> 0
		AND tsdd.DiscountStatus IN (3, 5, 7)
	GROUP BY 
		tsdd.StudentSiblingDiscountDetailId,
		tsdd.StudentId,
		ts.StudentName,
		tsdd.AcademicYearId,
		tsa.AcademicYear,
		tsdd.GradeId,
		tgm.GradeName,
		tsdd.DiscountPercent,
		tsdd.DiscountStatus
	HAVING 
		SUM(ISNULL(fuc.FeeAmount,0)) > SUM(ISNULL(fuc.PaidAmount,0))
END
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentMethod] 
   @PaymentMethodId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblPaymentMethod WHERE PaymentMethodId = @PaymentMethodId
		--UPDATE tblBranchMaster
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE BranchId = @BranchId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_GetPaymentMethod]
@PaymentMethodId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	Select PaymentMethodId, tpm.PaymentMethodCategoryId ,tpmc.CategoryName, PaymentMethodName, DebitAccount, CreditAccount, tpm.IsActive
	from tblPaymentMethod as tpm
	Join tblPaymentMethodCategory as tpmc on tpm.PaymentMethodCategoryId = tpmc.PaymentMethodCategoryId 
	WHERE PaymentMethodId = CASE WHEN @PaymentMethodId > 0 THEN @PaymentMethodId ELSE PaymentMethodId END
	END
GO

CREATE FUNCTION [dbo].[GetDateTimeFromTimeStamp]  
(  
 @UnixTimestamp BIGINT  
)  
RETURNS  DateTime  
AS  
BEGIN  
 IF LEN(@UnixTimestamp)>10  
 BEGIN  
  RETURN(SELECT DATEADD(SECOND, @UnixTimestamp/1000, '19700101'))  
 END   
 RETURN(SELECT DATEADD(SECOND, @UnixTimestamp, '19700101'))  
END  
Go