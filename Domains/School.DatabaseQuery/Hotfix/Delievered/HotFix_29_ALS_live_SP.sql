    
DROP PROCEDURE IF EXISTS [sp_ProcessOpenApplyRecordToTable]
GO

CREATE PROCEDURE  [dbo].[sp_ProcessOpenApplyRecordToTable]                              
as                              
begin       
      
 truncate table [tblParentOpenApplyProcessed]      
 truncate table [tblStudentOpenApplyProcessed]      
      
 select                              
  distinct                              
  os.*  
 into #student      
 from                               
 [dbo].[vw_GetStudentOpenApplyStudentInfo] os      
   
      
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
        
  declare @SchoolId int=0      
  select top 1 @SchoolId=SchoolId from tblSchoolMaster where IsActive=1 and IsDeleted=0      
      
   update os                
  set os.SchoolId=@SchoolId      
  from #student os       
    
      
  select      
 StudentId=0 ,StudentCode ,StudentImage='' ,ParentId=0 ,StudentName ,StudentArabicName ,StudentEmail ,DOB       
 ,IqamaNo ,NationalityId       
 ,GenderId ,AdmissionDate ,GradeId ,CostCenterId ,SectionId ,PassportNo ,PassportExpiry ,Mobile ,StudentAddress ,StudentStatusId       
 ,WithdrawDate ,WithdrawAt=null ,WithdrawYear ,Fees=null ,IsGPIntegration=0 ,TermId=1 ,AdmissionYear ,PrinceAccount       
 ,IsActive=1 ,IsDeleted=0 ,UpdateDate=getdate() ,UpdateBy=1 ,ParentCode      
  into #studentOpenApply      
  from #student      
        
 declare @StudentActiveStatusId int=2  --update- type notification on grid      
 declare @StudentWithdrawStatusId int=3 --delete- type notification on grid      
 declare @StudentNewStatusId int=1 --add- type notification on grid      
       
 select TOP 1 @StudentActiveStatusId =StudentStatusId  from tblStudentStatus where StatusName='Active'           
 select TOP 1 @StudentWithdrawStatusId =StudentStatusId  from tblStudentStatus where StatusName='Withdraw'           
       
 --Find all student as Withdrawable student      
 INSERT INTO [tblStudentOpenApplyProcessed]      
 (      
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id      
 )      
 select       
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId=@StudentWithdrawStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id     
 from tblStudent where StudentCode not in (select StudentCode from #studentOpenApply) and StudentStatusId=1      
      
  --Find all student as Ative student student      
 INSERT INTO [tblStudentOpenApplyProcessed]      
 (      
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id      
 )      
 select       
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId=@StudentActiveStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id      
 from tblStudent where StudentCode in (select StudentCode from #studentOpenApply)      
      
 --Find all student which are new      
 INSERT INTO [tblStudentOpenApplyProcessed]      
 (      
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id      
 )      
 select       
  StudentId,StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
  ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry,Mobile      
  ,StudentAddress,      
  StudentStatusId=@StudentNewStatusId,      
  WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration,TermId      
  ,AdmissionYear,PrinceAccount      
  ,IsActive=1 ,IsDeleted=0 ,UpdateDate=getdate() ,UpdateBy=1       
  ,ParentCode      
 from  #studentOpenApply where StudentCode not in (select StudentCode from tblStudent )      
      
  ---Final Parent to process      
  select       
   distinct      
   ParentCode ,ParentImage ,FatherName ,FatherArabicName ,FatherNationalityId ,FatherMobile ,FatherEmail ,IsFatherStaff ,FatherIqamaNo       
    ,OpenApplyFatherId ,MotherName ,MotherArabicName ,MotherNationalityId ,MotherMobile ,MotherEmail ,IsMotherStaff ,MotherIqamaNo       
    ,OpenApplyMotherId      
  INTO #FinalParenToProcess      
  from [dbo].[vw_GetStudentOpenApplyParentInfo]      
  where ParentCode in       
  (      
  select p_id_school_parent_id from tblStudent      
  union       
  select ParentCode from #studentOpenApply      
  )      
        
   ---get Active parent      
  INSERT INTO tblParentOpenApplyProcessed      
  (ParentId,ParentCode ,ParentImage ,FatherName ,FatherArabicName ,FatherNationalityId ,FatherMobile ,FatherEmail ,IsFatherStaff ,FatherIqamaNo       
   ,OpenApplyFatherId ,MotherName ,MotherArabicName ,MotherNationalityId ,MotherMobile ,MotherEmail ,IsMotherStaff ,MotherIqamaNo       
   ,OpenApplyMotherId ,IsActive,IsDeleted,UpdateDate,UpdateBy)      
  select distinct      
 t2.ParentId,  t1.ParentCode ,t1.ParentImage ,t1.FatherName ,t1.FatherArabicName ,t1.FatherNationalityId ,t1.FatherMobile ,t1.FatherEmail       
 ,t1.IsFatherStaff ,t1.FatherIqamaNo,t1.OpenApplyFatherId ,t1.MotherName ,t1.MotherArabicName ,t1.MotherNationalityId ,t1.MotherMobile ,      
 t1.MotherEmail ,t1.IsMotherStaff ,t1.MotherIqamaNo ,t1.OpenApplyMotherId      
 ,IsActive=1 ,IsDeleted=0 ,UpdateDate=getdate() ,UpdateBy=1       
  from  #FinalParenToProcess t1      
  join tblParent t2 on t1.ParentCode=t2.ParentCode      
      
   ---get new parent      
   INSERT INTO tblParentOpenApplyProcessed      
  (ParentId,ParentCode ,ParentImage ,FatherName ,FatherArabicName ,FatherNationalityId ,FatherMobile ,FatherEmail ,IsFatherStaff ,FatherIqamaNo       
   ,OpenApplyFatherId ,MotherName ,MotherArabicName ,MotherNationalityId ,MotherMobile ,MotherEmail ,IsMotherStaff ,MotherIqamaNo       
   ,OpenApplyMotherId,IsActive,IsDeleted,UpdateDate,UpdateBy)      
  select distinct      
 ParentId=0,  ParentCode ,ParentImage ,FatherName ,FatherArabicName ,FatherNationalityId ,FatherMobile ,FatherEmail ,IsFatherStaff ,FatherIqamaNo       
   ,OpenApplyFatherId ,MotherName ,MotherArabicName ,MotherNationalityId ,MotherMobile ,MotherEmail ,IsMotherStaff ,MotherIqamaNo       
   ,OpenApplyMotherId      
   ,IsActive=1 ,IsDeleted=0 ,UpdateDate=getdate() ,UpdateBy=1       
  from  #FinalParenToProcess t1      
  where ParentCode not in (select ParentCode from tblParentOpenApplyProcessed)      
      
      
  -------------Notification deault data process      
 IF NOT EXISTS(SELECT TOP 1 * FROM tblNotificationTypeMaster where NotificationType='Student' and  ActionTable='tblStudent')                        
 BEGIN                         
  INSERT INTO tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive,NotificationActionTable)                        
  SELECT  'Student', 'tblStudent', 'Student #N record #Action' ,1  ,'NotificationOpenApplyStudent'                      
 END            
             
 IF NOT EXISTS(SELECT TOP 1 * FROM tblNotificationTypeMaster where NotificationType='Parent' and  ActionTable='tblParent')                        
 BEGIN                         
  INSERT INTO tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive,NotificationActionTable)                        
  SELECT  'Parent', 'tblParent', 'Parent #N record #Action' ,1   ,'NotificationOpenApplyParent'                     
 END          
      
      
  DECLARE @NotificationTypeIdStudent int=0;                       
             
  select top 1 @NotificationTypeIdStudent=NotificationTypeId from tblNotificationTypeMaster where NotificationType='Student' and  ActionTable='tblStudent'          
      
  --TODO: Add count record for student            
  declare @NotificationGroupIdAdd int =1       --Add      
  declare @NotificationGroupIdUpdate int =2       --Update      
  declare @NotificationGroupIdWithdraw int =3       --Withdraw      
        
  if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdAdd)            
  begin            
   insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)                        
   select             
   @NotificationTypeIdStudent as NotificationTypeId,0 as NotificationCount, NotificationAction=@NotificationGroupIdAdd            
  end       
        
  if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdUpdate)            
  begin            
   insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)                        
   select             
   @NotificationTypeIdStudent as NotificationTypeId,0 as NotificationCount, NotificationAction=@NotificationGroupIdUpdate            
  end       
        
  if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdWithdraw)            
  begin            
   insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)                        
   select             
   @NotificationTypeIdStudent as NotificationTypeId,0 as NotificationCount, NotificationAction=@NotificationGroupIdWithdraw            
  end         
        
  ----   add group detail for parent            
  DECLARE @NotificationTypeIdParent int=0;       
       
  select top 1       
   @NotificationTypeIdParent=NotificationTypeId             
  from tblNotificationTypeMaster             
  where NotificationType='Parent' and  ActionTable='tblParent'                        
                        
  --Add count record for parent            
  set @NotificationGroupIdAdd =1            
  if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdAdd)            
  begin            
   insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)                        
   select             
   @NotificationTypeIdParent as NotificationTypeId,0 as NotificationCount, NotificationAction=@NotificationGroupIdAdd            
  end            
      
  ---Update count record for parent            
  set @NotificationGroupIdUpdate =2            
  if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdUpdate)            
  begin            
   insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)                        
   select             
   @NotificationTypeIdParent as NotificationTypeId,0 as NotificationCount, NotificationAction=@NotificationGroupIdUpdate            
  end            
            
      
      
  drop table #student      
  drop table #studentOpenApply      
  drop table #FinalParenToProcess      
      
