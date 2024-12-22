

truncate table [tblMenu]
go


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
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (5, N'Setup', N'Setup', N'', 0, 6, N'fa-solid fa-gear', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (6, N'Gender', N'Setup', N'Gender', 5, 5, N'', 1, 0, CAST(N'2024-03-16T22:01:20.840' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (7, N'Cost Center', N'Setup', N'Costcenter', 5, 6, N'', 1, 0, CAST(N'2024-03-16T16:33:12.380' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (8, N'Grade', N'Setup', N'Grade', 5, 7, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (9, N'Section', N'Setup', N'Section', 5, 8, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (10, N'Parents', N'Parent', N'', 0, 3, N'fa-solid fa-user-group', 0, 0, CAST(N'2024-03-19T12:11:08.130' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (11, N'Parents', N'Parent', N'ParentList', 13, 1, N'', 1, 0, CAST(N'2024-03-19T12:12:15.660' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (12, N'Add/Edit Parent', N'Parent', N'AddEditParent', 10, 2, N'', 1, 0, CAST(N'2024-03-19T12:12:38.613' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (13, N'Masters', N'Student', N'', 0, 4, N'fa-solid fa-user-graduate', 1, 0, CAST(N'2024-03-19T12:33:57.223' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (14, N'Students', N'Student', N'StudentList', 13, 1, N'', 1, 0, CAST(N'2024-03-19T12:50:17.997' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (15, N'Add/Edit Student', N'Student', N'AddEditStudent', 13, 3, N'', 0, 0, CAST(N'2024-03-19T12:50:27.820' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (17, N'Document Type', N'Setup', N'DocumentType', 5, 9, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (18, N'Student Status', N'Setup', N'StudentStatus', 5, 6, N'', 0, 1, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (20, N'Invoice Type', N'Setup', N'InvoiceType', 5, 7, N'', 0, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (21, N'Open Apply', N'Setup', N'OpenApply', 5, 8, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (22, N'School', N'School', N'', 0, 5, N'fa-solid fa-school', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (23, N'Branch', N'School', N'Branch', 22, 1, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (24, N'School', N'School', N'School', 22, 2, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (25, N'Add/Edit School', N'School', N'AddEditSchool', 22, 3, N'', 0, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (26, N'Fee Type', N'Fee', N'FeeType', 5, 10, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1026, N'Vat', N'Setup', N'Vat', 5, 11, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1027, N'Discount', N'Setup', N'Discount', 5, 12, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1028, N'School', N'School', N'School', 24, 13, N'', 0, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1029, N'Academic Year', N'AcademicYear', N'AcademicYear', 22, 3, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
INSERT [dbo].[tblMenu] ([MenuId], [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1030, N'Term', N'Term', N'Term', 22, 4, N'', 1, 0, CAST(N'2024-03-16T22:46:39.540' AS DateTime), -1)
GO
SET IDENTITY_INSERT [dbo].[tblMenu] OFF
GO
