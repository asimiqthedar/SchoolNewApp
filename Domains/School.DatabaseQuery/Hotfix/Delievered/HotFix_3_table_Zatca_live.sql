
--Zatca live DB script
	ALTER TABLE [ZATCAInvoiceLive].[dbo].UniformDetails DROP CONSTRAINT pk_UniformDetails_id
	ALTER TABLE [ZATCAInvoiceLive].[dbo].UniformDetails ADD CONSTRAINT pk_UniformDetails_id PRIMARY KEY ([UniformDetailID])
	alter table [ZATCAInvoiceLive].[dbo].[InvoiceSummary] add IqamaNumber nvarchar(50) null
	alter table [ZATCAInvoiceLive].[dbo].[InvoiceSummary] alter column [Nationality] nvarchar(100) null
	