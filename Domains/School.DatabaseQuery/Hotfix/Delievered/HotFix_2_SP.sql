alter PROCEDURE [dbo].[sp_GetUsers]
	@UserId int = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterRoleId int=0,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tu.UserId
		,tu.UserName
		,tu.UserArabicName
		,tu.UserEmail
		,tu.UserPhone
		,tu.UserPass
		,tu.RoleId
		,trl.RoleName
		,tu.ProfileImg				
		,tu.IsActive	
		,IsApprover=isnull(tu.IsApprover,0)
	FROM tblUser tu
	INNER JOIN tblRole trl
		ON trl.RoleId = tu.RoleId	
	WHERE tu.UserId = CASE WHEN @UserId > 0 THEN @UserId ELSE tu.UserId END
		AND (tu.UserName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserName END + '%'
		OR tu.UserEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserEmail END + '%'
		OR tu.UserPhone LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserPhone END + '%')
		AND tu.RoleId = CASE WHEN @FilterRoleId > 0 THEN @FilterRoleId ELSE tu.RoleId END
		AND tu.IsActive =  CASE WHEN @UserId>0 THEN tu.IsActive ELSE @FilterIsActive  END
		AND tu.IsDeleted =0 AND trl.IsDeleted = 0
	ORDER BY tu.UserName
END
GO
