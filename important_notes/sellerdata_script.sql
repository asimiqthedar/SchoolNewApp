USE [ALS_LIVE]
GO
/****** Object:  Table [dbo].[SellerDeviceConfigurations]    Script Date: 28/11/2024 10:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SellerDeviceConfigurations](
	[SellerDeviceConfigurationId] [bigint] IDENTITY(1,1) NOT NULL,
	[SellerId] [bigint] NOT NULL,
	[UserName] [varchar](500) NOT NULL,
	[DeviceManufacturer] [varchar](500) NOT NULL,
	[DeviceName] [varchar](500) NOT NULL,
	[DeviceId] [varchar](500) NOT NULL,
	[SerialNumber] [varchar](500) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_SellerDeviceConfigurations] PRIMARY KEY CLUSTERED 
(
	[SellerDeviceConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SellerMaster]    Script Date: 28/11/2024 10:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SellerMaster](
	[SellerId] [bigint] IDENTITY(1,1) NOT NULL,
	[CommonName] [varchar](500) NOT NULL,
	[OrganizationName] [varchar](500) NULL,
	[OrganizationIdentifier] [varchar](500) NOT NULL,
	[OrganizationUnitName] [varchar](500) NOT NULL,
	[Location] [varchar](500) NOT NULL,
	[Industry] [varchar](500) NOT NULL,
	[SchemeType] [varchar](400) NULL,
	[SchemaNo] [varchar](100) NULL,
	[CountryName] [varchar](500) NOT NULL,
	[CountyIdentificationCode] [varchar](2) NULL,
	[DocumentCurrencyCode] [varchar](100) NULL,
	[TaxCurrencyCode] [varchar](100) NULL,
	[CityName] [varchar](100) NULL,
	[StreetName] [varchar](400) NULL,
	[BuildingNumber] [varchar](400) NULL,
	[CitySubdivisionName] [varchar](400) NULL,
	[PostalZone] [varchar](400) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_SellerMaster] PRIMARY KEY CLUSTERED 
(
	[SellerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[SellerDeviceConfigurations] ON 

INSERT [dbo].[SellerDeviceConfigurations] ([SellerDeviceConfigurationId], [SellerId], [UserName], [DeviceManufacturer], [DeviceName], [DeviceId], [SerialNumber], [IsDeleted], [UpdateOn], [UpdateBy]) VALUES (1, 1, N'Asim', N'LENOVO', N'DESKTOP-1J1IS6T', N'21C2S0SM00', N'1-LENOVO|2- L14-100|3-21C2S0SM00', 0, CAST(N'2024-05-12T23:34:31.363' AS DateTime), 1)
INSERT [dbo].[SellerDeviceConfigurations] ([SellerDeviceConfigurationId], [SellerId], [UserName], [DeviceManufacturer], [DeviceName], [DeviceId], [SerialNumber], [IsDeleted], [UpdateOn], [UpdateBy]) VALUES (2, 1, N'Asim', N'HP', N'Pavilion14', N'8202121', N'1-HP|2-Pavilion14|3-8202121', 0, CAST(N'2024-05-19T10:28:17.420' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[SellerDeviceConfigurations] OFF
GO
SET IDENTITY_INSERT [dbo].[SellerMaster] ON 

INSERT [dbo].[SellerMaster] ([SellerId], [CommonName], [OrganizationName], [OrganizationIdentifier], [OrganizationUnitName], [Location], [Industry], [SchemeType], [SchemaNo], [CountryName], [CountyIdentificationCode], [DocumentCurrencyCode], [TaxCurrencyCode], [CityName], [StreetName], [BuildingNumber], [CitySubdivisionName], [PostalZone], [IsDeleted], [UpdateOn], [UpdateBy]) VALUES (1, N'ALS Software', N'شركه التعليم المتطور المحدوده', N'300056967800003', N'3000569678', N'Riyadh', N'Education', N'CRN', N'1010208833', N'SA', N'SA', N'SAR', N'SAR', N'Riyadh', N'Nakheel District', N'6708', N'Riyadh', N'11311', 0, CAST(N'2024-06-06T10:08:25.040' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[SellerMaster] OFF
GO
