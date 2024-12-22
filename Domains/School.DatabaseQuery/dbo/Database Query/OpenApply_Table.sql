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
 CONSTRAINT [PK_OpenApplyStudents] PRIMARY KEY CLUSTERED 
(
	[Newid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[OpenApplyParents](
	[Newid] [int] IDENTITY(1,1) NOT NULL,
	[id] [int] NOT NULL,
	[student_id] [nvarchar](max) NOT NULL,
	[city] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[email] [nvarchar](max) NULL,
	[mb_id] [int] NULL,
	[state] [nvarchar](max) NULL,
	[gender] [nvarchar](max) NULL,
	[address] [nvarchar](max) NULL,
	[country] [nvarchar](max) NULL,
	[custom_id] [nvarchar](max) NULL,
	[last_name] [nvarchar](max) NULL,
	[parent_id] [nvarchar](max) NULL,
	[address_ii] [nvarchar](max) NULL,
	[first_name] [nvarchar](max) NULL,
	[updated_at] [datetime2](7) NULL,
	[parent_role] [nvarchar](max) NULL,
	[postal_code] [nvarchar](max) NULL,
	[profile_photo] [nvarchar](max) NULL,
	[serial_number] [int] NULL,
	[preferred_name] [nvarchar](max) NULL,
	[managebac_parent_id] [int] NULL,
	[profile_photo_updated_at] [nvarchar](max) NULL,
 CONSTRAINT [PK_OpenApplyParents] PRIMARY KEY CLUSTERED 
(
	[Newid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tblNotification](
	[NotificationId] [bigint] IDENTITY(1,1) NOT NULL,
	[RecordId] [nvarchar](200) NOT NULL,
	[RecordStatus] [int] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[RecordType] [nvarchar](200) NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateBy] [int] NOT NULL,
 CONSTRAINT [PK_tblNotification] PRIMARY KEY CLUSTERED 
(
	[NotificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
