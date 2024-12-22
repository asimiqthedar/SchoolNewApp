CREATE TABLE [dbo].[Transactions](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionType] [nvarchar](100) NULL,
	[TransactionNo] [int] NULL,
 CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET IDENTITY_INSERT [dbo].[Transactions] ON 
GO
INSERT [dbo].[Transactions] ([TransactionID], [TransactionType], [TransactionNo]) VALUES (1, N'Invoice No', 6677)
GO
INSERT [dbo].[Transactions] ([TransactionID], [TransactionType], [TransactionNo]) VALUES (2, N'Vendor No', 1)
GO
INSERT [dbo].[Transactions] ([TransactionID], [TransactionType], [TransactionNo]) VALUES (3, N'Delete Password', 999)
GO
SET IDENTITY_INSERT [dbo].[Transactions] OFF
GO

