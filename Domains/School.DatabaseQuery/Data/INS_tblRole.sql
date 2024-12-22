truncate table [tblRole]
go

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