insert into tbluser(UserName	,UserArabicName	,UserEmail	,UserPhone	,UserPass	,ProfileImg	,RoleId	,IsActive	,IsDeleted	,UpdateDate	,UpdateBy	,IsApprover)
select 
UserName	=FatherName
,UserArabicName	=FatherArabicName
,UserEmail	=ParentCode
,UserPhone	=FatherMobile
,UserPass	='q8wbTLai6/4='
,ProfileImg	=''
,RoleId	=3
,IsActive=1	
,IsDeleted	=0
,UpdateDate	=getdate()
,UpdateBy	=1
,IsApprover=0

from tblParent
where isnull(FatherEmail,'') !=''