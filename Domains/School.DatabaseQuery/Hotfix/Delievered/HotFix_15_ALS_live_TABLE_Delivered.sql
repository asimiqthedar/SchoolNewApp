
--Tbl Menu REPORT

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 'Report', 'Report', '', 0, 17, 'fa-solid fa-file', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
declare @MenuId int= SCOPE_IDENTITY()
declare @NewMenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 'Uniform Revenue', 'Report', 'UniformRevenue', @MenuId, 18, '', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
set @NewMenuId = SCOPE_IDENTITY()
INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 1, @NewMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 'Total Revenue', 'Report', 'TotalRevenue', @MenuId, 20, '', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
set @NewMenuId = SCOPE_IDENTITY()
INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 1, @NewMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 'Fees Revenue', 'Report', 'FeesRevenue', @MenuId, 21, '', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
set @NewMenuId = SCOPE_IDENTITY()
INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 1, @NewMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 'Discount Report', 'Report', 'DiscountReport', @MenuId, 22, '', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
set @NewMenuId = SCOPE_IDENTITY()
INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES ( 1, @NewMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

go