END 
GO

DROP PROCEDURE IF EXISTS [sp_ProcessOpenApplyRecordToNotification]
GO

CREATE PROCEDURE  [dbo].[sp_ProcessOpenApplyRecordToNotification]                              
as                              
begin                              
 --1- added                              
 --2- updated       
 --3- delete/withdraw      
             
 ----DELETE previous record                        
 DELETE FROM [tblNotification]                     
 WHERE RecordType='Student'                    
 OR RecordType='parent'                    
 OR RecordType='Mother'                    
 OR RecordType='Father'                    
                        
 DELETE t                        
 FROM tblNotificationGroupDetail t                        
 where NotificationTypeId in             
 (            
  select NotificationTypeId from tblNotificationTypeMaster            
  WHERE ActionTable IN ('tblStudent','tblParent')                        
 )              
                        
 update t                        
 set t.NotificationCount=0            
 FROM tblNotificationGroup t            
 where NotificationTypeId in             
 (            
  select NotificationTypeId from tblNotificationTypeMaster            
  WHERE ActionTable IN ('tblStudent','tblParent')                        
 )    
     
 truncate table [tblStudentOpenApplyProcessed]    
 truncate table [tblParentOpenApplyProcessed]     
    
 BEGIN TRY      
  BEGIN TRANSACTION TRANS1        
        
 --Process master record first      
 exec [sp_ProcessOpenApplyRecordToTable]      
 --NotificationAction 1- Add, 2-Edit, 3-DELETEd      
      
 -----Start: Student Process      
 --RecordStatus 0=add, 1=Update, 2=Withdraw    
    
 INSERT INTO [tblNotification]                    
 (      
  RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson      
 )                              
 select                               
  ProcessId as RecordId    
  ,StudentStatusId RecordStatus    
  ,0 as IsApproved    
  ,'Student' as RecordType    
  ,Getdate()    
  ,0    
  ,[StudentCode]                        
  ,OldValueJson=ISNULL(OldValueJson,'')                        
  ,NewValueJson=ISNULL(NewValueJson,'')                        
 from                               
 (                              
  select                           
   stu.[StudentCode], os.ProcessId,os.StudentStatusId      
   --,LTRIM(RTRIM(ISNULL(os.[StudentEmail],''))) as OSEmail                  
   --,ltrim(rtrim(isnull( stu.[StudentEmail] ,''))) as StuEmail                  
   --,LTRIM(RTRIM(ISNULL(os.IqamaNo,''))) as OsIqamaNo                  
   --,ltrim(rtrim(isnull( stu.IqamaNo ,''))) as StuIqamaNo      
      
   , NewValueJson=     
   (    
    SELECT distinct jc.StudentCode,jc.StudentName,jc.StudentArabicName,jc.StudentEmail,jc.IqamaNo,jc.Mobile     
    FROM [tblStudentOpenApplyProcessed] jc where jc.[StudentCode] = os.[StudentCode] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER     
   )    
   , OldValueJson=     
   (    
    SELECT distinct jc.StudentCode,jc.StudentName,jc.StudentArabicName,jc.StudentEmail,jc.IqamaNo,jc.Mobile     
    FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER     
   )    
   ,NameUpdated=CASE                         
    WHEN ltrim(rtrim(os.[StudentName])) COLLATE SQL_Latin1_General_CP1256_CI_AS <>ltrim(rtrim(stu.[StudentName]))      
    THEN 1 ELSE 0 END                    
   ,ArabicNameUpdated=CASE                     
    WHEN LTRIM(RTRIM(os.StudentArabicName)) COLLATE SQL_Latin1_General_CP1256_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]))                         
    THEN 1 ELSE 0 END                    
   ,EmailUpdated=CASE                     
    WHEN ltrim(rtrim(isnull( os.[StudentEmail] ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))      
    THEN 1 ELSE 0 END                    
   ,IqamaNoUpdated=CASE WHEN ltrim(rtrim(isnull( os.IqamaNo ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))      
    THEN 1 ELSE 0 END                    
  FROM [dbo].[tblStudentOpenApplyProcessed] os                              
  LEFT JOIN [dbo].[tblStudent] stu                              
  ON LTRIM(RTRIM(os.[StudentCode])) COLLATE SQL_Latin1_General_CP1256_CI_AS=LTRIM(RTRIM(stu.[StudentCode]))      
 )t                          
 WHERE t.NameUpdated=1 OR t.ArabicNameUpdated=1 OR t.EmailUpdated=1 OR t.IqamaNoUpdated=1    
    
 -----End: Student Process      
      
 --ParentProcess      
 --RecordStatus --0=added/1=updated        
 INSERT INTO [tblNotification]                   
 (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)                              
 SELECT                    
  ProcessId, RecordStatus=CASE WHEN ParentId =0 THEN 1 ELSE 2 END  --added/updated                            
  ,0 as IsApproved, 'Parent' AS RecordType, GETDATE(),0 , [ParentCode] as student_id                         
  ,OldValueJson=ISNULL(OldValueJson,'')                        
  ,NewValueJson=ISNULL(NewValueJson,'')                        
 FROM                               
 (                  
  SELECT       
   ProcessId                          
   ,os.[ParentCode]      
   ,os.ParentId      
       
   ,NameUpdated=CASE                     
    WHEN     
    ltrim(rtrim(isnull( os.FatherName ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.FatherName ,'')))      
    OR    
    ltrim(rtrim(isnull( os.MotherName ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.MotherName ,'')))     
    THEN 1 ELSE 0 END                    
   ,EmailUpdated=CASE                     
    when     
    ltrim(rtrim(isnull( os.FatherEmail ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.FatherEmail ,'')))    
    OR     
    ltrim(rtrim(isnull( os.MotherEmail ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.MotherEmail ,'')))    
    THEN 1 ELSE 0 END                      
   ,IqamaNoUpdated=CASE     
   WHEN     
   ltrim(rtrim(isnull( os.FatherIqamaNo ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.FatherIqamaNo ,'')))      
   OR ltrim(rtrim(isnull( os.MotherIqamaNo ,''))) COLLATE SQL_Latin1_General_CP1256_CI_AS<>ltrim(rtrim(isnull( stu.MotherIqamaNo ,'')))      
    THEN 1 ELSE 0 END                    
       
   ,NewValueJson=     
   (    
    SELECT distinct    
     jc.ParentCode,jc.FatherName,jc.FatherArabicName,jc.FatherMobile,jc.FatherEmail    
     ,jc.MotherName,jc.MotherArabicName,jc.MotherMobile,jc.MotherEmail    
    FROM tblParentOpenApplyProcessed jc where jc.[ParentCode] COLLATE SQL_Latin1_General_CP1256_CI_AS= os.[ParentCode] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER     
   )    
   ,OldValueJson=     
   (    
    SELECT distinct    
     jc.ParentCode,jc.FatherName,jc.FatherArabicName,jc.FatherMobile,jc.FatherEmail    
     ,jc.MotherName,jc.MotherArabicName,jc.MotherMobile,jc.MotherEmail    
    FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER     
   )    
  FROM [dbo].tblParentOpenApplyProcessed os                              
  LEFT JOIN [dbo].[tblParent] stu                              
  ON os.[ParentCode] COLLATE SQL_Latin1_General_CP1256_CI_AS=stu.[ParentCode] --need to check with record      
 )t                             
 WHERE t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1      
      
  ------------------Notification group            
  DECLARE @NotificationTypeIdStudent int=0;                       
             
  select top 1 @NotificationTypeIdStudent=NotificationTypeId             
  from tblNotificationTypeMaster             
  where NotificationType='Student' and  ActionTable='tblStudent'       
        
  --TODO: Add count record for student            
  declare @NotificationGroupIdAdd int =1       --Add      
  declare @NotificationGroupIdUpdate int =2       --Update      
  declare @NotificationGroupIdWithdraw int =3       --Withdraw      
        
  --------------Start: Student record              
            
  if exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdStudent)                        
  begin            
   declare @NotificationCountAdd int=0            
   declare @NotificationCountUpdate int=0          
   declare @NotificationCountWithdraw int=0       
            
   select @NotificationCountAdd=count(1) from [tblNotification] where RecordType='Student' and RecordStatus=@NotificationGroupIdAdd            
   select @NotificationCountUpdate=count(1) from [tblNotification] where RecordType='Student' and RecordStatus=@NotificationGroupIdUpdate        
   select @NotificationCountWithdraw=count(1) from [tblNotification] where RecordType='Student' and RecordStatus=@NotificationGroupIdWithdraw      
      
   declare @NotificationGroupIdAddNew int =1       --Add      
   declare @NotificationGroupIdUpdateNew int =2       --Update      
   declare @NotificationGroupIdWithdrawNew int =3       --Withdraw      
      
   select top 1 @NotificationGroupIdAddNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdAdd      
      
   select top 1 @NotificationGroupIdUpdateNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdUpdate      
      
   select top 1 @NotificationGroupIdWithdrawNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdWithdraw      
      
   update tblNotificationGroup                        
   set NotificationCount=@NotificationCountAdd                        
   where  NotificationGroupId=@NotificationGroupIdAddNew        
                        
   update tblNotificationGroup                        
   set NotificationCount=@NotificationCountUpdate                        
   where  NotificationGroupId=@NotificationGroupIdUpdate      
      
   update tblNotificationGroup                        
   set NotificationCount=@NotificationCountWithdraw                        
   where  NotificationGroupId=@NotificationGroupIdWithdrawNew      
      
  end       
            
  ------------parent group             
  ----   add group detail for parent            
  DECLARE @NotificationTypeIdParent int=0;       
       
  select top 1       
   @NotificationTypeIdParent=NotificationTypeId             
  from tblNotificationTypeMaster             
  where NotificationType='Parent' and  ActionTable='tblParent'       
        
  if exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeIdParent)                        
  begin            
   declare @NotificationCountParentAdd int=0            
   declare @NotificationCountParentUpdate int=0            
             
   declare @NotificationGroupIdParentAdd int=0;            
   declare @NotificationGroupIdParentUpdate int=0;          
         
   select @NotificationCountParentAdd=count(1) from [tblNotification] where RecordType in ('Parent') and RecordStatus=@NotificationGroupIdAdd            
   select @NotificationCountParentUpdate=count(1) from [tblNotification] where RecordType in ('Parent') and RecordStatus=@NotificationGroupIdUpdate            
            
   select top 1 @NotificationGroupIdParentAdd=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdAdd          
      
   update tblNotificationGroup                        
   set NotificationCount=@NotificationCountParentAdd                        
   where  NotificationGroupId=@NotificationGroupIdParentAdd            
             
   select top 1 @NotificationGroupIdParentUpdate=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdUpdate                        
                        
   update tblNotificationGroup                        
   set NotificationCount=@NotificationCountParentUpdate                        
   where  NotificationGroupId=@NotificationGroupIdParentUpdate        
      
   end                  
              
   declare @NotificationGroupIdStudentAddNew int            
   declare @NotificationGroupIdStudentUpdateNew int       
   declare @NotificationGroupIdStudentWithdrawNew int       
   declare @NotificationGroupIdParentAddNew int            
   declare @NotificationGroupIdParentUpdateNew int            
         
   --Student      
   select top 1 @NotificationGroupIdStudentAddNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdAdd            
            
   select top 1 @NotificationGroupIdStudentUpdateNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdUpdate            
      
   select top 1 @NotificationGroupIdStudentWithdrawNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdStudent and NotificationAction=@NotificationGroupIdWithdraw          
            
   --Parent      
   select top 1 @NotificationGroupIdParentAddNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdAdd               
            
   select top 1 @NotificationGroupIdParentUpdateNew=NotificationGroupId from tblNotificationGroup             
   where NotificationTypeId=@NotificationTypeIdParent and NotificationAction=@NotificationGroupIdUpdate            
              
   --Add notification group detail for student            
   insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)                        
   select                         
   case when RecordStatus=1 then  @NotificationGroupIdStudentAddNew when     RecordStatus=2 then  @NotificationGroupIdStudentUpdateNew      
   else @NotificationGroupIdStudentWithdrawNew end      
   ,@NotificationTypeIdStudent as NotificationTypeId,RecordStatus,                        
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1                        
   from [tblNotification]                        
   where RecordType='Student'            
   --------------End: Student record                        
                        
   --------------Start: parent record               
                       
   insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)                        
   select                         
   case when RecordStatus=1 then  @NotificationGroupIdParentAddNew when     RecordStatus=2 then  @NotificationGroupIdParentUpdateNew      
   else @NotificationGroupIdStudentWithdrawNew end      
   ,@NotificationTypeIdParent as NotificationTypeId,RecordStatus,                        
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1                        
   from [tblNotification]                        
   where RecordType='Parent'       
      
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
                    
