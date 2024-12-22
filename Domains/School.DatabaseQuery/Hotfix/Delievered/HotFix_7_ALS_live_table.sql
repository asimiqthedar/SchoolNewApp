update tblEmailConfig
set Port=587
GO

alter table UniformDetails drop column Id
GO

alter table ZATCAInvoiceLive.dbo.InvoiceSummary  alter column [MobileNo] nvarchar(50) null