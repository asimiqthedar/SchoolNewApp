ALTER TABLE [dbo].[tblSiblingDiscountDetail] ADD 
[IsActive] [bit] NULL CONSTRAINT [DF__tblSiblin__IsAct__1B13F4C6] DEFAULT ((1)),
[IsDeleted] [bit] NULL CONSTRAINT [DF__tblSiblin__IsDel__1C0818FF] DEFAULT ((0))
GO
CREATE TABLE [dbo].[tblFeeStatement]
(
	[FeeStatementId] [bigint] IDENTITY (1,1) NOT NULL,
	[FeeStatementType] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[InvoiceNo] [bigint] NULL,
	[InvoiceDate] [datetime] NULL,
	[PaymentMethod] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FeeType] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FeeAmount] [decimal] (18,2) NOT NULL,
	[PaidAmount] [decimal] (18,2) NOT NULL,
	[StudentId] [bigint] NOT NULL,
	[ParentId] [bigint] NOT NULL,
	[StudentName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AcademicYearId] [bigint] NOT NULL,
	[GradeId] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tblStudentOtherDiscountDetail]
(
	[StudentOtherDiscountDetailId] [bigint] IDENTITY (1,1) NOT NULL,
	[StudentId] [bigint] NOT NULL,
	[AcademicYearId] [bigint] NOT NULL,
	[GradeId] [bigint] NOT NULL,
	[FeeTypeId] [bigint] NULL,
	[DiscountName] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountAmount] [decimal] (18,4) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL
) ON [PRIMARY]
GO