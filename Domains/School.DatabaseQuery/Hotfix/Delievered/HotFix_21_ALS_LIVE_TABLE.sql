  
alter table tblSchoolAcademic add IsCurrentYear bit null 

update tblSchoolAcademic  set IsCurrentYear =0

update tblSchoolAcademic
set IsCurrentYear=1
where  cast(getdate() as date) between cast(PeriodFrom as date) and cast(PeriodTo as date)