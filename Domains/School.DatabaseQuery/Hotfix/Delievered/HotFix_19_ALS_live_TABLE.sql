
ALTER TABLE [dbo].[tblStudentOtherDiscountDetail] ADD 
[DiscountStatus] [int] NOT NULL CONSTRAINT [DF_tblStudentOtherDiscountDetail_DiscountStatus] DEFAULT ((3))
GO
ALTER TABLE [dbo].[tblStudentSiblingDiscountDetail] ADD 
[DiscountStatus] [int] NOT NULL CONSTRAINT [DF_tblStudentSiblingDiscountDetail_DiscountStatus] DEFAULT ((3))
GO
ALTER TABLE [dbo].[INV_InvoiceDetail] ADD 
[StudentCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsAdvance] [bit] NULL
GO
ALTER TABLE [dbo].[INV_InvoicePayment] ADD 
[PaymentMethodId] [bigint] NULL
GO
ALTER TABLE [dbo].[INT_SalesPaymentSourceTable] ADD 
[CheckbookID] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO

CREATE TABLE [dbo].[INT_SalesDistributionSourceTable]
(
	[SeqNum] [int] NOT NULL,
	[SOPNumber] [char] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SOPType] [smallint] NOT NULL,
	[DistType] [smallint] NOT NULL,
	[AccountNumber] [char] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DebitAmount] [numeric] (19,5) NOT NULL,
	[CreditAmount] [numeric] (19,5) NOT NULL,
	[DistributionRef] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IntegrationStatus] [smallint] NOT NULL,
	[Error] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT [PK_INT_SalesDistributionSourceTable] PRIMARY KEY CLUSTERED
	(
		[SeqNum] ASC,
		[SOPNumber] ASC,
		[SOPType] ASC
	) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY  = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

