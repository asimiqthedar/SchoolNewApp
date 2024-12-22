
CREATE TABLE [dbo].[tblFeeStatement](
	[FeeStatementId] [bigint] IDENTITY(1,1) NOT NULL,
	[FeeStatementType] [nvarchar](200) NOT NULL, --Tuition/DiscountApply/DiscountRefund/TuitionFeePayment/TuitionFeePaymentRefund
	
	[InvoiceNo] [bigint]  NULL,	
	[InvoiceDate] [datetime]  NULL,
	
	[PaymentMethod] [nvarchar](200)  NULL, 
	[FeeType] [nvarchar](200)  NULL, 
	[FeeAmount] [decimal](18, 2) NOT NULL,
	[PaidAmount] [decimal](18, 2) NOT NULL,

	[StudentId] [bigint] NOT NULL,
	[ParentId] [bigint] NOT NULL,
	[StudentName] [nvarchar](200) NULL,
	[ParentName] [nvarchar](200) NULL,

	[AcademicYearId] [bigint] NOT NULL,
	[GradeId] [int] NULL,

	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
	
 CONSTRAINT [PK_tblFeeStatement] PRIMARY KEY CLUSTERED 
(
	[FeeStatementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


