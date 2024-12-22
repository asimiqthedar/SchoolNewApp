create proc sp_CleanUpOpenApplyRecord
as
begin
	truncate table OpenApplyParents
	truncate table OpenApplyStudentParentMap
	truncate table OpenApplyParents
end
Go

create proc [dbo].[sp_ProcessOpenApplyRecordToNotification]            
as            
begin            
 --1- added            
 --2- updated             
 BEGIN TRY          
 BEGIN TRANSACTION TRANS1          
  --NotificationAction 1- Add, 2-Edit, 3-DELETEd      
      
  ----DELETE previous record      
  DELETE FROM [tblNotification]   
  WHERE RecordType='Student'  
  AND RecordType='Mother'  
  AND RecordType='Father'  
      
  DELETE t      
  FROM tblNotificationGroupDetail t      
  INNER JOIN tblNotificationTypeMaster  tm   
  ON t.NotificationTypeId=tm.NotificationTypeId      
  WHERE tm.ActionTable IN ('tblStudent','tblParent')      
      
  DELETE t      
  FROM tblNotificationGroup t      
  INNER JOIN tblNotificationTypeMaster  tm   
  ON t.NotificationTypeId=tm.NotificationTypeId      
  WHERE tm.ActionTable IN ('tblStudent','tblParent')      
      
  DELETE FROM tblNotificationTypeMaster  where ActionTable in ('tblStudent','tblParent')      
     
  INSERT INTO [tblNotification]  
  (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)            
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
    stu.[StudentCode], os.id, os.[student_id]  
    , NewValueJson= (SELECT * FROM [OpenApplyStudents] jc where jc.[student_id] = os.[student_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )      
    , OldValueJson= (SELECT * FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )      
    ,NameUpdated=CASE       
     WHEN LTRIM(RTRIM(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))      
     THEN 1 ELSE 0 END  
    ,ArabicNameUpdated=CASE   
     WHEN LTRIM(RTRIM(os.[other_name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))       
     THEN 1 ELSE 0 END  
    ,EmailUpdated=CASE   
     WHEN LTRIM(RTRIM(ISNULL(os.[email],''))) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))      
     THEN 1 ELSE 0 END  
    ,IqamaNoUpdated=CASE WHEN LTRIM(RTRIM(ISNULL(os.IqamaNo,''))) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))      
     THEN 1 ELSE 0 END  
   FROM [dbo].[OpenApplyStudents] os            
   LEFT JOIN [dbo].[tblStudent] stu            
   ON os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]  
   AND  
   (            
    (            
    (LTRIM(RTRIM(os.first_name))+ ' '+ ltrim(rtrim(os.last_name))) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))      
    OR LTRIM(RTRIM(os.[other_name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))         
    OR LTRIM(RTRIM(ISNULL(os.[email],''))) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
    OR LTRIM(RTRIM(ISNULL(os.IqamaNo,''))) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))         
    )            
    OR            
    1=1            
   )      
  )t        
  WHERE t.NameUpdated=1 OR t.ArabicNameUpdated=1 OR t.EmailUpdated=1 OR t.IqamaNoUpdated=1    
            
  INSERT INTO [tblNotification]  
  (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)            
  SELECT  
   id, RecordStatus=CASE WHEN [ParentCode] IS NULL THEN 1 ELSE 2 END  --added/updated          
   ,0 as IsApproved, 'Mother' AS RecordType, GETDATE(),0 , student_id       
   ,OldValueJson=ISNULL(OldValueJson,'')      
   ,NewValueJson=ISNULL(NewValueJson,'')      
  FROM             
  (            
   SELECT       
    ROW_NUMBER() OVER(PARTITION BY student_id,gender ORDER BY student_id) as RN,        
    stu.[ParentCode], os.id,os.[student_id]      
    ,NameUpdated=CASE   
     WHEN(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName            
     THEN 1 ELSE 0 END  
    ,EmailUpdated=CASE   
     when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail            
     THEN 1 ELSE 0 END    
    ,IqamaNoUpdated=CASE WHEN LTRIM(RTRIM(ISNULL(os.IqamaNo,''))) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.MotherIqamaNo ,'')))      
     THEN 1 ELSE 0 END  
    ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )      
    ,OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )      
   FROM [dbo].[OpenApplyParents] os            
   LEFT JOIN [dbo].[tblParent] stu            
   ON os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record            
   AND os.gender='Female'          
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
  WHERE t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1      
          
  INSERT INTO [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)            
  SELECT  
   id,            
   case when [ParentCode] is null then 1 else 2 end RecordStatus,  
   0 as IsApproved,  
   'Father' as RecordType, Getdate(), 0 ,student_id  
  ,OldValueJson=ISNULL(OldValueJson,'')      
  ,NewValueJson=ISNULL(NewValueJson,'')      
  FROM  
  (  
   SELECT  
    ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,         
    stu.[ParentCode], os.id , os.[student_id]  
    ,NameUpdated=case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]            
     then 1 else 0 end  
    ,EmailUpdated=case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]            
    then 1 else 0 end  
    ,IqamaNoUpdated=case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.FatherIqamaNo ,'')))      
    then 1 else 0 end  
    ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )      
    , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )  
   FROM [dbo].[OpenApplyParents] os            
   LEFT JOIN [dbo].[tblParent] stu            
   ON os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record            
   AND os.gender='male'          
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
  WHERE t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1  
  
  ---Process final table to notification table      
      
  ----insert into master record : tblNotificationTypeMaster      
  IF NOT EXISTS(SELECT TOP 1 * FROM tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblStudent')      
  BEGIN       
   INSERT INTO tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)      
   SELECT  'OpenApplyRecordProcessing', 'tblStudent', 'Student #N record #Action' ,1      
  END      
      
  IF NOT EXISTS(SELECT TOP 1 * FROM tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblParent')      
  BEGIN       
   INSERT INTO tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)      
   SELECT  'OpenApplyRecordProcessing', 'tblParent', 'Parent #N record #Action' ,1      
  END  
  
  DECLARE @NotificationTypeId int=0;      
      
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
  
END  
GO

alter proc sp_processOpenapplyInsertFirstTime
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