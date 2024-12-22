DROP view IF EXISTS vw_ParentStudent
GO
create view vw_ParentStudent
as

select
stu.StudentId
,stu.StudentCode	,stu.StudentName	,stu.StudentEmail	,stu.DOB	,stu.IqamaNo,stu.GradeId	,stu.CostCenterId
,par.ParentId
,par.ParentCode	,par.FatherName	,par.FatherNationalityId	,par.FatherMobile	,par.FatherEmail
,par.FatherIqamaNo	,par.MotherIqamaNo
,cm.CountryName

from tblStudent stu   
JOIN tblParent par ON stu.ParentId=par.ParentId  
join tblCountryMaster cm on par.FatherNationalityId=cm.CountryId
GO

DROP view IF EXISTS vw_FeeStatementParenStudent
GO
create view vw_FeeStatementParenStudent
as
SELECT
par.ParentCode  
,par.FatherName  
,par.MotherName
,par.FatherMobile  
,par.FatherEmail
,par.ParentId	
,stu.StudentCode
,stu.StudentName

,CostCenter=cc.CostCenterName   
,Grade=gm.GradeName  
,Gender=gtm.GenderTypeName   
,GradeId=a.GradeId

,a.ParentName	

,InvoiceUpdateDate=ISNULL(a.InvoiceDate,a.UpdateDate)
,a.FeeStatementType	,a.InvoiceNo	,a.InvoiceDate	,a.PaymentMethod	,a.FeeType	,a.FeeAmount	,a.PaidAmount	,a.StudentId	
,a.AcademicYearId	,a.UpdateDate	,a.UpdateBy

,sa.PeriodFrom
,sa.PeriodTo

FROM  
tblStudent stu   
JOIN tblParent par ON stu.ParentId=par.ParentId  

LEFT join tblFeeStatement a ON a.StudentId=stu.StudentId and a.IsActive=1 and a.IsDeleted=0
LEFT JOIN tblGradeMaster gm ON a.GradeId=gm.GradeId and gm.IsActive=1 and gm.IsDeleted=0
LEFT JOIN tblSchoolAcademic AS sa ON a.AcademicYearId = sa.SchoolAcademicId   
LEFT JOIN tblCostCenterMaster cc ON gm.CostCenterId=cc.CostCenterId
LEFT JOIN tblGenderTypeMaster gtm ON gtm.GenderTypeId=stu.GenderId
where
stu.IsActive=1 and stu.IsDeleted=0
and par.IsActive=1 and par.IsDeleted=0
GO