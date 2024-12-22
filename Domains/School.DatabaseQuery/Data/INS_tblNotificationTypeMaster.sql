truncate table [tblNotificationTypeMaster]
go

SET IDENTITY_INSERT [dbo].[tblNotificationTypeMaster] ON 
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationTypeId], [NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES (1, N'Fee Payment Plan', N'tblFeePaymentPlan', N'Payment Plan #N record #Action', 1, NULL)
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationTypeId], [NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES (44, N'OpenApplyRecordProcessing', N'tblStudent', N'Student #N record #Action', 1, NULL)
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationTypeId], [NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES (45, N'OpenApplyRecordProcessing', N'tblParent', N'Parent #N record #Action', 1, NULL)
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationTypeId], [NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES (46, N'Academic Term', N'tblSchoolTermAcademic', N'Academic Term #N record #Action', 1, NULL)
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationTypeId], [NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES (1045, N'Fee Generated', N'tblFeeGenerate', N'Fee Generated #N record #Action', 1, N'NotificationGenerateFee')
GO
SET IDENTITY_INSERT [dbo].[tblNotificationTypeMaster] OFF
GO