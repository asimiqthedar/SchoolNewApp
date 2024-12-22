
declare @ParentMenuId int=0
declare @DisplaySequence int=0

select top 1 @DisplaySequence =max(DisplaySequence)+1  from [tblMenu]

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Report', 'Report', '', 0, @DisplaySequence, 'fa-solid fa-file', 1, 0, CAST(getdate() AS DateTime), -1)
set @ParentMenuId=SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @ParentMenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

--------Add child menu
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'All Revenue', 'Report', 'AllRevenueReport', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

declare @MenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)


----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Monthly Revenue', 'Report', 'MonthlyRevenue', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Advance Fee Revenue', 'Report', 'AdvanceFeeRevenue', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Discount Report', 'Report', 'DiscountReport', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Entrance Revenue', 'Report', 'EntranceRevenue', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Tuition Revenue', 'Report', 'TuitionRevenue', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

----
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Uniform Revenue', 'Report', 'UniformRevenue', @ParentMenuId, @DisplaySequence, '', 1, 0, CAST(getdate() AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

