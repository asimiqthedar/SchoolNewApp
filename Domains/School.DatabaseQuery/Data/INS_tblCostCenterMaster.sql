truncate table [tblCostCenterMaster]
go

SET IDENTITY_INSERT [dbo].[tblCostCenterMaster] ON 
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (1, N'PYP', N'Primary Years Programme', 1, 0, CAST(N'2024-03-29T09:43:56.050' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (2, N'MYP', N'Middle Years Programme', 1, 0, CAST(N'2024-03-29T09:44:07.907' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (3, N'DP', N'Diploma Programme', 1, 0, CAST(N'2024-04-24T22:15:51.183' AS DateTime), 1, N'', N'')
GO
SET IDENTITY_INSERT [dbo].[tblCostCenterMaster] OFF
GO
