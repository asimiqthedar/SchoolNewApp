IF OBJECT_ID(N'[tblCostCenterMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblCostCenterMaster] 
GO
CREATE TABLE [dbo].[tblCostCenterMaster](
	[CostCenterId] [bigint] IDENTITY(1,1) NOT NULL,
	[CostCenterName] [nvarchar](200) NULL,
	[Remarks] [nvarchar](400) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblCostCenterMaster] PRIMARY KEY CLUSTERED 
(
	[CostCenterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblCountryMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblCountryMaster] 
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
IF OBJECT_ID(N'[tblDocumentTypeMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblDocumentTypeMaster] 
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
IF OBJECT_ID(N'[tblErrors]', N'U') IS NOT NULL  
   DROP TABLE [tblErrors] 
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
IF OBJECT_ID(N'[tblGenderTypeMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblGenderTypeMaster] 
GO
CREATE TABLE [dbo].[tblGenderTypeMaster](
	[GenderTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[GenderTypeName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblGenderTypeMaster] PRIMARY KEY CLUSTERED 
(
	[GenderTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblGradeMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblGradeMaster] 
GO
CREATE TABLE [dbo].[tblGradeMaster](
	[GradeId] [bigint] IDENTITY(1,1) NOT NULL,
	[CostCenterId] [bigint] NOT NULL,
	[GenderTypeId] [int] NULL,
	[GradeName] [nvarchar](200) NULL,
	[SequenceNo] [int] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblGradeMaster] PRIMARY KEY CLUSTERED 
(
	[GradeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblGradeSection]', N'U') IS NOT NULL  
   DROP TABLE [tblGradeSection] 
GO
CREATE TABLE [dbo].[tblGradeSection](
	[GradeSectionId] [bigint] IDENTITY(1,1) NOT NULL,
	[CostCenterId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[SectionName] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblGradeSection] PRIMARY KEY CLUSTERED 
(
	[GradeSectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblInvoiceTypeMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblInvoiceTypeMaster] 
GO
CREATE TABLE [dbo].[tblInvoiceTypeMaster](
	[InvoiceTypeId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceTypeName] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblInvoiceTypeMaster] PRIMARY KEY CLUSTERED 
(
	[InvoiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblMenu]', N'U') IS NOT NULL  
   DROP TABLE [tblMenu] 
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
IF OBJECT_ID(N'[tblParent]', N'U') IS NOT NULL  
   DROP TABLE [tblParent] 
GO
CREATE TABLE [dbo].[tblParent](
	[ParentId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentCode] [nvarchar](50) NOT NULL,
	[ParentImage] [nvarchar](500) NULL,
	[FatherName] [nvarchar](200) NOT NULL,
	[FatherArabicName] [nvarchar](200) NULL,
	[FatherNationalityId] [int] NOT NULL,
	[FatherMobile] [nvarchar](20) NOT NULL,
	[FatherEmail] [nvarchar](200) NOT NULL,
	[IsFatherStaff] [bit] NOT NULL,
	[MotherName] [nvarchar](200) NOT NULL,
	[MotherArabicName] [nvarchar](200) NULL,
	[MotherNationalityId] [int] NOT NULL,
	[MotherMobile] [nvarchar](20) NULL,
	[MotherEmail] [nvarchar](200) NULL,
	[IsMotherStaff] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblParent] PRIMARY KEY CLUSTERED 
(
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
IF OBJECT_ID(N'[tblRole]', N'U') IS NOT NULL  
   DROP TABLE [tblRole] 
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
IF OBJECT_ID(N'[tblRoleMenuMapping]', N'U') IS NOT NULL  
   DROP TABLE [tblRoleMenuMapping] 
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
IF OBJECT_ID(N'[tblStudentStatus]', N'U') IS NOT NULL  
   DROP TABLE [tblStudentStatus] 
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
IF OBJECT_ID(N'[tblUser]', N'U') IS NOT NULL  
   DROP TABLE [tblUser] 
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
IF OBJECT_ID(N'[tblVatCountryExclusionMap]', N'U') IS NOT NULL  
   DROP TABLE [tblVatCountryExclusionMap] 
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
IF OBJECT_ID(N'[tblVatMaster]', N'U') IS NOT NULL  
   DROP TABLE [tblVatMaster] 
GO
CREATE TABLE [dbo].[tblVatMaster](
	[VatId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvoiceTypeId] [bigint] NOT NULL,
	[VatPercent] [decimal](18, 2) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblVatMaster] PRIMARY KEY CLUSTERED 
(
	[VatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrors] ADD  CONSTRAINT [DF_tblErrors_DATE_TIME]  DEFAULT (getdate()) FOR [DATE_TIME]
GO
EXEC sys.sp_addextendedproperty @name=N'seq', @value=7 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrors'
GO
EXEC sys.sp_addextendedproperty @name=N'tabletype', @value=N'Trans' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblErrors'
GO
