
insert into tblStudentStatus(StatusName	,IsActive,	IsDeleted,	UpdateDate,	UpdateBy)
select StatusName='Hold'	,IsActive=1,	IsDeleted=0,	UpdateDate=getdate(),	UpdateBy=1
GO
