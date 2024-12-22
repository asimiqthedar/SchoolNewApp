
truncate table [tblGradeMaster]
go

SET IDENTITY_INSERT [dbo].[tblGenderTypeMaster] ON 
GO
INSERT [dbo].[tblGenderTypeMaster] ([GenderTypeId], [GenderTypeName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (1, N'Boy', 1, 0, CAST(N'2024-03-24T22:48:36.763' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGenderTypeMaster] ([GenderTypeId], [GenderTypeName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (2, N'Girl', 1, 0, CAST(N'2024-03-24T22:48:41.470' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tblGenderTypeMaster] OFF
GO