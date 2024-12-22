CREATE TABLE [dbo].[OpenApplyStudentParentMap](
	[StudentParentMapid] [int] IDENTITY(1,1) NOT NULL,
	[OpenApplyStudentId] [int] NOT NULL,
	[OpenApplyParentId] [int] NOT NULL,
	[PrincePrefix] [nvarchar](50) NULL,
 CONSTRAINT [PK_OpenApplyStudentParentMap] PRIMARY KEY CLUSTERED 
(
	[StudentParentMapid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
