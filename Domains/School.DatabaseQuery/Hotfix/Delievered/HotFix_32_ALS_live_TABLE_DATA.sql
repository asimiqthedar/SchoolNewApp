declare @ParentMenuId int
select top 1 @ParentMenuId =MenuId from tblMenu where Menu='Report' and IsActive=1 and IsDeleted=0 and ParentMenuId=0 and IsActive=1 and IsDeleted=0
select @ParentMenuId 

update tblMenu
set ParentMenuId=@ParentMenuId
where Menu in ('General Report','Parent Statement')

update tblMenu
set Menu='Parent Student Report'
where Menu in ('Parent Statement')

update tblMenu
set MenuAction='ParentStudentReport'
where Menu='Parent Student Report'
GO

---------------New menu

declare @ParentMenuId int=0
declare @DisplaySequence int=0

select top 1 @ParentMenuId =MenuId  from [tblMenu] where Menu='Report' and ParentMenuId=0
and IsActive=1 and IsDeleted=0
select top 1 @DisplaySequence =max(DisplaySequence)+1  from [tblMenu] 

select @ParentMenuId

--------Add child menu --General Report

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Parent Statement', 'Report', 'ParentStudentStatementReport', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

declare @MenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)