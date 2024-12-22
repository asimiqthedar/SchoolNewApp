drop view if exists vw_InvoiceParentInfo
GO

CREATE view  vw_InvoiceParentInfo
as
select * from 
(
	select distinct
		ROW_NUMBER() over(partition by InvoiceNo order by InvoiceNo) as RN
		,
		  InvoiceNo,InvoiceType
		,ParentId=isnull(ind.ParentId,0)
		,ParentName=isnull(isnull(ind.ParentName,p.FatherName),'')
		,ParentCode=isnull(isnull(ind.ParentCode,p.ParentCode),'')
		,FatherMobile=isnull(isnull(ind.FatherMobile,p.FatherMobile),'')
		,NationalityId=isnull(isnull(NationalityId,0) ,0)
		,CountryName=isnull(cm.CountryName,'')
	from INV_InvoiceDetail ind
	left join tblParent p on ind.ParentId=p.ParentId 
	left join tblCountryMaster cm on isnull(isnull(NationalityId,0) ,0)=cm.CountryId
)t
where t.RN=1
Go