END 
GO

DROP PROCEDURE IF EXISTS [sp_GetNotificationOpenApplyStudent]
GO
  
CREATE PROCEDURE [dbo].[sp_GetNotificationOpenApplyStudent]      
 @NotificationTypeId int=0      
,@NotificationGroupId int=0      
,@NotificationGroupDetailId int=0      
AS      
BEGIN      
 SET NOCOUNT ON;     
 select     
  noti.RecordType, noti.OldValueJson, noti.NewValueJson,tgd.NotificationAction,    
  tgd.NotificationTypeId,tgd.NotificationGroupId,tgd.NotificationGroupDetailId,    
  stu.*     
 from tblNotificationGroupDetail tgd    
 join tblNotificationGroup tg on tgd.NotificationGroupId=tg.NotificationGroupId    
 join tblNotificationTypeMaster tgm on tg.NotificationTypeId=tgm.NotificationTypeId    
 join tblNotification noti on tgd.TableRecordId=noti.NotificationId    
 join [tblStudentOpenApplyProcessed] stu on noti.RecordId=stu.ProcessId    
 where NotificationType='Student'    
 and tgd.NotificationTypeId=@NotificationTypeId    
 and tgd.NotificationGroupId=@NotificationGroupId    
 and (@NotificationGroupDetailId=0 OR tgd.NotificationGroupDetailId=@NotificationGroupDetailId)    
    
