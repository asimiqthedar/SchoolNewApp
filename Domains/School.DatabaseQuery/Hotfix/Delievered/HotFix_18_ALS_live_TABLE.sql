alter table [dbo].[INV_InvoicePayment]
add [PaymentMethodId] bigint null
GO

ALTER TABLE [dbo].[tblStudentOtherDiscountDetail] ADD 
[DiscountStatus] [int] NOT NULL CONSTRAINT [DF_tblStudentOtherDiscountDetail_DiscountStatus] DEFAULT ((3))
GO
ALTER TABLE [dbo].[tblStudentSiblingDiscountDetail] ADD 
[DiscountStatus] [int] NOT NULL CONSTRAINT [DF_tblStudentSiblingDiscountDetail_DiscountStatus] DEFAULT ((3))
GO
ALTER TABLE [dbo].[tblFeeStatement] ADD CONSTRAINT [PK_tblFeeStatement] PRIMARY KEY CLUSTERED
	(
		[FeeStatementId] ASC
	) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY  = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStudentOtherDiscountDetail] ADD CONSTRAINT [PK_tblStudentOtherDiscountDetail] PRIMARY KEY CLUSTERED
	(
		[StudentOtherDiscountDetailId] ASC
	) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY  = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
INSERT INTO [dbo].[tblNotificationTypeMaster]
           ([NotificationType]
           ,[ActionTable]
           ,[NotificationMsg]
           ,[IsActive]
           ,[NotificationActionTable])
     VALUES
           ('Other Discount'
           ,'tblStudentOtherDiscountDetail'
           ,'Other Discount #N record #Action'
           ,1
           ,'NotificationOtherDiscount')
GO
INSERT INTO [dbo].[tblNotificationTypeMaster]
           ([NotificationType]
           ,[ActionTable]
           ,[NotificationMsg]
           ,[IsActive]
           ,[NotificationActionTable])
     VALUES
           ('Sibling Discount'
           ,'tblStudentSiblingDiscountDetail'
           ,'Sibling Discount #N record #Action'
           ,1
           ,'NotificationSiblingDiscount')
GO

create view vw_GetStudentOpenApplyParentInfo
as
select 
distinct
OpenApplyStudentId=stu.id,
StudentCode=stu.student_id	,ParentCode=stu.p_id_school_parent_id,
father.ParentImage	,FatherName	,FatherArabicName	,FatherNationalityId	,FatherMobile	,FatherEmail	,IsFatherStaff	,FatherIqamaNo	
,OpenApplyFatherId	,MotherRowNo	,MotherName	,MotherArabicName	,MotherNationalityId	,MotherMobile	,MotherEmail	,IsMotherStaff	
,MotherIqamaNo	,OpenApplyMotherId

from OpenApplyStudents stu
left join
	(
	  select     
		FatherRowNo
		,OpenApplyStudentId=OpenApplyStudentId
		,ParentCode=parent_id
		,ParentImage =''      
		,FatherName =(ltrim(rtrim(isnull([first_name],'')))+' '+ltrim(rtrim(isnull([last_name],''))))      
		,FatherArabicName =isnull([other_name],'')      
		,FatherNationalityId =isnull(CountryId, 0)        
		,FatherMobile =isnull(mobile_phone,'')      
		,FatherEmail =ltrim(rtrim(isnull([email],'')))      
		,IsFatherStaff =0      
		,FatherIqamaNo=IqamaNo      
		,OpenApplyFatherId =id
	  from      
	  (      
	   select       
		ROW_NUMBER() over(partition by stuParent.id order by stuParent.id asc) as FatherRowNo      
		,stuParent.*,CountryId=isnull(tc.CountryId ,0)  ,stuMap.OpenApplyStudentId    
		from      
		OpenApplyStudents stu 
		inner join [OpenApplyStudentParentMap] stuMap on stuMap.OpenApplyStudentId=stu.id
		inner join OpenApplyparents stuParent on stumap.OpenApplyParentId=stuParent.id      
		left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName        
	   where stuParent.gender='Male'
	  )tFather
	  where FatherRowNo=1
  )father
  on stu.id=father.OpenApplyStudentId
  left join
  (
   select 
	MotherRowNo
    ,OpenApplyStudentId=OpenApplyStudentId   
	,ParentCode=parent_id
	,ParentImage =''      
    ,MotherName =(ltrim(rtrim([first_name]))+' '+ltrim(rtrim([last_name])))      
    ,MotherArabicName =[other_name]      
    ,MotherNationalityId =isnull(CountryId, 0)        
    ,MotherMobile =mobile_phone      
    ,MotherEmail =ltrim(rtrim([email]))      
    ,IsMotherStaff =0      
    ,MotherIqamaNo=IqamaNo      
    ,OpenApplyMotherId =id
   from      
   (      
    select 
     ROW_NUMBER() over(partition by stuParent.id order by stuParent.id asc) as MotherRowNo
     ,stuParent.*,CountryId=isnull(tc.CountryId ,0)    ,OpenApplyStudentId  
     from       
     OpenApplyStudents stu 
    inner join [OpenApplyStudentParentMap] stuMap on stuMap.OpenApplyStudentId=stu.id
    inner join OpenApplyparents stuParent on stumap.OpenApplyParentId=stuParent.id      
    left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName        
	where stuParent.gender='Female'
   )tMother 
   where MotherRowNo=1
   )mother
   on stu.id=mother.OpenApplyStudentId
GO
