--als live DB script
	INSERT [dbo].[tblEmailConfig] ([Host], [Port], [Username], [Password], [EnableSSL], [FromEmail], [IsDeleted], [UpdateDate], 
[UpdateBy]) VALUES ( N'smtp.gmail.com', 465, N'alsfinance@alsschools.com', N'Als12345', 1, N'shashwatmishra803@hotmail.com', 0, CAST(N'2024-07-24T00:30:42.760' AS DateTime), 1)

	ALTER TABLE [INV_InvoiceSummary] ADD CONSTRAINT pk_INV_InvoiceSummary PRIMARY KEY ([InvoiceId])
	ALTER TABLE INV_InvoiceDetail ADD CONSTRAINT pk_INV_InvoiceDetail PRIMARY KEY ([InvoiceDetailId])
	ALTER TABLE [INV_InvoicePayment] ADD CONSTRAINT pk_INV_InvoicePayment PRIMARY KEY ([InvoicePaymentId])
GO

declare @GradeId int=0
select top 1 @GradeId =GradeId  from tblGradeMaster where GradeName='KG 2'
if(@GradeId>0)
begin
	update stu
	set stu.GradeId=@GradeId
	from tblStudent stu
	join OpenApplyStudents  opn
	on stu.StudentCode=opn.custom_id
	where opn.grade='kg2'
end
Go