END      
GO

DROP PROCEDURE IF EXISTS [sp_GetNotificationOpenApplyParent]
GO
  
CREATE PROCEDURE [dbo].[sp_GetNotificationOpenApplyParent]      
@NotificationTypeId int=0      
,@NotificationGroupId int=0      
,@NotificationGroupDetailId int=0      
AS      
BEGIN      
 SET NOCOUNT ON;       
     
 select     
  noti.RecordType, noti.OldValueJson, noti.NewValueJson,tgd.NotificationAction,    
  tgd.NotificationTypeId,tgd.NotificationGroupId,tgd.NotificationGroupDetailId,    
  stu.*     
 from tblNotificationGroupDetail tgd    
 join tblNotificationGroup tg on tgd.NotificationGroupId=tg.NotificationGroupId    
 join tblNotificationTypeMaster tgm on tg.NotificationTypeId=tgm.NotificationTypeId    
 join tblNotification noti on tgd.TableRecordId=noti.NotificationId    
 join tblParentOpenApplyProcessed stu on noti.RecordId=stu.ProcessId    
 where NotificationType='Parent'    
 and tgd.NotificationTypeId=@NotificationTypeId    
 and tgd.NotificationGroupId=@NotificationGroupId    
 and (@NotificationGroupDetailId=0 OR tgd.NotificationGroupDetailId=@NotificationGroupDetailId)    
    
