declare @ParentMenuId int=0
declare @DisplaySequence int=0

select top 1 @ParentMenuId =MenuId  from [tblMenu] where Menu='Setup'

select top 1 @DisplaySequence =max(DisplaySequence)+1  from [tblMenu] where Menu='Setup'


INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 'Payment Category', 'Setup', 'PaymentMethodCategory', @ParentMenuId, @DisplaySequence, 'fa-solid fa-file', 1, 0, CAST(N'2024-03-16T16:31:49.663' AS DateTime), -1)
declare @MenuId int= SCOPE_IDENTITY()
declare @NewMenuId int= SCOPE_IDENTITY()
select @MenuId 

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @MenuId , 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)

set @DisplaySequence=@DisplaySequence+1;


INSERT [dbo].[tblMenu] ( [Menu], [MenuCtrl], [MenuAction], [ParentMenuId], [DisplaySequence], [FaIcon], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( N'Payment Method', N'Setup', N'PaymentMethod', @ParentMenuId, @DisplaySequence, N'', 1, 0, CAST(N'2024-03-16T22:01:20.840' AS DateTime), -1)
set @NewMenuId = SCOPE_IDENTITY()

INSERT [dbo].[tblRoleMenuMapping] ([RoleId], [MenuId], [AllowAdd], [AllowEdit], [AllowDelete], [IsActive], [IsDeleted], [UpdateDate], [UpdateBy]) 
VALUES ( 1, @NewMenuId, 1, 1, 1, 1, 0, CAST(N'2024-03-19T12:51:04.447' AS DateTime), -1)
GO
