USE [tempdb]
GO

/****** Object:  Table [dbo].[DEX_LOCK]    Script Date: 02/09/2024 9:29:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DEX_LOCK](
	[session_id] [int] NOT NULL,
	[row_id] [int] NOT NULL,
	[table_path_name] [char](100) NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DEX_SESSION]    Script Date: 02/09/2024 9:29:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DEX_SESSION](
	[session_id] [int] IDENTITY(1,1) NOT NULL,
	[sqlsvr_spid] [smallint] NOT NULL
) ON [PRIMARY]
GO