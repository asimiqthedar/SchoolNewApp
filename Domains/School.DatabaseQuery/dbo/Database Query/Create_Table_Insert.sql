
SET IDENTITY_INSERT [dbo].[tblMenu] ON 
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Dashboard', N'Home', N'', 0, 1, N'fa fa-tachometer', 1, 0, CAST(N'2024-03-15T01:01:14.200' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Admin', N'Home', N'AdminDashboard', 1, 1, N'', 1, 0, CAST(N'2024-03-15T01:06:18.297' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, N'Student', N'Home', N'StudentDashboard', 1, 2, N'', 1, 0, CAST(N'2024-03-15T01:06:35.657' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (4, N'User', N'User', N'Index', 0, 2, N'fa-solid fa-user', 1, 0, CAST(N'2024-03-15T14:00:37.187' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (5, N'Setup', N'Setup', N'', 0, 5, N'fa-solid fa-gear', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (6, N'Gender', N'Setup', N'Gender', 5, 1, N'', 0, 1, CAST(N'2024-03-16T22:01:20.840' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (7, N'Cost Center', N'Setup', N'Costcenter', 5, 2, N'', 1, 0, CAST(N'2024-03-16T16:33:12.380' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (8, N'Grade', N'Setup', N'Grade', 5, 3, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (9, N'Section', N'Setup', N'GradeSection', 5, 4, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (10, N'Parents', N'Parent', N'', 0, 3, N'fa-solid fa-user-group', 1, 0, CAST(N'2024-03-19T12:11:08.130' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (11, N'All Parents', N'Parent', N'ParentList', 10, 1, N'', 1, 0, CAST(N'2024-03-19T12:12:15.660' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (12, N'Add Parent', N'Parent', N'AddEditParent', 10, 2, N'', 1, 0, CAST(N'2024-03-19T12:12:38.613' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (13, N'Students', N'Student', N'', 0, 4, N'fa-solid fa-user-graduate', 1, 0, CAST(N'2024-03-19T12:33:57.223' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (14, N'All Students', N'Student', N'StudentList', 13, 1, N'', 1, 0, CAST(N'2024-03-19T12:50:17.997' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (15, N'All Students', N'Student', N'AddEditStudent', 13, 3, N'', 1, 0, CAST(N'2024-03-19T12:50:27.820' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (17, N'Document Type', N'Setup', N'DocumentType', 5, 5, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
SET IDENTITY_INSERT [dbo].[tblMenu] OFF
GO
SET IDENTITY_INSERT [dbo].[tblRole] ON 
GO
INSERT [dbo].[tblRole] ([RoleId], [RoleName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Admin', 1, 0, CAST(N'2024-03-15T00:58:09.253' AS DateTime), -1)
GO
INSERT [dbo].[tblRole] ([RoleId], [RoleName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Student', 1, 0, CAST(N'2024-03-15T00:58:15.587' AS DateTime), -1)
GO
INSERT [dbo].[tblRole] ([RoleId], [RoleName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, N'Parent', 0, 1, CAST(N'2024-03-15T00:58:23.450' AS DateTime), -1)
GO
INSERT [dbo].[tblRole] ([RoleId], [RoleName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (4, N'Teacher', 0, 1, CAST(N'2024-03-15T00:58:29.197' AS DateTime), -1)
GO
SET IDENTITY_INSERT [dbo].[tblRole] OFF
GO
SET IDENTITY_INSERT [dbo].[tblRoleMenuMapping] ON 
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, 2, 1, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:18.893' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, 2, 3, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:29.453' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, 1, 1, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:31.730' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (4, 1, 2, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:34.563' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (5, 1, 4, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:37.310' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (6, 1, 5, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:40.313' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (7, 1, 6, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:42.990' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (8, 1, 7, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:29:45.853' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (9, 1, 8, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:30:17.010' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (10, 1, 9, 1, 1, 1, 1, 0, CAST(N'2024-03-15T01:30:21.267' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (11, 1, 10, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:14:09.920' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (12, 1, 11, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:14:13.207' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (13, 1, 12, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:14:15.913' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (14, 1, 13, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:50:58.157' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (15, 1, 14, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:01.943' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (16, 1, 15, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)
GO
INSERT [dbo].[tblRoleMenuMapping] ([RoleMenuMappingId], [RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (17, 1, 17, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)
GO
SET IDENTITY_INSERT [dbo].[tblRoleMenuMapping] OFF
GO
SET IDENTITY_INSERT [dbo].[tblUser] ON 
GO
INSERT [dbo].[tblUser] ([UserId], [UserName], [UserArabicName], [UserEmail], [UserPhone], [UserPass], [ProfileImg], [RoleId], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Admin 1', N'المشرف 1', N'admin1@gmail.com', N'987654320', N'Am+6U5mZf5uyQaLTeomumA==', NULL, 1, 1, 0, CAST(N'2024-03-15T18:35:51.977' AS DateTime), 1)
GO
INSERT [dbo].[tblUser] ([UserId], [UserName], [UserArabicName], [UserEmail], [UserPhone], [UserPass], [ProfileImg], [RoleId], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Student 1', N'الطالب 1', N'student1@gmail.com', N'987654320', N'NbGGkIYVmBwE8ov/fo/DOw==', NULL, 2, 1, 0, CAST(N'2024-03-15T18:35:36.953' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblUser] OFF
GO