END 
GO

DROP PROCEDURE IF EXISTS sp_ApproveOpenApplyParent
GO

CREATE proc sp_ApproveOpenApplyParent  
@LoginUserId int=0  
,@NotificationGroupDetailId int  
as  
begin  
  BEGIN TRY  
  BEGIN TRANSACTION TRANS1   
     
  
  --------------Start: Parent record    
  
   declare @NotificationGroupId  int=0;  
   declare @NotificationTypeId int=0;  
   declare @NotificationAction int=0;  
   declare @TableRecordId int=0;  
   declare @ProcessId int=0;  
   declare @ParentCode nvarchar(50)=''  
  
   select top 1     
    @NotificationGroupId=NotificationGroupId   
    ,@NotificationTypeId=NotificationTypeId   
    ,@NotificationAction=NotificationAction   
    ,@TableRecordId=TableRecordId  
   from tblNotificationGroupDetail  
   where NotificationGroupDetailId=@NotificationGroupDetailId  
  
   select top 1 @ProcessId=RecordId,@ParentCode=student_id from tblNotification where NotificationId=@TableRecordId  
         
   declare @NotificationGroupIdAdd int =1       --Add  
   declare @NotificationGroupIdUpdate int =2       --Update  
   declare @NotificationGroupIdWithdraw int =3       --Withdraw  
  
    if(@NotificationGroupIdAdd=@NotificationAction)--add  
    begin  
     declare @ParentId int=0  
      --Check parent record exists  
      if exists(select 1 from tblParent where ParentCode=@ParentCode)  
      begin  
       select top 1 @ParentId=ParentId from tblParent where ParentCode=@ParentCode  
       SELECT -1 AS Result, 'Record alredy exists.' AS Response   
      end  
      else if exists(select 1 from [tblParentOpenApplyProcessed] where ProcessId=@ProcessId)  
      begin  
       insert into tblParent  
       (  
        ParentCode,ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail  
        ,IsFatherStaff,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff  
        ,IsActive,IsDeleted,UpdateDate,UpdateBy  
        ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId  
       )  
       select top 1  
        ParentCode,ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail  
        ,IsFatherStaff,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff  
        ,IsActive,IsDeleted,UpdateDate,UpdateBy  
        ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId  
       from   
       [tblParentOpenApplyProcessed]  
       where ProcessId=@ProcessId  
  
       set @ParentId=SCOPE_IDENTITY();  
  
      end  
  
      delete from tblNotification where NotificationId=@TableRecordId  
      delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId  
  
      update tblNotificationGroup  
      set NotificationCount=NotificationCount-1  
      where NotificationGroupId=@NotificationGroupId  
    end  
    else if(@NotificationGroupIdUpdate=@NotificationAction)--update  
    begin  
     ----Update student info  
      update s  
      set          
       s.ParentCode    =t.ParentCode  
       ,s.ParentImage    =t.ParentImage  
       ,s.FatherName    =t.FatherName  
       ,s.FatherArabicName   =t.FatherArabicName  
       ,s.FatherNationalityId  =t.FatherNationalityId  
       ,s.FatherMobile    =t.FatherMobile  
       ,s.FatherEmail    =t.FatherEmail  
       ,s.IsFatherStaff   =t.IsFatherStaff  
       ,s.MotherName    =t.MotherName  
       ,s.MotherArabicName   =t.MotherArabicName  
       ,s.MotherNationalityId  =t.MotherNationalityId  
       ,s.MotherMobile    =t.MotherMobile  
       ,s.MotherEmail    =t.MotherEmail  
       ,s.IsMotherStaff   =t.IsMotherStaff  
       ,s.IsActive     =t.IsActive  
       ,s.IsDeleted    =t.IsDeleted  
       ,s.UpdateDate    =t.UpdateDate  
       ,s.UpdateBy     =t.UpdateBy  
       ,s.FatherIqamaNo   =t.FatherIqamaNo  
       ,s.MotherIqamaNo   =t.MotherIqamaNo  
       ,s.OpenApplyFatherId  =t.OpenApplyFatherId  
       ,s.OpenApplyMotherId  =t.OpenApplyMotherId  
       ,s.OpenApplyStudentId  =t.OpenApplyStudentId  
  
      from tblParent s  
      join [tblParentOpenApplyProcessed] t on s.ParentCode=t.ParentCode  
      where ProcessId=@ProcessId  
  
      delete from tblNotification where NotificationId=@TableRecordId  
      delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId  
  
      update tblNotificationGroup  
      set NotificationCount=NotificationCount-1  
      where NotificationGroupId=@NotificationGroupId  
    end      
     
    
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

