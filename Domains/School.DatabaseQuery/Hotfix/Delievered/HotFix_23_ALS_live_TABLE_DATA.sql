
declare @ParentMenuId int=0
declare @DisplaySequence int=0

select top 1 @DisplaySequence =max(DisplaySequence)+1  from [tblMenu]

--dashbaord enrty
if not exists(select 1 from [tblRoleMenuMapping] where [RoleId]=3 and [MenuId]=1)
begin
	INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
	VALUES (3, 1, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)
end

--Menu under dashboard
INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES (N'Parent Dashboard', N'Home', N'ParentDashboard', 1, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)

declare @ParentDashboardMenuId int = SCOPE_IDENTITY()
INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES (3, @ParentDashboardMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

--main menu
set @DisplaySequence=@DisplaySequence+1;
INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy])
VALUES (N'Home', N'Home', N'', 0, @DisplaySequence, N'fa-solid fa-house', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)

set @ParentMenuId=SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 3, @ParentMenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

--------Add child menu
set @DisplaySequence=@DisplaySequence+1;
INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy])
VALUES (N'Parent Details', N'Home', N'ParentDashboardParentInfo', @ParentMenuId, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)

declare @MenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 3, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

-----------
set @DisplaySequence=@DisplaySequence+1;

INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy])
VALUES (N'Students Detail', N'Home', N'ParentDashboarStudentInfo', @ParentMenuId, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)

set @MenuId = SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 3, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)

-----------
set @DisplaySequence=@DisplaySequence+1;
INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy])
VALUES (N'Fee Statement', N'Home', N'ParentDashboardFeeStatement', @ParentMenuId, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)


set @MenuId = SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 3, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)


-----------
set @DisplaySequence=@DisplaySequence+1;
INSERT [dbo].[tblMenu] ([Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy])
VALUES (N'Invoice Detail', N'Home', N'ParentDashboardInvoiceDetail', @ParentMenuId, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)


set @MenuId = SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 3, @MenuId , 1, 1, 1, 1, 0, CAST(getdate() AS DateTime), -1)
-----------
