  
CREATE PROCEDURE [dbo].[sp_GetOpenApply]  
 @OpenApplyId bigint = 0,  
 @FilterSearch NVarChar(200)=null,  
 @FilterIsActive bit=1  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT top 1
	tgt.OpenApplyId
	,tgt.GrantType
	,tgt.ClientId
	,tgt.ClientSecret
	,tgt.Audience
	,tgt.OpenApplyJobPath
	,tgt.IsDeleted
	,tgt.IsActive
 FROM [tblOpenApplyMaster] tgt    
 WHERE tgt.OpenApplyId = CASE WHEN @OpenApplyId > 0 THEN @OpenApplyId ELSE tgt.OpenApplyId END   
 and IsDeleted=0 and IsActive=1
END  
GO

CREATE PROCEDURE [dbo].[sp_SaveOpenApply]  
	@LoginUserId int  
	,@OpenApplyId bigint  
	,@GrantType nvarchar(200)  
	,@ClientId nvarchar(200)  
	,@ClientSecret nvarchar(200)  
	,@Audience nvarchar(200)  
	,@OpenApplyJobPath nvarchar(200)  
	,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@OpenApplyId = 0)  
   BEGIN  
    INSERT INTO [tblOpenApplyMaster]  
        (
			GrantType
			,ClientId
			,ClientSecret
			,Audience
			,OpenApplyJobPath

			,IsActive  
			,IsDeleted  
			,UpdateDate  
			,UpdateBy
		)  
    VALUES  
        (
			 @GrantType
			,@ClientId
			,@ClientSecret
			,@Audience
			,@OpenApplyJobPath

			,@IsActive   
			,0  
			,GETDATE()  
			,@LoginUserId
		)  

		--SET @OpenApplyId=SCOPE_IDENTITY();
		--SELECT @OpenApplyId AS Result, 'Saved' AS Response
		SELECT 0 AS Result, 'Saved' AS Response  
   END  
   ELSE  
   BEGIN  
    UPDATE [tblOpenApplyMaster]  
      SET 
		GrantType = @GrantType
		,ClientId = @ClientId
		,ClientSecret = @ClientSecret
		,Audience = @Audience
		,OpenApplyJobPath = @OpenApplyJobPath

       ,IsActive = @IsActive        
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE OpenApplyId = @OpenApplyId  
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

create proc sp_GetNotificationList
@UserId int
as
begin
	select * from tblNotification
	where IsApproved=0 and UpdateDate>=getdate()-1
end
GO

create proc sp_ProcessOpenApplyRecord  
as  
begin  
 --1- added  
 --2- updated   
  
 insert into [tblNotification]  
 (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy])  
 select   
  id as RecordId,  
  case when [StudentCode] is null then 1 else 2 end RecordStatus,    
  0 as IsApproved,  
  'Student' as RecordType,  
  Getdate(),0  
 from   
 (  
  select * from [dbo].[OpenApplyStudents] os  
  left join [dbo].[tblStudent] stu  
  on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]  
 
	 AND   
	  (  
	   (  
	   os.[name] COLLATE SQL_Latin1_General_CP1_CI_AS <>stu.[StudentName] 
	   OR os.[other_name]  COLLATE SQL_Latin1_General_CP1_CI_AS <>stu.[StudentArabicName]  
	  OR os.[email]  COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[StudentEmail]  
		--OR os.[status] <>stu.[StudentStatusId]  
		--enrolled  
	   )  
	   OR  
	   1=1  
	  ) 
 )t  
  
 insert into [tblNotification]  
 (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy])  
 select   
  id,  
  case when [ParentCode] is null then 1 else 2 end RecordStatus,  
  --cast(0 as bit) as  
  0 as IsApproved,  
  'Mother' as RecordType,  
  Getdate(),0  
 from   
 (  
 select ROW_NUMBER() over(partition by   student_id,gender,parent_role order by student_id) as RN, * from [dbo].[OpenApplyParents] os  
  left join [dbo].[tblParent] stu  
  on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record  
  and os.gender='Female'
  AND   
  (  
   (  
    os.[name] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]  
    OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]  
   )  
   OR  
   1=1  
  )

 )t 
 where t.RN=1

 insert into [tblNotification]  
 (RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy])  
 select   
  id,  
  case when [ParentCode] is null then 1 else 2 end RecordStatus,  
  --cast(0 as bit) as  
  0 as IsApproved,  
  'Father' as RecordType,  
  Getdate(),0  
 from   
 (  
 select ROW_NUMBER() over(partition by   student_id,gender,parent_role order by student_id) as RN, * from [dbo].[OpenApplyParents] os  
  left join [dbo].[tblParent] stu  
  on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record  
  and os.gender='male'
  AND   
  (  
   (  
    os.[name] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]  
    OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]  
   )  
   OR  
   1=1  
  )

 )t 
 where t.RN=1

end
GO
