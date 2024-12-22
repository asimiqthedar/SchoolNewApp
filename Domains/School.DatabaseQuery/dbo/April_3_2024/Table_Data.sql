
------Insert into menu table
--for hide Parents menu
update tblMenu set IsActive = 0 where MenuId = 10

--move all parents branch under student
update tblMenu set ParentMenuId = 13 where MenuId = 11

-- for hide add/edit for students
update tblMenu set IsActive = 0 where MenuId = 15

--for hide school menu
update tblMenu set IsActive = 0 where MenuId = 22

--move school branch under setup
update tblMenu set ParentMenuId = 5 where MenuId = 24

--move all school branch under setup
update tblMenu set ParentMenuId = 5 where MenuId = 23
