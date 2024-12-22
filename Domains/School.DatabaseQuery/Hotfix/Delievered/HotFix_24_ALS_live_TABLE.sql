Alter table tblSiblingDiscountMaster
Add StaffDiscountPercent decimal(5,2)  null
GO

update tblSiblingDiscountMaster
set StaffDiscountPercent=0
GO

Alter table tblSiblingDiscountMaster
alter column StaffDiscountPercent decimal(5,2) not null
GO