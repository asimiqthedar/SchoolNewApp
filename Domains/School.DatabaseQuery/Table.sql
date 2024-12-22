USE [als_dev]
GO
------------Invoice new number table
  CREATE TABLE [dbo].[Transactions](
	[Id] int IDENTITY(1,1) NOT NULL,
	TransactionID int NOT NULL,
	TransactionNo int NOT NULL,
) ON [PRIMARY]

--insert query to get latest number
insert into [Transactions]
select 1,6464

/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 6/22/2024 4:22:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[_oldInvoiceBuyer]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_oldInvoiceBuyer](
	[BuyerId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceId] [bigint] NOT NULL,
	[BuyerIdentificationID] [varchar](100) NOT NULL,
	[SchemeID] [varchar](100) NOT NULL,
	[CompanyID] [varchar](100) NULL,
	[RegistrationName] [varchar](100) NULL,
	[CountryIdentificationCode] [varchar](100) NULL,
	[CitySubdivisionName] [varchar](400) NULL,
	[PostalZone] [varchar](50) NULL,
	[CityName] [varchar](400) NULL,
	[BuildingNumber] [varchar](50) NULL,
	[StreetName] [varchar](400) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_InvoiceBuyer] PRIMARY KEY CLUSTERED 
(
	[BuyerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_oldInvoiceItem]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_oldInvoiceItem](
	[InvoiceItemId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceId] [bigint] NOT NULL,
	[ProductName] [varchar](100) NOT NULL,
	[ProductPrice] [decimal](18, 2) NOT NULL,
	[ProductQuantity] [int] NOT NULL,
	[TotalPrice] [decimal](18, 2) NOT NULL,
	[DiscountValue] [decimal](18, 2) NULL,
	[TotalPriceAfterDiscount] [decimal](18, 2) NULL,
	[VatPercentage] [decimal](5, 2) NULL,
	[VatValue] [decimal](18, 2) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_InvoiceItem] PRIMARY KEY CLUSTERED 
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_OldInvoiceMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_OldInvoiceMaster](
	[InvoiceId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [varchar](50) NULL,
	[MainInvoiceNo] [varchar](50) NULL,
	[InvoiceAmount] [decimal](18, 2) NULL,
	[InvoiceType] [int] NULL,
	[PaymentMethod] [int] NULL,
	[IssueDate] [varchar](50) NULL,
	[IssueTime] [varchar](50) NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[TotalPriceAfterDiscount] [decimal](18, 2) NULL,
	[VatValue] [decimal](18, 2) NULL,
	[PayableAmount] [decimal](18, 2) NULL,
	[RefundPayableAmount] [decimal](18, 2) NULL,
	[InvoiceZATCAMode] [varchar](100) NULL,
	[EncodedInvoice] [nvarchar](max) NULL,
	[InvoiceHash] [nvarchar](max) NULL,
	[UUID] [nvarchar](800) NULL,
	[ReportingStatus] [varchar](100) NULL,
	[QRCodePath] [nvarchar](max) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_InvoiceMaster] PRIMARY KEY CLUSTERED 
(
	[InvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_OldInvoiceSeller]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_OldInvoiceSeller](
	[SellerId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceId] [bigint] NOT NULL,
	[SellerIdentificationID] [varchar](100) NULL,
	[SchemeID] [varchar](400) NULL,
	[CityName] [varchar](100) NULL,
	[StreetName] [varchar](400) NULL,
	[BuildingNumber] [varchar](400) NULL,
	[CitySubdivisionName] [varchar](400) NULL,
	[PostalZone] [varchar](400) NULL,
	[RegistrationName] [varchar](400) NULL,
	[CompanyID] [varchar](100) NULL,
	[CountryIdentificationCode] [varchar](100) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateOn] [datetime] NOT NULL,
	[UpdateBy] [bigint] NOT NULL,
 CONSTRAINT [PK_InvoiceSeller] PRIMARY KEY CLUSTERED 
(
	[SellerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_OldSellerCSR]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_OldSellerCSR](
	[SellerCSRId] [bigint] IDENTITY(1,1) NOT NULL,
	[SellerId] [bigint] NOT NULL,
	[CSR] [varchar](max) NOT NULL,
	[PrivateKey] [varchar](max) NOT NULL,
	[PubliceKey] [varchar](max) NOT NULL,
	[Secret] [varchar](max) NOT NULL,
	[Mode] [nvarchar](100) NOT NULL,
	[OTP] [nvarchar](100) NOT NULL,
	[InvoiceType] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_SellerCSR] PRIMARY KEY CLUSTERED 
(
	[SellerCSRId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_OldSellerMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_OldSellerMaster](
	[SellerId] [bigint] IDENTITY(1,1) NOT NULL,
	[CommonName] [varchar](500) NOT NULL,
	[SerialNumber] [varchar](500) NOT NULL,
	[OrganizationIdentifier] [varchar](500) NOT NULL,
	[OrganizationUnitName] [varchar](500) NOT NULL,
	[OrganizationName] [varchar](500) NOT NULL,
	[CountryName] [varchar](500) NOT NULL,
	[Location] [varchar](500) NOT NULL,
	[Industry] [varchar](500) NOT NULL,
 CONSTRAINT [PK_SellerMaster] PRIMARY KEY CLUSTERED 
(
	[SellerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_oldtblInvoiceMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_oldtblInvoiceMaster](
	[InvoiceId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentId] [bigint] NULL,
	[IqamaNumber] [nvarchar](200) NULL,
	[InvoiceNumber] [nvarchar](200) NOT NULL,
	[InvoiceTypeId] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[PaymentMethodId] [bigint] NOT NULL,
	[PaymentReferenceNumber] [nvarchar](200) NULL,
	[Status] [bit] NOT NULL,
	[VatNumber] [nvarchar](200) NULL,
	[GpVoucherNumber] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblInvoiceMaster] PRIMARY KEY CLUSTERED 
(
	[InvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FeeTypeDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeeTypeDetail](
	[FeeTypeDetailId] [bigint] IDENTITY(1,1) NOT NULL,
	[AcademicYear] [nvarchar](20) NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[FeeAmount] [decimal](18, 4) NULL,
	[GradeId] [bigint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_FeeTypeDetail] PRIMARY KEY CLUSTERED 
(
	[FeeTypeDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[INV_InvoiceDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INV_InvoiceDetail](
	[InvoiceDetailId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [bigint] NOT NULL,
	[AcademicYear] [nvarchar](200) NOT NULL,
	[InvoiceType] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ItemCode] [nvarchar](200) NULL,
	[StudentId] [nvarchar](200) NULL,
	[Discount] [decimal](18, 2) NULL,
	[Quantity] [decimal](18, 2) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[TaxableAmount] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 2) NULL,
	[TaxAmount] [decimal](18, 2) NULL,
	[ItemSubtotal] [decimal](18, 2) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[ParentId] [nvarchar](200) NULL,
	[StudentName] [nvarchar](200) NULL,
	[ParentName] [nvarchar](200) NULL,
	[GradeId] [int] NULL,
	[NationalityId] [nvarchar](50) NULL,
	[IqamaNumber] [nvarchar](200) NULL,
 CONSTRAINT [PK_INV_InvoiceDetail] PRIMARY KEY CLUSTERED 
(
	[InvoiceDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[INV_InvoicePayment]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INV_InvoicePayment](
	[InvoicePaymentId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [bigint] NOT NULL,
	[PaymentMethod] [nvarchar](200) NOT NULL,
	[PaymentReferenceNumber] [nvarchar](200) NOT NULL,
	[PaymentAmount] [decimal](18, 2) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_INV_InvoicePayment] PRIMARY KEY CLUSTERED 
(
	[InvoicePaymentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[INV_InvoiceSummary]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INV_InvoiceSummary](
	[InvoiceId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [bigint] NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[PublishedBy] [nvarchar](50) NOT NULL,
	[CreditNo] [nvarchar](50) NULL,
	[CreditReason] [nvarchar](500) NULL,
	[CustomerName] [nvarchar](50) NULL,
	[ParentId] [nvarchar](200) NOT NULL,
	[IqamaNumber] [nvarchar](200) NOT NULL,
	[TaxableAmount] [decimal](18, 2) NULL,
	[TaxAmount] [decimal](18, 2) NULL,
	[ItemSubtotal] [decimal](18, 2) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[InvoiceType] [nvarchar](50) NULL,
	[InvoiceRefNo] [bigint] NULL,
 CONSTRAINT [PK_INV_InvoiceSummary] PRIMARY KEY CLUSTERED 
(
	[InvoiceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OpenApplyParents]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OpenApplyParents](
	[Newid] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NOT NULL,
	[first_name] [nvarchar](max) NULL,
	[last_name] [nvarchar](max) NULL,
	[other_name] [nvarchar](max) NULL,
	[preferred_name] [nvarchar](max) NULL,
	[parent_id] [nvarchar](max) NULL,
	[gender] [nvarchar](max) NULL,
	[prefix] [nvarchar](max) NULL,
	[phone] [nvarchar](max) NULL,
	[mobile_phone] [nvarchar](max) NULL,
	[address] [nvarchar](max) NULL,
	[address_ii] [nvarchar](max) NULL,
	[city] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[postal_code] [nvarchar](max) NULL,
	[country] [nvarchar](max) NULL,
	[email] [nvarchar](max) NULL,
	[employer] [nvarchar](max) NULL,
	[birth_date] [nvarchar](max) NULL,
	[work_phone] [nvarchar](max) NULL,
	[nationality] [nvarchar](max) NULL,
	[arabic_title] [nvarchar](max) NULL,
	[home_telephone] [nvarchar](max) NULL,
	[IqamaNo] [nvarchar](max) NULL,
	[student_id] [nvarchar](max) NULL,
	[Passport_id] [nvarchar](max) NULL,
	[p_id_school_parent_id] [nvarchar](max) NULL,
 CONSTRAINT [PK_OpenApplyParents] PRIMARY KEY CLUSTERED 
(
	[Newid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OpenApplyStudents]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OpenApplyStudents](
	[Newid] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NOT NULL,
	[serial_number] [int] NULL,
	[custom_id] [nvarchar](max) NULL,
	[applicant_id] [nvarchar](max) NULL,
	[email] [nvarchar](max) NULL,
	[first_name] [nvarchar](max) NOT NULL,
	[last_name] [nvarchar](max) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[other_name] [nvarchar](max) NULL,
	[preferred_name] [nvarchar](max) NULL,
	[birth_date] [nvarchar](max) NULL,
	[gender] [nvarchar](max) NULL,
	[enrollment_year] [int] NULL,
	[full_address] [nvarchar](max) NULL,
	[address] [nvarchar](max) NULL,
	[address_ii] [nvarchar](max) NULL,
	[city] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[postal_code] [nvarchar](max) NULL,
	[country] [nvarchar](max) NULL,
	[grade] [nvarchar](max) NULL,
	[campus] [nvarchar](max) NULL,
	[campus_id] [int] NULL,
	[status] [nvarchar](max) NULL,
	[status_level] [nvarchar](max) NULL,
	[status_changed_at] [datetime2](7) NULL,
	[managebac_student_id] [nvarchar](max) NULL,
	[mb_id] [nvarchar](max) NULL,
	[applied_at] [datetime2](7) NULL,
	[enrolled_at] [datetime2](7) NULL,
	[inquired_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL,
	[latest_activity_date] [nvarchar](max) NULL,
	[nationality] [nvarchar](max) NULL,
	[student_id] [nvarchar](max) NULL,
	[passport_id] [nvarchar](max) NULL,
	[profile_photo] [nvarchar](max) NULL,
	[profile_photo_updated_at] [datetime2](7) NULL,
	[checklist_state] [nvarchar](max) NULL,
	[inquired_date] [datetime2](7) NULL,
	[applied_date] [datetime2](7) NULL,
	[admitted_date] [datetime2](7) NULL,
	[wait_listed_date] [datetime2](7) NULL,
	[declined_date] [datetime2](7) NULL,
	[enrolled_date] [datetime2](7) NULL,
	[withdrawn_date] [datetime2](7) NULL,
	[graduated_date] [datetime2](7) NULL,
	[representative] [nvarchar](max) NULL,
	[enrollment_date] [datetime2](7) NULL,
	[source_campaign] [nvarchar](max) NULL,
	[contact_date] [datetime2](7) NULL,
	[agent_id] [nvarchar](max) NULL,
	[IqamaNo] [nvarchar](max) NULL,
	[mobile_phone] [nvarchar](max) NULL,
	[PrinceAccount] [bit] NOT NULL,
	[p_id_school_parent_id] [nvarchar](max) NULL,
 CONSTRAINT [PK_OpenApplyStudents] PRIMARY KEY CLUSTERED 
(
	[Newid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblBranchMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBranchMaster](
	[BranchId] [bigint] IDENTITY(1,1) NOT NULL,
	[BranchName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblBranchMaster] PRIMARY KEY CLUSTERED 
(
	[BranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblContactInformation]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblContactInformation](
	[ContactId] [bigint] IDENTITY(1,1) NOT NULL,
	[SchoolId] [bigint] NULL,
	[ContactPerson] [nvarchar](400) NOT NULL,
	[ContactPosition] [nvarchar](200) NOT NULL,
	[ContactTelephone] [nvarchar](20) NOT NULL,
	[ContactEmail] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblContactInformation] PRIMARY KEY CLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCostCenterMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCostCenterMaster](
	[CostCenterId] [bigint] IDENTITY(1,1) NOT NULL,
	[CostCenterName] [nvarchar](200) NULL,
	[Remarks] [nvarchar](400) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblCostCenterMaster] PRIMARY KEY CLUSTERED 
(
	[CostCenterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblCountryMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCountryMaster](
	[CountryId] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](200) NULL,
	[CountryCode] [nvarchar](3) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblCountryMaster] PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDiscountMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDiscountMaster](
	[DiscountId] [bigint] IDENTITY(1,1) NOT NULL,
	[DiscountName] [nvarchar](200) NOT NULL,
	[DiscountPercent] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblDiscountMaster] PRIMARY KEY CLUSTERED 
(
	[DiscountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDiscountRuleMapping]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDiscountRuleMapping](
	[DiscountRuleMapId] [bigint] IDENTITY(1,1) NOT NULL,
	[DiscountRuleId] [int] NOT NULL,
	[DiscountId] [bigint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblDiscountRuleMapping] PRIMARY KEY CLUSTERED 
(
	[DiscountRuleMapId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDiscountRules]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDiscountRules](
	[DiscountRuleId] [int] IDENTITY(1,1) NOT NULL,
	[DiscountRuleDescription] [nvarchar](500) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblDiscountRules] PRIMARY KEY CLUSTERED 
(
	[DiscountRuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblDocumentTypeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDocumentTypeMaster](
	[DocumentTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[DocumentTypeName] [nvarchar](200) NULL,
	[Remarks] [nvarchar](400) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblDocumentTypeMaster] PRIMARY KEY CLUSTERED 
(
	[DocumentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblErrors]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblErrors](
	[ERROR_NUMBER] [int] NULL,
	[ERROR_SEVERITY] [varchar](100) NULL,
	[ERROR_STATE] [varchar](100) NULL,
	[ERROR_PROCEDURE] [varchar](max) NULL,
	[ERROR_LINE] [varchar](max) NULL,
	[ERROR_MESSAGE] [varchar](max) NULL,
	[DATE_TIME] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeGenerate]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeGenerate](
	[FeeGenerateId] [bigint] IDENTITY(1,1) NOT NULL,
	[SchoolAcademicId] [bigint] NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[GenerateStatus] [int] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblFeeGenerate] PRIMARY KEY CLUSTERED 
(
	[FeeGenerateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeGenerateDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeGenerateDetail](
	[FeeGenerateDetailId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeGenerateId] [bigint] NOT NULL,
	[StudentId] [bigint] NOT NULL,
	[SchoolAcademicId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[FeeAmount] [decimal](18, 4) NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblFeeGenerateDetail] PRIMARY KEY CLUSTERED 
(
	[FeeGenerateDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeGradewise]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeGradewise](
	[FeeGradewiseId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[FeeStructureId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[FirstAmount] [decimal](18, 4) NULL,
	[FirstDueDate] [datetime] NULL,
	[SecondAmount] [decimal](18, 4) NULL,
	[SecondDueDate] [datetime] NULL,
	[ThirdAmount] [decimal](18, 4) NULL,
	[ThirdDueDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblFeeGradewise] PRIMARY KEY CLUSTERED 
(
	[FeeGradewiseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeePaymentPlan]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeePaymentPlan](
	[FeePaymentPlanId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeTypeDetailId] [bigint] NOT NULL,
	[PaymentPlanAmount] [decimal](18, 2) NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[IsRejected] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblFeePaymentPlan] PRIMARY KEY CLUSTERED 
(
	[FeePaymentPlanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeStructure]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeStructure](
	[FeeStructureId] [bigint] IDENTITY(1,1) NOT NULL,
	[AcademicYear] [nvarchar](20) NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[IsGradeWise] [bit] NOT NULL,
	[FeeAmount] [decimal](18, 4) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblFeeStructure] PRIMARY KEY CLUSTERED 
(
	[FeeStructureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeTypeDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeTypeDetail](
	[FeeTypeDetailId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[AcademicYearId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[TermFeeAmount] [decimal](18, 4) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[StaffFeeAmount] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblFeeTypeDetail] PRIMARY KEY CLUSTERED 
(
	[FeeTypeDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFeeTypeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeeTypeMaster](
	[FeeTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeTypeName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[IsPaymentPlan] [bit] NOT NULL,
	[IsTermPlan] [bit] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
	[IsPrimary] [bit] NOT NULL,
	[IsGradeWise] [bit] NOT NULL,
 CONSTRAINT [PK_tblFeeTypeMaster] PRIMARY KEY CLUSTERED 
(
	[FeeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGenderTypeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGenderTypeMaster](
	[GenderTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[GenderTypeName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblGenderTypeMaster] PRIMARY KEY CLUSTERED 
(
	[GenderTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGradeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGradeMaster](
	[GradeId] [int] IDENTITY(1,1) NOT NULL,
	[CostCenterId] [bigint] NOT NULL,
	[GenderTypeId] [int] NULL,
	[GradeName] [nvarchar](200) NULL,
	[SequenceNo] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblGradeMaster] PRIMARY KEY CLUSTERED 
(
	[GradeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblInvoiceDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInvoiceDetail](
	[InvoiceDetailID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [nvarchar](50) NULL,
	[InvoiceType] [nvarchar](50) NULL,
	[Description] [nvarchar](150) NULL,
	[Discount] [decimal](18, 2) NULL,
	[Quantity] [decimal](18, 2) NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[StudentId] [nvarchar](50) NULL,
	[TaxableAmount] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 2) NULL,
	[TaxAmount] [decimal](18, 2) NULL,
	[ItemSubtotal] [decimal](18, 2) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[ItemCode] [varchar](255) NULL,
 CONSTRAINT [pk_tblInvoiceDetail] PRIMARY KEY CLUSTERED 
(
	[InvoiceDetailID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblInvoiceSummary]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInvoiceSummary](
	[InvoiceID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [nvarchar](50) NOT NULL,
	[PaymentMethod] [nvarchar](50) NULL,
	[PaymentReferenceNumber] [nvarchar](100) NULL,
	[Status] [nvarchar](10) NULL,
	[ChequeNo] [nvarchar](50) NULL,
	[ParentID] [nvarchar](50) NULL,
	[IqamaNumber] [nvarchar](50) NULL,
	[PublishedBy] [nvarchar](50) NULL,
	[InvoiceDate] [datetime] NULL,
	[CreditNo] [nvarchar](50) NULL,
	[CreditReason] [nvarchar](max) NULL,
	[CustomerName] [nvarchar](100) NULL,
	[ParentName] [nvarchar](100) NULL,
	[EmailID] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](10) NULL,
	[Nationality] [nvarchar](15) NULL,
	[Address] [nvarchar](250) NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [pk_tblInvoiceSummary] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblInvoiceTypeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInvoiceTypeMaster](
	[InvoiceTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceTypeName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[ReceivableAccount] [nvarchar](200) NULL,
	[AdvanceAccount] [nvarchar](200) NULL,
	[ReceivableAccountRemarks] [nvarchar](400) NULL,
	[AdvanceAccountRemarks] [nvarchar](400) NULL,
 CONSTRAINT [PK_tblInvoiceTypeMaster] PRIMARY KEY CLUSTERED 
(
	[InvoiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblMenu]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMenu](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[Menu] [nvarchar](50) NOT NULL,
	[MenuCtrl] [nvarchar](100) NOT NULL,
	[MenuAction] [nvarchar](100) NOT NULL,
	[ParentMenuId] [int] NULL,
	[DisplaySequence] [int] NOT NULL,
	[FaIcon] [nvarchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblMenu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNotification]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNotification](
	[NotificationId] [bigint] IDENTITY(1,1) NOT NULL,
	[RecordId] [nvarchar](200) NOT NULL,
	[RecordStatus] [int] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[RecordType] [nvarchar](200) NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[student_id] [nvarchar](100) NULL,
	[OldValueJson] [nvarchar](max) NULL,
	[NewValueJson] [nvarchar](max) NULL,
 CONSTRAINT [PK_tblNotification] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNotificationGroup]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNotificationGroup](
	[NotificationGroupId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationTypeId] [int] NOT NULL,
	[NotificationCount] [int] NOT NULL,
	[NotificationAction] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_tblNotificationGroup] PRIMARY KEY CLUSTERED 
(
	[NotificationGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNotificationGroupDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNotificationGroupDetail](
	[NotificationGroupDetailId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationGroupId] [int] NOT NULL,
	[NotificationTypeId] [int] NOT NULL,
	[NotificationAction] [nvarchar](200) NOT NULL,
	[TableRecordId] [nvarchar](200) NOT NULL,
	[TableRecordColumnName] [nvarchar](200) NULL,
	[OldValueJson] [nvarchar](max) NOT NULL,
	[NewValueJson] [nvarchar](max) NOT NULL,
	[CreatedBy] [int] NOT NULL,
 CONSTRAINT [PK_tblNotificationGroupDetail] PRIMARY KEY CLUSTERED 
(
	[NotificationGroupDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblNotificationTypeMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNotificationTypeMaster](
	[NotificationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationType] [nvarchar](100) NOT NULL,
	[ActionTable] [nvarchar](200) NOT NULL,
	[NotificationMsg] [nvarchar](500) NOT NULL,
	[NotificationActionTable] [nvarchar](500) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_tblNotificationTypeMaster] PRIMARY KEY CLUSTERED 
(
	[NotificationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOldUniformDetails]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOldUniformDetails](
	[UniformDetailID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceNo] [nvarchar](50) NULL,
	[Description] [nvarchar](150) NULL,
	[Grade] [nvarchar](50) NULL,
	[Color] [nvarchar](10) NULL,
	[Size] [nvarchar](10) NULL,
	[Quantity] [nvarchar](10) NULL,
	[UnitPrice] [nvarchar](10) NULL,
	[TaxableAmount] [nvarchar](10) NULL,
	[Discount] [nvarchar](10) NULL,
	[TaxRate] [nvarchar](10) NULL,
	[TaxAmount] [nvarchar](10) NULL,
	[ItemSubtotal] [nvarchar](10) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[UpdatedOn] [datetime] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
 CONSTRAINT [pk_tblUniformDetails] PRIMARY KEY CLUSTERED 
(
	[UniformDetailID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblOpenApplyMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOpenApplyMaster](
	[OpenApplyId] [bigint] IDENTITY(1,1) NOT NULL,
	[GrantType] [nvarchar](200) NULL,
	[ClientId] [nvarchar](200) NULL,
	[ClientSecret] [nvarchar](400) NULL,
	[Audience] [nvarchar](200) NULL,
	[OpenApplyJobPath] [nvarchar](200) NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblOpenApplyMaster] PRIMARY KEY CLUSTERED 
(
	[OpenApplyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblParent]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblParent](
	[ParentId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentCode] [nvarchar](50) NOT NULL,
	[ParentImage] [nvarchar](500) NULL,
	[FatherName] [nvarchar](200) NOT NULL,
	[FatherArabicName] [nvarchar](200) NULL,
	[FatherNationalityId] [int] NOT NULL,
	[FatherMobile] [nvarchar](50) NULL,
	[FatherEmail] [nvarchar](200) NOT NULL,
	[IsFatherStaff] [bit] NOT NULL,
	[MotherName] [nvarchar](200) NOT NULL,
	[MotherArabicName] [nvarchar](200) NULL,
	[MotherNationalityId] [int] NOT NULL,
	[MotherMobile] [nvarchar](50) NULL,
	[MotherEmail] [nvarchar](200) NULL,
	[IsMotherStaff] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[FatherIqamaNo] [nvarchar](50) NULL,
	[MotherIqamaNo] [nvarchar](50) NULL,
	[OpenApplyFatherId] [bigint] NULL,
	[OpenApplyMotherId] [bigint] NULL,
	[OpenApplyStudentId] [bigint] NULL,
 CONSTRAINT [PK_tblParent] PRIMARY KEY CLUSTERED 
(
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblParentAccount]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblParentAccount](
	[ParentAccountId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentId] [bigint] NOT NULL,
	[ReceivableAccount] [nvarchar](200) NULL,
	[AdvanceAccount] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblParentAccount] PRIMARY KEY CLUSTERED 
(
	[ParentAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRole]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRole](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblRole] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblRoleMenuMapping]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRoleMenuMapping](
	[RoleMenuMappingId] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NOT NULL,
	[MenuId] [int] NOT NULL,
	[AllowAdd] [bit] NOT NULL,
	[AllowEdit] [bit] NOT NULL,
	[AllowDelete] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblRoleMenuMapping] PRIMARY KEY CLUSTERED 
(
	[RoleMenuMappingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSchoolAcademic]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSchoolAcademic](
	[SchoolAcademicId] [int] IDENTITY(1,1) NOT NULL,
	[SchoolId] [bigint] NULL,
	[AcademicYear] [nvarchar](200) NOT NULL,
	[PeriodFrom] [datetime] NOT NULL,
	[PeriodTo] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblSchoolAcademic] PRIMARY KEY CLUSTERED 
(
	[SchoolAcademicId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSchoolAccountInfo]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSchoolAccountInfo](
	[SchoolAccountIId] [int] IDENTITY(1,1) NOT NULL,
	[SchoolId] [bigint] NULL,
	[CodeDescription] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[ReceivableAccount] [nvarchar](400) NULL,
	[AdvanceAccount] [nvarchar](400) NULL,
 CONSTRAINT [PK_tblSchoolAccountInfo] PRIMARY KEY CLUSTERED 
(
	[SchoolAccountIId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSchoolLogo]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSchoolLogo](
	[SchoolLogoId] [int] IDENTITY(1,1) NOT NULL,
	[SchoolId] [bigint] NOT NULL,
	[LogoName] [nvarchar](200) NOT NULL,
	[LogoPath] [nvarchar](800) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblSchoolLogo] PRIMARY KEY CLUSTERED 
(
	[SchoolLogoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSchoolMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSchoolMaster](
	[SchoolId] [bigint] IDENTITY(1,1) NOT NULL,
	[SchoolNameEnglish] [nvarchar](400) NULL,
	[SchoolNameArabic] [nvarchar](400) NULL,
	[BranchId] [bigint] NOT NULL,
	[CountryId] [bigint] NULL,
	[City] [nvarchar](200) NULL,
	[Address] [nvarchar](400) NULL,
	[Telephone] [nvarchar](200) NULL,
	[SchoolEmail] [nvarchar](200) NULL,
	[WebsiteUrl] [nvarchar](400) NULL,
	[VatNo] [nvarchar](200) NULL,
	[Logo] [nvarchar](400) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblSchoolMaster] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSchoolTermAcademic]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSchoolTermAcademic](
	[SchoolTermAcademicId] [int] IDENTITY(1,1) NOT NULL,
	[SchoolAcademicId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[IsRejected] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[TermName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tblSchoolTermAcademic] PRIMARY KEY CLUSTERED 
(
	[SchoolTermAcademicId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblSection]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSection](
	[SectionId] [bigint] IDENTITY(1,1) NOT NULL,
	[SectionName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblSection] PRIMARY KEY CLUSTERED 
(
	[SectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStudent]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStudent](
	[StudentId] [bigint] IDENTITY(1,1) NOT NULL,
	[StudentCode] [nvarchar](50) NOT NULL,
	[StudentImage] [nvarchar](500) NULL,
	[ParentId] [bigint] NULL,
	[StudentName] [nvarchar](200) NOT NULL,
	[StudentArabicName] [nvarchar](200) NULL,
	[StudentEmail] [nvarchar](200) NOT NULL,
	[DOB] [datetime] NOT NULL,
	[IqamaNo] [nvarchar](100) NOT NULL,
	[NationalityId] [int] NOT NULL,
	[GenderId] [int] NOT NULL,
	[AdmissionDate] [datetime] NOT NULL,
	[GradeId] [int] NOT NULL,
	[CostCenterId] [bigint] NOT NULL,
	[SectionId] [bigint] NOT NULL,
	[PassportNo] [nvarchar](50) NULL,
	[PassportExpiry] [datetime] NULL,
	[Mobile] [nvarchar](20) NULL,
	[StudentAddress] [nvarchar](400) NOT NULL,
	[StudentStatusId] [int] NOT NULL,
	[WithdrawDate] [datetime] NULL,
	[WithdrawAt] [int] NULL,
	[WithdrawYear] [nvarchar](20) NULL,
	[Fees] [decimal](12, 2) NULL,
	[IsGPIntegration] [bit] NOT NULL,
	[TermId] [int] NOT NULL,
	[AdmissionYear] [nvarchar](20) NULL,
	[PrinceAccount] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[p_id_school_parent_id] [nvarchar](100) NULL,
 CONSTRAINT [pk_tblStudent] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStudentFeeDetail]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStudentFeeDetail](
	[StudentFeeDetailId] [bigint] IDENTITY(1,1) NOT NULL,
	[StudentId] [bigint] NOT NULL,
	[AcademicYearId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[FeeTypeId] [bigint] NOT NULL,
	[FeeAmount] [decimal](18, 4) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblStudentFeeDetail] PRIMARY KEY CLUSTERED 
(
	[StudentFeeDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblStudentStatus]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblStudentStatus](
	[StudentStatusId] [bigint] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblStudentStatus] PRIMARY KEY CLUSTERED 
(
	[StudentStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTermMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTermMaster](
	[TermId] [int] IDENTITY(1,1) NOT NULL,
	[TermName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblTermMaster] PRIMARY KEY CLUSTERED 
(
	[TermId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUploadDocument]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUploadDocument](
	[UploadedDocId] [bigint] IDENTITY(1,1) NOT NULL,
	[DocFor] [int] NOT NULL,
	[DocType] [bigint] NOT NULL,
	[DocForId] [bigint] NOT NULL,
	[DocNo] [nvarchar](20) NOT NULL,
	[DocPath] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblUploadDocument] PRIMARY KEY CLUSTERED 
(
	[UploadedDocId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblUser]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUser](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](200) NOT NULL,
	[UserArabicName] [nvarchar](500) NULL,
	[UserEmail] [nvarchar](200) NOT NULL,
	[UserPhone] [nvarchar](20) NULL,
	[UserPass] [nvarchar](500) NOT NULL,
	[ProfileImg] [nvarchar](500) NULL,
	[RoleId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblUser] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblVatCountryExclusionMap]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVatCountryExclusionMap](
	[VatCountryMapId] [bigint] IDENTITY(1,1) NOT NULL,
	[VatId] [bigint] NOT NULL,
	[CountryId] [bigint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblVatCountryExclusionMap] PRIMARY KEY CLUSTERED 
(
	[VatCountryMapId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblVatMaster]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVatMaster](
	[VatId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeTypeId] [int] NOT NULL,
	[VatTaxPercent] [decimal](18, 2) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	[DebitAccount] [nvarchar](200) NULL,
	[CreditAccount] [nvarchar](200) NULL,
 CONSTRAINT [PK_tblVatMaster] PRIMARY KEY CLUSTERED 
(
	[VatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Temp_GL]    Script Date: 6/22/2024 4:22:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_GL](
	[BACHNUMB] [nvarchar](30) NULL,
	[JRNENTRY] [int] NULL,
	[TRXDATE] [datetime] NULL,
	[REFRENCE] [nvarchar](62) NULL,
	[ACTNUMST] [nvarchar](258) NULL,
	[ACTINDX] [int] NULL,
	[DSCRIPTN] [nvarchar](62) NULL,
	[DEBITAMT] [decimal](19, 5) NULL,
	[CRDTAMNT] [decimal](19, 5) NULL,
	[SQNCLINE] [decimal](19, 5) NULL,
	[ACCTTYPE] [int] NULL,
	[USERID] [nvarchar](30) NULL,
	[RowId] [int] NOT NULL,
	[ARDSCJVD] [nvarchar](1000) NULL,
	[InterID] [nvarchar](10) NULL,
	[DTA_GroupID] [char](1) NULL,
	[DTA_CodeID] [char](1) NULL,
	[ICTRX] [int] NULL,
	[PostingDesc] [char](1) NULL,
	[FUNLCURR_T] [char](1) NULL,
	[FUNCRIDX_T] [bigint] NULL,
	[XCHGRATE] [decimal](18, 7) NULL,
	[EXGTBLID] [nvarchar](30) NULL,
	[EXCHDATE] [datetime] NULL,
	[RATETPID] [nvarchar](30) NULL,
	[CorrespondingUnit] [nvarchar](30) NULL,
	[ORDEBITAMT] [decimal](18, 7) NULL,
	[ORCRDTAMNT] [decimal](18, 7) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrors] ADD  CONSTRAINT [DF_tblErrors_DATE_TIME]  DEFAULT (getdate()) FOR [DATE_TIME]
GO
ALTER TABLE [dbo].[tblContactInformation]  WITH CHECK ADD  CONSTRAINT [FK_tblContactInformation_tblSchoolMaster] FOREIGN KEY([SchoolId])
REFERENCES [dbo].[tblSchoolMaster] ([SchoolId])
GO
ALTER TABLE [dbo].[tblContactInformation] CHECK CONSTRAINT [FK_tblContactInformation_tblSchoolMaster]
GO
ALTER TABLE [dbo].[tblGradeMaster]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGradeMaster_tblCostCenterMaster] FOREIGN KEY([CostCenterId])
REFERENCES [dbo].[tblCostCenterMaster] ([CostCenterId])
GO
ALTER TABLE [dbo].[tblGradeMaster] NOCHECK CONSTRAINT [FK_tblGradeMaster_tblCostCenterMaster]
GO
ALTER TABLE [dbo].[tblSchoolAcademic]  WITH CHECK ADD  CONSTRAINT [FK_tblSchoolAcademic_tblSchoolMaster] FOREIGN KEY([SchoolId])
REFERENCES [dbo].[tblSchoolMaster] ([SchoolId])
GO
ALTER TABLE [dbo].[tblSchoolAcademic] CHECK CONSTRAINT [FK_tblSchoolAcademic_tblSchoolMaster]
GO
ALTER TABLE [dbo].[tblSchoolAccountInfo]  WITH NOCHECK ADD  CONSTRAINT [FK_tblSchoolAccountInfo_tblSchoolMaster] FOREIGN KEY([SchoolId])
REFERENCES [dbo].[tblSchoolMaster] ([SchoolId])
GO
ALTER TABLE [dbo].[tblSchoolAccountInfo] CHECK CONSTRAINT [FK_tblSchoolAccountInfo_tblSchoolMaster]
GO
ALTER TABLE [dbo].[tblSchoolLogo]  WITH CHECK ADD  CONSTRAINT [FK_tblSchoolLogo_tblSchoolMaster] FOREIGN KEY([SchoolId])
REFERENCES [dbo].[tblSchoolMaster] ([SchoolId])
GO
ALTER TABLE [dbo].[tblSchoolLogo] CHECK CONSTRAINT [FK_tblSchoolLogo_tblSchoolMaster]
GO
ALTER TABLE [dbo].[tblSchoolMaster]  WITH CHECK ADD  CONSTRAINT [FK_tblSchoolMaster_tblBranchMaster] FOREIGN KEY([BranchId])
REFERENCES [dbo].[tblBranchMaster] ([BranchId])
GO
ALTER TABLE [dbo].[tblSchoolMaster] CHECK CONSTRAINT [FK_tblSchoolMaster_tblBranchMaster]
GO
ALTER TABLE [dbo].[tblSchoolTermAcademic]  WITH CHECK ADD  CONSTRAINT [FK_tblSchoolTermAcademic_tblSchoolAcademic] FOREIGN KEY([SchoolAcademicId])
REFERENCES [dbo].[tblSchoolAcademic] ([SchoolAcademicId])
GO
ALTER TABLE [dbo].[tblSchoolTermAcademic] CHECK CONSTRAINT [FK_tblSchoolTermAcademic_tblSchoolAcademic]
GO
ALTER TABLE [dbo].[tblStudent]  WITH CHECK ADD  CONSTRAINT [FK_tblStudent_tblCostCenterMaster] FOREIGN KEY([CostCenterId])
REFERENCES [dbo].[tblCostCenterMaster] ([CostCenterId])
GO
ALTER TABLE [dbo].[tblStudent] CHECK CONSTRAINT [FK_tblStudent_tblCostCenterMaster]
GO
ALTER TABLE [dbo].[tblStudent]  WITH CHECK ADD  CONSTRAINT [FK_tblStudent_tblGrade] FOREIGN KEY([GradeId])
REFERENCES [dbo].[tblGradeMaster] ([GradeId])
GO
ALTER TABLE [dbo].[tblStudent] CHECK CONSTRAINT [FK_tblStudent_tblGrade]
GO
ALTER TABLE [dbo].[tblStudent]  WITH CHECK ADD  CONSTRAINT [FK_tblStudent_tblParent] FOREIGN KEY([ParentId])
REFERENCES [dbo].[tblParent] ([ParentId])
GO
ALTER TABLE [dbo].[tblStudent] CHECK CONSTRAINT [FK_tblStudent_tblParent]
GO
ALTER TABLE [dbo].[tblStudent]  WITH CHECK ADD  CONSTRAINT [FK_tblStudent_tblSection] FOREIGN KEY([SectionId])
REFERENCES [dbo].[tblSection] ([SectionId])
GO
ALTER TABLE [dbo].[tblStudent] CHECK CONSTRAINT [FK_tblStudent_tblSection]
GO
ALTER TABLE [dbo].[tblStudent]  WITH CHECK ADD  CONSTRAINT [FK_tblStudent_tblTermMaster] FOREIGN KEY([TermId])
REFERENCES [dbo].[tblTermMaster] ([TermId])
GO
ALTER TABLE [dbo].[tblStudent] CHECK CONSTRAINT [FK_tblStudent_tblTermMaster]
GO
ALTER TABLE [dbo].[tblUploadDocument]  WITH CHECK ADD  CONSTRAINT [FK_tblUploadDocument_tblDocumentTypeMaster1] FOREIGN KEY([DocType])
REFERENCES [dbo].[tblDocumentTypeMaster] ([DocumentTypeId])
GO
ALTER TABLE [dbo].[tblUploadDocument] CHECK CONSTRAINT [FK_tblUploadDocument_tblDocumentTypeMaster1]
GO
EXEC sys.sp_addextendedproperty @name=N'seq', @value=7 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrors'
GO
EXEC sys.sp_addextendedproperty @name=N'tabletype', @value=N'Trans' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrors'
GO