DROP PROCEDURE IF EXISTS sp_ApproveOpenApplyStudent
GO   

CREATE proc sp_ApproveOpenApplyStudent      
@LoginUserId int=0      
,@NotificationGroupDetailId int      
as      
begin      
  BEGIN TRY      
  BEGIN TRANSACTION TRANS1      
  --------------Start: Student record              
      
   declare @ParentNotificationTypeId int=0;      
   declare @StudentNotificationTypeId int=0;      
      
   select top 1 @StudentNotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='Student'      
   select top 1 @ParentNotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='Parent'      
      
      
   select top 1      
    noti.RecordType, noti.OldValueJson, noti.NewValueJson,tgd.NotificationAction,      
    tgd.NotificationTypeId,tgd.NotificationGroupId,tgd.NotificationGroupDetailId      
    ,stu.ProcessId,stu.StudentId,stu.StudentCode,stu.StudentImage,stu.ParentId      
    ,stu.StudentName,stu.StudentArabicName,stu.StudentEmail,stu.DOB,stu.IqamaNo      
    ,stu.NationalityId,stu.GenderId,stu.AdmissionDate,stu.GradeId,stu.CostCenterId      
    ,stu.SectionId,stu.PassportNo,stu.PassportExpiry,stu.Mobile,stu.StudentAddress      
    ,stu.StudentStatusId,stu.WithdrawDate,stu.WithdrawAt,stu.WithdrawYear,stu.Fees      
    ,stu.IsGPIntegration,stu.TermId,stu.AdmissionYear,stu.PrinceAccount      
    ,stu.IsActive,stu.IsDeleted,stu.UpdateDate,stu.UpdateBy,stu.p_id_school_parent_id  as ParentCode      
   into #tempInfo      
   from tblNotificationGroupDetail tgd      
   join tblNotificationGroup tg on tgd.NotificationGroupId=tg.NotificationGroupId      
   join tblNotificationTypeMaster tgm on tg.NotificationTypeId=tgm.NotificationTypeId      
   join tblNotification noti on tgd.TableRecordId=noti.NotificationId     
     
   join [tblStudentOpenApplyProcessed] stu on noti.RecordId=stu.ProcessId      
   where NotificationType='Student'         
   --and (@NotificationGroupDetailId=0 OR tgd.NotificationGroupDetailId=@NotificationGroupDetailId)      
      
   if exists(select 1  from #tempInfo)      
   begin      
    declare @StudentCode nvarchar(50)=''      
    declare @ParentCode nvarchar(50)=''      
      
    declare @NotificationAction int=0      
    declare @NotificationGroupIdAdd int =1       --Add      
    declare @NotificationGroupIdUpdate int =2       --Update      
    declare @NotificationGroupIdWithdraw int =3       --Withdraw      
          
    select top 1 @NotificationAction=NotificationAction, @StudentCode=StudentCode,@ParentCode=ParentCode      
     from #tempInfo      
      
     ---Add      
    if(@NotificationGroupIdAdd=@NotificationAction)      
    begin      
      declare @ParentId int=0      
      --Check parent record exists      
      if exists(select 1 from tblParent where ParentCode=@ParentCode)      
      begin      
       select top 1 @ParentId=ParentId from tblParent where ParentCode=@ParentCode      
      end      
      else if exists(select 1 from [tblParentOpenApplyProcessed] where ParentCode=@ParentCode)      
      begin      
       insert into tblParent      
       (      
        ParentCode,ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail      
        ,IsFatherStaff,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff      
        ,IsActive,IsDeleted,UpdateDate,UpdateBy      
        ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId      
       )      
       select top 1      
        ParentCode,ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail      
        ,IsFatherStaff,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff      
        ,IsActive,IsDeleted,UpdateDate,UpdateBy      
        ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId      
       from       
       [tblParentOpenApplyProcessed]      
       where ParentCode=@ParentCode      
      
       set @ParentId=SCOPE_IDENTITY();             
      end      
      
      if(@ParentId>0)      
       begin      
       insert into tblStudent      
       (      
        StudentCode,StudentImage,ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
        ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry      
        ,Mobile,StudentAddress,StudentStatusId,WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration      
        ,TermId,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,p_id_school_parent_id      
       )      
       select top 1      
        StudentCode,StudentImage,ParentId=@ParentId,StudentName,StudentArabicName,StudentEmail,DOB,IqamaNo      
        ,NationalityId,GenderId,AdmissionDate,GradeId,CostCenterId,SectionId,PassportNo,PassportExpiry      
        ,Mobile,StudentAddress,StudentStatusId,WithdrawDate,WithdrawAt,WithdrawYear,Fees,IsGPIntegration      
        ,TermId,AdmissionYear,PrinceAccount,IsActive,IsDeleted,UpdateDate,UpdateBy,ParentCode      
       from       
       #tempInfo      
             
       declare @ParentNotificationId int=0      
       select top 1 @ParentNotificationId=NotificationId from tblNotification where RecordType='Parent' and student_id=@ParentCode      
      
       --Delete from parent notification      
       delete from tblNotificationGroupDetail where NotificationGroupDetailId=@ParentNotificationId      
      
       --Delete from notification detail for student      
       delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId      
      
       update tblNotificationGroup set NotificationCount=NotificationCount-1       
       where NotificationTypeId=@StudentNotificationTypeId and NotificationAction=@NotificationAction      
      
       update tblNotificationGroup set NotificationCount=NotificationCount-1       
       where NotificationTypeId=@ParentNotificationTypeId and NotificationAction=@NotificationAction      
      
       end      
      else      
      begin      
       --Unable to process parent, So unable to add student      
       SELECT -1 AS Result, 'Unable to process parent, So unable to add student' AS Response       
      end      
    end      
    else if(@NotificationGroupIdUpdate=@NotificationAction)--update      
    begin      
      ----Update student info      
      update s      
      set              
       s.StudentCode  =t.StudentCode      
       ,s.StudentImage   =t.StudentImage      
       ,s.StudentName   =t.StudentName      
       ,s.StudentArabicName =t.StudentArabicName      
       ,s.StudentEmail   =t.StudentEmail      
       ,s.DOB     =t.DOB      
       ,s.IqamaNo    =t.IqamaNo      
       ,s.NationalityId  =t.NationalityId      
       ,s.GenderId    =t.GenderId      
       ,s.AdmissionDate  =t.AdmissionDate      
       ,s.GradeId    =t.GradeId      
       ,s.CostCenterId   =t.CostCenterId      
       ,s.SectionId   =t.SectionId      
       ,s.PassportNo   =t.PassportNo      
       ,s.PassportExpiry  =t.PassportExpiry      
       ,s.Mobile    =t.Mobile      
       ,s.StudentAddress  =t.StudentAddress      
       ,s.StudentStatusId  =t.StudentStatusId      
       ,s.WithdrawDate   =t.WithdrawDate      
       ,s.WithdrawAt   =t.WithdrawAt      
       ,s.WithdrawYear   =t.WithdrawYear      
       ,s.Fees     =t.Fees      
       ,s.IsGPIntegration  =t.IsGPIntegration      
       ,s.TermId    =t.TermId      
       ,s.AdmissionYear  =t.AdmissionYear      
       ,s.PrinceAccount  =t.PrinceAccount      
       ,s.IsActive    =t.IsActive      
       ,s.IsDeleted   =t.IsDeleted      
       ,s.UpdateDate   =t.UpdateDate      
       ,s.UpdateBy    =t.UpdateBy      
       ,s.p_id_school_parent_id=t.ParentCode      
      from tblStudent s      
      join #tempInfo t on s.StudentCode=t.StudentCode      
      
      update tblNotificationGroup set NotificationCount=NotificationCount-1       
       where NotificationTypeId=@StudentNotificationTypeId and NotificationAction=@NotificationAction      
          
      --Delete from notification detail for student      
      delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId      
    end      
    else if(@NotificationGroupIdWithdraw=@NotificationAction)--withdraw      
    begin      
     declare @StudentId int      
     select top 1 @StudentId=StudentId from tblStudent where StudentCode=@StudentCode      
      
     declare @TotalAmountPending decimal(18,0)=0      
     select       
      @TotalAmountPending= isnull(sum(isnull(FeeAmount,0)),0)-isnull(sum(isnull(PaidAmount,0)),0)       
     from tblFeeStatement where StudentId=@StudentId      
      
     if(@TotalAmountPending>0)      
     begin      
      SELECT -2 AS Result, 'Unable to withdraw student as balance pending' AS Response       
     end      
     else      
     begin      
      --Withdraw student      
      update tblStudent      
      set StudentStatusId=2      
      where StudentId=@StudentId      
      
      --Delete from notification detail for student      
      delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId      
     end      
    end      
   end      
          
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

DROP PROCEDURE IF EXISTS sp_RejectOpenApplyStudent
GO 

CREATE proc sp_RejectOpenApplyStudent  
@LoginUserId int=0  
,@NotificationGroupDetailId int  
as  
begin  
  BEGIN TRY  
  BEGIN TRANSACTION TRANS1   
  
   declare @NotificationGroupId  int=0;  
   declare @NotificationTypeId int=0;  
   declare @NotificationAction int=0;  
   declare @TableRecordId int=0;  
   declare @ProcessId int=0;  
  
   select top 1     
    @NotificationGroupId=NotificationGroupId   
    ,@NotificationTypeId=NotificationTypeId   
    ,@NotificationAction=NotificationAction   
    ,@TableRecordId=TableRecordId  
   from tblNotificationGroupDetail  
   where NotificationGroupDetailId=@NotificationGroupDetailId  
  
   select top 1 @ProcessId=RecordId from tblNotification where NotificationId=@TableRecordId  
        
   delete from tblNotification where NotificationId=@TableRecordId  
   delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId  
  
   update tblNotificationGroup  
   set NotificationCount=NotificationCount-1  
   where NotificationGroupId=@NotificationGroupId  
     
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

DROP PROCEDURE IF EXISTS sp_RejectOpenApplyParent
GO 

CREATE proc sp_RejectOpenApplyParent  
@LoginUserId int=0  
,@NotificationGroupDetailId int  
as  
begin  
  BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
    
   declare @ParentNotificationTypeId int=0;  
   declare @StudentNotificationTypeId int=0;  
  
   select top 1 @StudentNotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='Student'  
   select top 1 @ParentNotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='Parent'  
    
  --------------Start: Parent record    
    
   --select top 1  
   -- noti.RecordType, noti.OldValueJson, noti.NewValueJson,tgd.NotificationAction,  
   -- tgd.NotificationTypeId,tgd.NotificationGroupId,tgd.NotificationGroupDetailId  
   -- ,stu.ProcessId,stu.ParentId,stu.ParentCode,stu.ParentImage,stu.FatherName  
   -- ,stu.FatherArabicName,stu.FatherNationalityId,stu.FatherMobile,stu.FatherEmail,stu.IsFatherStaff  
   -- ,stu.MotherName,stu.MotherArabicName,stu.MotherNationalityId,stu.MotherMobile,stu.MotherEmail  
   -- ,stu.IsMotherStaff,stu.IsActive,stu.IsDeleted,stu.UpdateDate,stu.UpdateBy,stu.FatherIqamaNo  
   -- ,stu.MotherIqamaNo  
   -- ,tgd.TableRecordId  
   --into #tempInfo  
   --from tblNotificationGroupDetail tgd  
   --join tblNotificationGroup tg on tgd.NotificationGroupId=tg.NotificationGroupId  
   --join tblNotificationTypeMaster tgm on tg.NotificationTypeId=tgm.NotificationTypeId  
   --join tblNotification noti on tgd.TableRecordId=noti.NotificationId  
   --join [tblParentOpenApplyProcessed] stu on noti.RecordId=stu.ParentCode  
   --where NotificationType='Parent'     
   --and (@NotificationGroupDetailId=0 OR tgd.NotificationGroupDetailId=@NotificationGroupDetailId)  
  
     
   declare @NotificationGroupId  int=0;  
   declare @NotificationTypeId int=0;  
   declare @NotificationAction int=0;  
   declare @TableRecordId int=0;  
  
   select top 1     
    @NotificationGroupId=NotificationGroupId   
    ,@NotificationTypeId=NotificationTypeId   
    ,@NotificationAction=NotificationAction   
    ,@TableRecordId=TableRecordId  
   from tblNotificationGroupDetail  
   where NotificationGroupDetailId=@NotificationGroupDetailId  
        
   delete from tblNotification where NotificationId=@TableRecordId  
   delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId  
  
   update tblNotificationGroup  
   set NotificationCount=NotificationCount-1  
   where NotificationGroupId=@NotificationGroupId  
     
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