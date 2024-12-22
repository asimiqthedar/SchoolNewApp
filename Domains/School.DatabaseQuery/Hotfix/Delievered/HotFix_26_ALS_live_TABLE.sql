
CREATE TABLE [dbo].[tblParentOpenApplyProcessed](
	[ProcessId] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentId] [bigint]NOT NULL, 
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
 CONSTRAINT [PK_tblParentOpenApplyProcessed] PRIMARY KEY CLUSTERED 
(
	[ProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[tblStudentOpenApplyProcessed](
	[ProcessId] [bigint] IDENTITY(1,1) NOT NULL,
	[StudentId] [bigint] NOT NULL,
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
 CONSTRAINT [PK_tblStudentOpenApplyProcessed] PRIMARY KEY CLUSTERED 
(
	[ProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


delete from tblNotificationTypeMaster where NotificationType in (
'OpenApplyRecordProcessing',
'OpenApplyRecordProcessing',
'Student',
'Parent')
GO

INSERT [dbo].[tblNotificationTypeMaster] ([NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES ( N'Student', N'tblStudent', N'Student #N record #Action', 1, N'NotificationOpenApplyStudent')
GO
INSERT [dbo].[tblNotificationTypeMaster] ([NotificationType], [ActionTable], [NotificationMsg], [IsActive], [NotificationActionTable]) VALUES ( N'Parent', N'tblParent', N'Parent #N record #Action', 1, N'NotificationOpenApplyParent')
GO

