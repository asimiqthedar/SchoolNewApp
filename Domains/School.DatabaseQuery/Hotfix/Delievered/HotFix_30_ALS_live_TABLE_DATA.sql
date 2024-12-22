
declare @ParentMenuId int=0
declare @DisplaySequence int=0

select top 1 @ParentMenuId =MenuId  from [tblMenu] where Menu='Report' and ParentMenuId=0
and IsActive=1 and IsDeleted=0
select top 1 @DisplaySequence =max(DisplaySequence)+1  from [tblMenu] 


--------Add child menu --General Report

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'General Report', 'Report', 'GeneralReport', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

declare @MenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

--------Add child menu --Parent Statement
set @DisplaySequence=@DisplaySequence+1;
INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Parent Statement', 'Report', 'ParentStudentStatementReport', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)