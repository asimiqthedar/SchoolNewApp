SET IDENTITY_INSERT [dbo].[tblDocumentTypeMaster] ON 
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Iqama', N'Iqama ', 0, 1, CAST(N'2024-04-02T10:04:01.817' AS DateTime), 1)
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Passport', N'Passport', 1, 0, CAST(N'2024-03-24T22:59:25.407' AS DateTime), 1)
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, N'Medical Certificate', N'Medical Certificate', 1, 0, CAST(N'2024-06-09T01:55:23.253' AS DateTime), 1)
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (4, N'Previous School Certificate', N'Previous School Certificate', 1, 0, CAST(N'2024-03-24T22:59:43.393' AS DateTime), 1)
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (5, N'Other Document', N'Other Documents', 1, 0, CAST(N'2024-03-24T22:59:54.107' AS DateTime), 1)
GO
INSERT [dbo].[tblDocumentTypeMaster] ([DocumentTypeId], [DocumentTypeName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (6, N'SCHOOL DOCUMENT', N'Added test', 1, 0, CAST(N'2024-04-22T00:35:45.380' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblDocumentTypeMaster] OFF
GO


SET IDENTITY_INSERT [dbo].[tblFeeTypeMaster] ON 
GO
INSERT [dbo].[tblFeeTypeMaster] ([FeeTypeId], [FeeTypeName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [IsPaymentPlan], [IsTermPlan], [DebitAccount], [CreditAccount], [IsPrimary], [IsGradeWise]) VALUES (1, N'UNIFORM FEE', 1, 0, CAST(N'2024-06-10T03:41:29.860' AS DateTime), 1, 0, 0, N'1200', N'2300', 0, 0)
GO
INSERT [dbo].[tblFeeTypeMaster] ([FeeTypeId], [FeeTypeName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [IsPaymentPlan], [IsTermPlan], [DebitAccount], [CreditAccount], [IsPrimary], [IsGradeWise]) VALUES (2, N'ENTRANCE EXAM FEE', 1, 0, CAST(N'2024-07-03T01:23:39.203' AS DateTime), 1, 0, 1, N'1200', N'2300', 0, 1)
GO
INSERT [dbo].[tblFeeTypeMaster] ([FeeTypeId], [FeeTypeName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [IsPaymentPlan], [IsTermPlan], [DebitAccount], [CreditAccount], [IsPrimary], [IsGradeWise]) VALUES (3, N'TUITION FEE', 1, 0, CAST(N'2024-06-10T03:42:16.293' AS DateTime), 1, 1, 1, N'1200', N'2300', 1, 1)
GO
SET IDENTITY_INSERT [dbo].[tblFeeTypeMaster] OFF
GO

SET IDENTITY_INSERT [dbo].[tblTermMaster] ON 
GO
INSERT [dbo].[tblTermMaster] ([TermId], [TermName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Term1', 1, 0, CAST(N'2024-03-15T18:35:51.977' AS DateTime), -1)
GO
INSERT [dbo].[tblTermMaster] ([TermId], [TermName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Term2', 1, 0, CAST(N'2024-03-15T18:35:51.977' AS DateTime), -1)
GO
INSERT [dbo].[tblTermMaster] ([TermId], [TermName], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, N'Term3', 1, 0, CAST(N'2024-03-15T18:35:51.977' AS DateTime), -1)
GO
SET IDENTITY_INSERT [dbo].[tblTermMaster] OFF
GO


SET IDENTITY_INSERT [dbo].[tblOpenApplyMaster] ON 
GO
INSERT [dbo].[tblOpenApplyMaster] ([OpenApplyId], [GrantType], [ClientId], [ClientSecret], [Audience], [OpenApplyJobPath], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy]) VALUES (1, N'client_credentials', N'3fd2660da747a2ddc94cce08e2f0ed6c783e073d66ee662a5fccd29e89005619edeec8c0608f3d39', N'52e5e7af069b7f063de3d0c4b4e8f904ccaa92e7c46f6abc7bf39592dd891e9a4a17b299112b98329d2b129aa935c2f4d993eda56bcb1e4683ef18f1', N'als.openapply.com', N'C://Openapply/JobPath', 0, 1, CAST(N'2024-03-31T03:39:46.063' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblOpenApplyMaster] OFF
GO



SET IDENTITY_INSERT [dbo].[tblCountryMaster] ON 
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Afghanistan', N'AFG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'Albania', N'ALB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (3, N'Algeria', N'DZA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (4, N'American Samoa', N'ASM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (5, N'Andorra', N'AND', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (6, N'Angola', N'AGO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (7, N'Anguilla', N'AIA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (8, N'Antarctica', N'ATA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (9, N'Antigua and Barbuda', N'ATG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (10, N'Argentina', N'ARG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (11, N'Armenia', N'ARM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (12, N'Aruba', N'ABW', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (13, N'Australia', N'AUS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (14, N'Austria', N'AUT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (15, N'Azerbaijan', N'AZE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (16, N'Bahamas (the)', N'BHS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (17, N'Bahrain', N'BHR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (18, N'Bangladesh', N'BGD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (19, N'Barbados', N'BRB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (20, N'Belarus', N'BLR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (21, N'Belgium', N'BEL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (22, N'Belize', N'BLZ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (23, N'Benin', N'BEN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (24, N'Bermuda', N'BMU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (25, N'Bhutan', N'BTN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (26, N'Bolivia (Plurinational State of)', N'BOL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (27, N'Bonaire, Sint Eustatius and Saba', N'BES', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (28, N'Bosnia and Herzegovina', N'BIH', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (29, N'Botswana', N'BWA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (30, N'Bouvet Island', N'BVT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (31, N'Brazil', N'BRA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (32, N'British Indian Ocean Territory (the)', N'IOT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (33, N'Brunei Darussalam', N'BRN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (34, N'Bulgaria', N'BGR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (35, N'Burkina Faso', N'BFA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (36, N'Burundi', N'BDI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (37, N'Cabo Verde', N'CPV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (38, N'Cambodia', N'KHM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (39, N'Cameroon', N'CMR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (40, N'Canada', N'CAN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (41, N'Cayman Islands (the)', N'CYM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (42, N'Central African Republic (the)', N'CAF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (43, N'Chad', N'TCD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (44, N'Chile', N'CHL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (45, N'China', N'CHN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (46, N'Christmas Island', N'CXR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (47, N'Cocos (Keeling) Islands (the)', N'CCK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (48, N'Colombia', N'COL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (49, N'Comoros (the)', N'COM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (50, N'Congo (the Democratic Republic of the)', N'COD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (51, N'Congo (the)', N'COG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (52, N'Cook Islands (the)', N'COK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (53, N'Costa Rica', N'CRI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (54, N'Croatia', N'HRV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (55, N'Cuba', N'CUB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (56, N'Curaçao', N'CUW', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (57, N'Cyprus', N'CYP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (58, N'Czechia', N'CZE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (59, N'Côte d Ivoire', N'CIV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (60, N'Denmark', N'DNK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (61, N'Djibouti', N'DJI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (62, N'Dominica', N'DMA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (63, N'Dominican Republic (the)', N'DOM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (64, N'Ecuador', N'ECU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (65, N'Egypt', N'EGY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (66, N'El Salvador', N'SLV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (67, N'Equatorial Guinea', N'GNQ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (68, N'Eritrea', N'ERI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (69, N'Estonia', N'EST', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (70, N'Eswatini', N'SWZ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (71, N'Ethiopia', N'ETH', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (72, N'Falkland Islands (the) [Malvinas]', N'FLK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (73, N'Faroe Islands (the)', N'FRO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (74, N'Fiji', N'FJI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (75, N'Finland', N'FIN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (76, N'France', N'FRA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (77, N'French Guiana', N'GUF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (78, N'French Polynesia', N'PYF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (79, N'French Southern Territories (the)', N'ATF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (80, N'Gabon', N'GAB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (81, N'Gambia (the)', N'GMB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (82, N'Georgia', N'GEO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (83, N'Germany', N'DEU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (84, N'Ghana', N'GHA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (85, N'Gibraltar', N'GIB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (86, N'Greece', N'GRC', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (87, N'Greenland', N'GRL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (88, N'Grenada', N'GRD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (89, N'Guadeloupe', N'GLP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (90, N'Guam', N'GUM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (91, N'Guatemala', N'GTM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (92, N'Guernsey', N'GGY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (93, N'Guinea', N'GIN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (94, N'Guinea-Bissau', N'GNB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (95, N'Guyana', N'GUY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (96, N'Haiti', N'HTI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (97, N'Heard Island and McDonald Islands', N'HMD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (98, N'Holy See (the)', N'VAT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (99, N'Honduras', N'HND', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (100, N'Hong Kong', N'HKG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (101, N'Hungary', N'HUN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (102, N'Iceland', N'ISL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (103, N'India', N'IND', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (104, N'Indonesia', N'IDN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (105, N'Iran (Islamic Republic of)', N'IRN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (106, N'Iraq', N'IRQ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (107, N'Ireland', N'IRL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (108, N'Isle of Man', N'IMN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (109, N'Israel', N'ISR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (110, N'Italy', N'ITA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (111, N'Jamaica', N'JAM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (112, N'Japan', N'JPN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (113, N'Jersey', N'JEY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (114, N'Jordan', N'JOR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (115, N'Kazakhstan', N'KAZ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (116, N'Kenya', N'KEN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (117, N'Kiribati', N'KIR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (118, N'Korea (the Democratic Peoples Republic of)', N'PRK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (119, N'Korea (the Republic of)', N'KOR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (120, N'Kuwait', N'KWT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (121, N'Kyrgyzstan', N'KGZ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (122, N'Lao People Democratic Republic (the)', N'LAO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (123, N'Latvia', N'LVA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (124, N'Lebanon', N'LBN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (125, N'Lesotho', N'LSO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (126, N'Liberia', N'LBR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (127, N'Libya', N'LBY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (128, N'Liechtenstein', N'LIE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (129, N'Lithuania', N'LTU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (130, N'Luxembourg', N'LUX', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (131, N'Macao', N'MAC', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (132, N'Madagascar', N'MDG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (133, N'Malawi', N'MWI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (134, N'Malaysia', N'MYS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (135, N'Maldives', N'MDV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (136, N'Mali', N'MLI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (137, N'Malta', N'MLT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (138, N'Marshall Islands (the)', N'MHL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (139, N'Martinique', N'MTQ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (140, N'Mauritania', N'MRT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (141, N'Mauritius', N'MUS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (142, N'Mayotte', N'MYT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (143, N'Mexico', N'MEX', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (144, N'Micronesia (Federated States of)', N'FSM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (145, N'Moldova (the Republic of)', N'MDA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (146, N'Monaco', N'MCO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (147, N'Mongolia', N'MNG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (148, N'Montenegro', N'MNE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (149, N'Montserrat', N'MSR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (150, N'Morocco', N'MAR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (151, N'Mozambique', N'MOZ', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (152, N'Myanmar', N'MMR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (153, N'Namibia', N'NAM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (154, N'Nauru', N'NRU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (155, N'Nepal', N'NPL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (156, N'Netherlands (the)', N'NLD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (157, N'New Caledonia', N'NCL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (158, N'New Zealand', N'NZL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (159, N'Nicaragua', N'NIC', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (160, N'Niger (the)', N'NER', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (161, N'Nigeria', N'NGA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (162, N'Niue', N'NIU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (163, N'Norfolk Island', N'NFK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (164, N'Northern Mariana Islands (the)', N'MNP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (165, N'Norway', N'NOR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (166, N'Oman', N'OMN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (167, N'Pakistan', N'PAK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (168, N'Palau', N'PLW', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (169, N'Palestine, State of', N'PSE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (170, N'Panama', N'PAN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (171, N'Papua New Guinea', N'PNG', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (172, N'Paraguay', N'PRY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (173, N'Peru', N'PER', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (174, N'Philippines (the)', N'PHL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (175, N'Pitcairn', N'PCN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (176, N'Poland', N'POL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (177, N'Portugal', N'PRT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (178, N'Puerto Rico', N'PRI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (179, N'Qatar', N'QAT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (180, N'Republic of North Macedonia', N'MKD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (181, N'Romania', N'ROU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (182, N'Russian Federation (the)', N'RUS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (183, N'Rwanda', N'RWA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (184, N'Réunion', N'REU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (185, N'Saint Barthélemy', N'BLM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (186, N'Saint Helena, Ascension and Tristan da Cunha', N'SHN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (187, N'Saint Kitts and Nevis', N'KNA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (188, N'Saint Lucia', N'LCA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (189, N'Saint Martin (French part)', N'MAF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (190, N'Saint Pierre and Miquelon', N'SPM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (191, N'Saint Vincent and the Grenadines', N'VCT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (192, N'Samoa', N'WSM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (193, N'San Marino', N'SMR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (194, N'Sao Tome and Principe', N'STP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (195, N'Saudi Arabia', N'SAU', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (196, N'Senegal', N'SEN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (197, N'Serbia', N'SRB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (198, N'Seychelles', N'SYC', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (199, N'Sierra Leone', N'SLE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (200, N'Singapore', N'SGP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (201, N'Sint Maarten (Dutch part)', N'SXM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (202, N'Slovakia', N'SVK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (203, N'Slovenia', N'SVN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (204, N'Solomon Islands', N'SLB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (205, N'Somalia', N'SOM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (206, N'South Africa', N'ZAF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (207, N'South Georgia and the South Sandwich Islands', N'SGS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (208, N'South Sudan', N'SSD', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (209, N'Spain', N'ESP', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (210, N'Sri Lanka', N'LKA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (211, N'Sudan (the)', N'SDN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (212, N'Suriname', N'SUR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (213, N'Svalbard and Jan Mayen', N'SJM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (214, N'Sweden', N'SWE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (215, N'Switzerland', N'CHE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (216, N'Syrian Arab Republic', N'SYR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (217, N'Taiwan (Province of China)', N'TWN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (218, N'Tajikistan', N'TJK', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (219, N'Tanzania, United Republic of', N'TZA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (220, N'Thailand', N'THA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (221, N'Timor-Leste', N'TLS', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (222, N'Togo', N'TGO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (223, N'Tokelau', N'TKL', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (224, N'Tonga', N'TON', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (225, N'Trinidad and Tobago', N'TTO', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (226, N'Tunisia', N'TUN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (227, N'Turkey', N'TUR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (228, N'Turkmenistan', N'TKM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (229, N'Turks and Caicos Islands (the)', N'TCA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (230, N'Tuvalu', N'TUV', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (231, N'Uganda', N'UGA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (232, N'Ukraine', N'UKR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (233, N'United Arab Emirates (the)', N'ARE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (234, N'United Kingdom of Great Britain and Northern Ireland (the)', N'GBR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (235, N'United States Minor Outlying Islands (the)', N'UMI', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (236, N'United States of America (the)', N'USA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (237, N'Uruguay', N'URY', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (238, N'Uzbekistan', N'UZB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (239, N'Vanuatu', N'VUT', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (240, N'Venezuela (Bolivarian Republic of)', N'VEN', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (241, N'Viet Nam', N'VNM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (242, N'Virgin Islands (British)', N'VGB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (243, N'Virgin Islands (U.S.)', N'VIR', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (244, N'Wallis and Futuna', N'WLF', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (245, N'Western Sahara', N'ESH', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (246, N'Yemen', N'YEM', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (247, N'Zambia', N'ZMB', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (248, N'Zimbabwe', N'ZWE', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (249, N'Aland Islands', N'ALA', 1, 0, CAST(N'2024-03-19T19:42:36.827' AS DateTime), -1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (250, N'American (United States)', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (251, N'British', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (252, N'Chinese (China)', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (253, N'Egyptian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (254, N'Emirati', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (255, N'Jordanian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (256, N'Kittian and Nevisian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (257, N'Kuwaiti', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (258, N'Lebanese', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (259, N'Malaysian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (260, N'Romanian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (261, N'Saudi Arabian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (262, N'Yemeni', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (263, N'American (United States)', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (264, N'British', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (265, N'Canadian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (266, N'Chinese (China)', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (267, N'Egyptian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (268, N'Emirati', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (269, N'Eritrean', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (270, N'Ethiopian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (271, N'French (France)', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (272, N'Jordanian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (273, N'Kuwaiti', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (274, N'Lebanese', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (275, N'Malaysian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (276, N'Mexican', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (277, N'Palestinian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (278, N'Romanian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (279, N'Saudi Arabian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (280, N'Syrian', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
INSERT [dbo].[tblCountryMaster] ([CountryId], [CountryName], [CountryCode], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (281, N'Yemeni', N'', 1, 0, CAST(N'2024-04-04T10:55:17.490' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblCountryMaster] OFF
GO

SET IDENTITY_INSERT [dbo].[tblCostCenterMaster] ON 
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (1, N'PYP', N'Primary Years Programme', 1, 0, CAST(N'2024-03-29T09:43:56.050' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (2, N'MYP', N'Middle Years Programme', 1, 0, CAST(N'2024-03-29T09:44:07.907' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblCostCenterMaster] ([CostCenterId], [CostCenterName], [Remarks], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (3, N'DP', N'Diploma Programme', 1, 0, CAST(N'2024-04-20T14:58:11.277' AS DateTime), 1, N'1200', N'2300')
GO

SET IDENTITY_INSERT [dbo].[tblCostCenterMaster] OFF
GO

SET IDENTITY_INSERT [dbo].[tblSchoolMaster] ON 
GO
INSERT [dbo].[tblSchoolMaster] ([SchoolId], [SchoolNameEnglish], [SchoolNameArabic], [BranchId], [CountryId], [City], [Address], [Telephone], [SchoolEmail], [WebsiteUrl], [VatNo], [Logo], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'Advance Learning School', N'شركة التعلم المتقدم', 1, 195, N'Riyadh', N'Queen street', N'48348383', N'school1@gmail.com', NULL, N'sadadasdasd', N'E:\iis\ALS\wwwroot\uploads\schoolimages\exrtica logo_f8dd.png', 1, 0, CAST(N'2024-04-03T00:16:14.820' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblSchoolMaster] OFF
GO



SET IDENTITY_INSERT [dbo].[tblGradeMaster] ON 
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (1, 1, 0, N'KG 1', 1, 0, 1, CAST(N'2024-06-09T01:55:12.760' AS DateTime), 1, N'', N'')
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (2, 1, 0, N'KG 2', 2, 0, 1, CAST(N'2024-03-29T09:45:20.760' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (3, 1, 0, N'GRADE 1', 3, 0, 1, CAST(N'2024-03-29T09:45:30.043' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (4, 1, 0, N'GRADE 2', 4, 0, 1, CAST(N'2024-03-29T09:45:39.983' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (5, 1, 0, N'GRADE 3', 5, 0, 1, CAST(N'2024-03-29T09:45:52.823' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (6, 1, 1, N'GRADE 4', 6, 0, 1, CAST(N'2024-03-29T09:46:04.990' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (7, 1, 2, N'GRADE 4', 7, 0, 1, CAST(N'2024-03-29T09:46:11.870' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (8, 1, 1, N'GRADE 5', 8, 0, 1, CAST(N'2024-03-29T09:46:20.240' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (9, 1, 2, N'GRADE 5', 9, 0, 1, CAST(N'2024-03-29T09:46:26.087' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (10, 2, 1, N'GRADE 6', 10, 0, 1, CAST(N'2024-03-29T09:46:42.767' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (11, 2, 2, N'GRADE 6', 11, 0, 1, CAST(N'2024-03-29T09:46:48.810' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (12, 2, 1, N'GRADE 7', 12, 0, 1, CAST(N'2024-03-29T09:46:59.473' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (13, 2, 2, N'GRADE 7', 13, 0, 1, CAST(N'2024-03-29T09:47:09.420' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (14, 2, 1, N'GRADE 8', 14, 0, 1, CAST(N'2024-03-29T09:47:22.523' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (15, 2, 2, N'GRADE 8', 15, 0, 1, CAST(N'2024-03-29T09:47:29.057' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (16, 2, 1, N'GRADE 9', 16, 0, 1, CAST(N'2024-03-29T09:47:37.840' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (17, 2, 2, N'GRADE 9', 17, 0, 1, CAST(N'2024-03-29T09:47:44.087' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (18, 2, 1, N'GRADE 10', 18, 0, 1, CAST(N'2024-03-29T09:48:00.400' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (19, 2, 2, N'GRADE 10', 19, 0, 1, CAST(N'2024-03-29T09:48:06.660' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (20, 3, 1, N'GRADE 11', 20, 0, 1, CAST(N'2024-04-02T09:54:14.523' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (22, 3, 1, N'GRADE 12', 22, 0, 1, CAST(N'2024-03-29T09:48:41.917' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (23, 3, 2, N'GRADE 12', 23, 0, 1, CAST(N'2024-03-29T09:48:47.127' AS DateTime), 1, NULL, NULL)
GO
INSERT [dbo].[tblGradeMaster] ([GradeId], [CostCenterId], [GenderTypeId], [GradeName], [SequenceNo], [IsDeleted], [IsActive], [UpdateDate], [UpdateBy], [DebitAccount], [CreditAccount]) VALUES (25, 3, 2, N'GRADE 11', 21, 0, 1, CAST(N'2024-04-02T09:54:14.523' AS DateTime), 1, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[tblGradeMaster] OFF
GO

SET IDENTITY_INSERT [dbo].[tblDiscountMaster] ON 
GO
INSERT [dbo].[tblDiscountMaster] ([DiscountId], [DiscountName], [DiscountPercent], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (1, N'SIBLING DISCOUNT', N'10.00', 1, 0, CAST(N'2024-04-17T13:03:11.043' AS DateTime), 1)
GO
INSERT [dbo].[tblDiscountMaster] ([DiscountId], [DiscountName], [DiscountPercent], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) VALUES (2, N'STAFF DISCOUNT', N'70.00', 1, 0, CAST(N'2024-04-17T13:03:37.337' AS DateTime), 1)
GO
SET IDENTITY_INSERT [dbo].[tblDiscountMaster] OFF
GO