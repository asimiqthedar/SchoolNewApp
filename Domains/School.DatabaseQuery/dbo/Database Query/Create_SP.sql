IF OBJECT_ID('[usp_SaveErrorDetail]', 'P') IS NOT NULL
DROP PROC [usp_SaveErrorDetail]
GO
CREATE PROCEDURE [dbo].[usp_SaveErrorDetail]
AS
BEGIN
	SET NOCOUNT ON;	
	INSERT INTO tblErrors
	(	
	[ERROR_NUMBER]
	,[ERROR_SEVERITY]
	,[ERROR_STATE]
	,[ERROR_PROCEDURE]
	,[ERROR_LINE]
	,[ERROR_MESSAGE]
	)
	SELECT	ERROR_NUMBER()
	,ERROR_SEVERITY()
	,ERROR_STATE()
	,ERROR_PROCEDURE()
	,ERROR_LINE()
	,ERROR_MESSAGE()
END
GO
IF OBJECT_ID('[sp_AdjustGrade]', 'P') IS NOT NULL
DROP PROC [sp_AdjustGrade]
GO
CREATE PROCEDURE [dbo].[sp_AdjustGrade]
	@GradeId int
	,@Value int
	,@SequenceNo int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF @Value=-1
			BEGIN
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo+1 
					WHERE GradeId =(SELECT GradeId FROM tblGradeMaster 
									WHERE SequenceNo=@SequenceNo-1)
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo-1 
					WHERE GradeId =@GradeId
			END
			ELSE
			BEGIN
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo-1
					WHERE GradeId =(SELECT GradeId FROM tblGradeMaster 
									WHERE SequenceNo=@SequenceNo+1)
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo+1 
					WHERE GradeId =@GradeId
			END
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteCostCenter]', 'P') IS NOT NULL
DROP PROC [sp_DeleteCostCenter]
GO
CREATE PROCEDURE [dbo].[sp_DeleteCostCenter] 
	@LoginUserId int
	,@CostCenterId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblCostCenterMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE CostCenterId = @CostCenterId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteDocumentType]', 'P') IS NOT NULL
DROP PROC [sp_DeleteDocumentType]
GO
CREATE PROCEDURE [dbo].[sp_DeleteDocumentType] 
	@LoginUserId int
	,@DocumentTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblDocumentTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE DocumentTypeId = @DocumentTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteGender]', 'P') IS NOT NULL
DROP PROC [sp_DeleteGender]
GO
CREATE PROCEDURE [dbo].[sp_DeleteGender] 
	@LoginUserId int
	,@GenderTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblGenderTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE GenderTypeId = @GenderTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteGrade]', 'P') IS NOT NULL
DROP PROC [sp_DeleteGrade]
GO
CREATE PROCEDURE [dbo].[sp_DeleteGrade] 
	@LoginUserId int
	,@GradeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblGradeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE GradeId = @GradeId

		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteGradeSection]', 'P') IS NOT NULL
DROP PROC [sp_DeleteGradeSection]
GO
CREATE PROCEDURE [dbo].[sp_DeleteGradeSection] 
	@LoginUserId int
	,@GradeSectionId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblGradeSection
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE GradeSectionId= @GradeSectionId
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteInvoiceType]', 'P') IS NOT NULL
DROP PROC [sp_DeleteInvoiceType]
GO
CREATE PROCEDURE [dbo].[sp_DeleteInvoiceType] 
	@LoginUserId int
	,@InvoiceTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblInvoiceTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE InvoiceTypeId = @InvoiceTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteParent]', 'P') IS NOT NULL
DROP PROC [sp_DeleteParent]
GO
CREATE PROCEDURE [dbo].[sp_DeleteParent] 
	@LoginUserId int
	,@ParentId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblParent
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE ParentId = @ParentId
		
		UPDATE tblUser 	
		SET IsActive = 0
			,IsDeleted = 1
			,UpdateBy = @LoginUserId
			,UpdateDate = GETDATE()
		WHERE UserEmail = (Select FatherEmail from tblParent WHERE ParentId = @ParentId)

		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_DeleteUser]', 'P') IS NOT NULL
DROP PROC [sp_DeleteUser]
GO
CREATE PROCEDURE [dbo].[sp_DeleteUser] 
	@LoginUserId int
	,@UserId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblUser
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE UserId = @UserId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_GetAppDropdown]', 'P') IS NOT NULL
DROP PROC [sp_GetAppDropdown]
GO
CREATE PROCEDURE [dbo].[sp_GetAppDropdown]
	@DropdownType int
	,@ReferenceId int
AS
BEGIN
	SET NOCOUNT ON;
	IF @DropdownType = 1
	BEGIN
		SELECT trl.RoleId AS SValue
			,trl.RoleName	AS SText
		FROM tblRole trl
		WHERE trl.IsActive = 1 AND trl.IsDeleted = 0
		ORDER BY trl.RoleName
	END
	IF @DropdownType = 2
	BEGIN
		SELECT tcc.CostCenterId AS SValue
			,tcc.CostCenterName	AS SText
		FROM tblCostCenterMaster tcc
		WHERE tcc.IsActive = 1 AND tcc.IsDeleted = 0
		ORDER BY tcc.CostCenterName
	END
	IF @DropdownType = 3
	BEGIN
		SELECT tgt.GenderTypeId AS SValue
			,tgt.GenderTypeName	AS SText
		FROM tblGenderTypeMaster tgt
		WHERE tgt.IsActive = 1 AND tgt.IsDeleted = 0
		ORDER BY tgt.GenderTypeName
	END
	IF @DropdownType = 4
	BEGIN
		SELECT tg.GradeId AS SValue
			,CONCAT_WS(' - ',tcc.CostCenterName ,tg.GradeName, tgt.GenderTypeName) 	AS SText
		FROM tblGradeMaster tg
		INNER JOIN tblCostCenterMaster tcc
			ON tcc.CostCenterId = tg.CostCenterId
		LEFT JOIN tblGenderTypeMaster tgt
			ON tgt.GenderTypeId = tg.GenderTypeId
		WHERE tg.IsActive = 1 AND tg.IsDeleted = 0
			AND tg.CostCenterId = CASE WHEN @ReferenceId > 0 THEN @ReferenceId ELSE tg.CostCenterId END 
		ORDER BY tg.SequenceNo
	END
	IF @DropdownType = 5
	BEGIN
		SELECT tc.CountryId AS SValue
			,CONCAT_WS(' - ',tc.CountryName, tc.CountryCode) 	AS SText
		FROM tblCountryMaster tc		
		WHERE tc.IsActive = 1 AND tc.IsDeleted = 0			
		ORDER BY tc.CountryName
	END
END
GO
IF OBJECT_ID('[sp_GetAuthDetail]', 'P') IS NOT NULL
DROP PROC [sp_GetAuthDetail]
GO
CREATE PROCEDURE [dbo].[sp_GetAuthDetail] 
	@UserEmail [nvarchar](200)
	,@UserPass [nvarchar](500)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT tu.UserId
		,tu.UserName
		,tu.UserArabicName
		,tu.UserEmail
		,tu.UserPhone
		,tr.RoleId
		,tr.RoleName
		,tu.ProfileImg		
	FROM tblUser tu
	INNER JOIN tblRole tr
		ON tr.RoleId = tu.RoleId	
	WHERE tu.IsActive = 1 AND tu.IsDeleted = 0 AND tr.IsActive = 1 AND tr.IsDeleted = 0
		AND tu.UserEmail = @UserEmail AND tu.UserPass = @UserPass
	
	DECLARE @MenuTable 
	TABLE(MenuId int
		,Menu nvarchar(50)
		,MenuCtrl nvarchar(100)
		,MenuAction nvarchar(100)
		,ParentMenuId int
		,DisplaySequence int
		,FaIcon nvarchar(50)
		,AllowAdd bit
		,AllowEdit bit
		,AllowDelete bit)
	INSERT INTO @MenuTable (MenuId, Menu, MenuCtrl, MenuAction, ParentMenuId, DisplaySequence,FaIcon,AllowAdd,AllowEdit,AllowDelete)
	SELECT tm.MenuId
		,tm.Menu
		,tm.MenuCtrl
		,tm.MenuAction
		,tm.ParentMenuId
		,tm.DisplaySequence
		,tm.FaIcon
		,trmm.AllowAdd
		,trmm.AllowEdit
		,trmm.AllowDelete
	FROM tblMenu tm
	INNER JOIN tblRoleMenuMapping trmm
		ON tm.MenuId = trmm.MenuId
	INNER JOIN tblUser tu
		ON tu.RoleId = trmm.RoleId
	WHERE tu.UserEmail = @UserEmail
		AND tm.IsActive = 1 AND trmm.IsActive = 1
		AND tm.IsDeleted =0 AND trmm.IsDeleted = 0
	;WITH  MenuCTE
	AS
	(
		SELECT tm1.MenuId
			,tm1.Menu
			,tm1.MenuCtrl
			,tm1.MenuAction
			,tm1.ParentMenuId
			,tm1.DisplaySequence
			,tm1.FaIcon
			,tm1.AllowAdd
			,tm1.AllowEdit
			,tm1.AllowDelete
			,1 AS [Level]
			,CAST((tm1.Menu) AS VARCHAR(MAX)) AS Hierarchy
		FROM @MenuTable tm1
		WHERE ParentMenuId = 0

		UNION ALL
		SELECT tm2.MenuId
			,tm2.Menu
			,tm2.MenuCtrl
			,tm2.MenuAction
			,tm2.ParentMenuId
			,tm2.DisplaySequence
			,tm2.FaIcon
			,tm2.AllowAdd
			,tm2.AllowEdit
			,tm2.AllowDelete
			,M.[level] + 1 AS [Level]
			,CAST((M.Hierarchy + '->' + tm2.Menu) AS VARCHAR(MAX)) AS Hierarchy
		FROM @MenuTable AS tm2
		JOIN MenuCTE AS M ON tm2.ParentMenuId = M.MenuId   
	)
	SELECT * FROM MenuCTE
	ORDER BY ParentMenuId,DisplaySequence
END
GO
IF OBJECT_ID('[sp_GetCostCenter]', 'P') IS NOT NULL
DROP PROC [sp_GetCostCenter]
GO
CREATE PROCEDURE [dbo].[sp_GetCostCenter]
	@CostCenterId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tcc.CostCenterId
		,tcc.CostCenterName
		,tcc.Remarks		
		,tcc.IsActive		
	FROM tblCostCenterMaster tcc		
	WHERE tcc.CostCenterId = CASE WHEN @CostCenterId > 0 THEN @CostCenterId ELSE tcc.CostCenterId END
		AND (tcc.CostCenterName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.CostCenterName END + '%'
		OR tcc.Remarks LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.Remarks END + '%')
		AND tcc.IsActive =  CASE WHEN @CostCenterId>0 THEN tcc.IsActive ELSE @FilterIsActive  END
		AND tcc.IsDeleted =  0
	ORDER BY tcc.CostCenterName
END
GO
IF OBJECT_ID('[sp_GetDocumentType]', 'P') IS NOT NULL
DROP PROC [sp_GetDocumentType]
GO
CREATE PROCEDURE [dbo].[sp_GetDocumentType]
	@DocumentTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tdt.DocumentTypeId
		,tdt.DocumentTypeName
		,tdt.Remarks		
		,tdt.IsActive		
	FROM tblDocumentTypeMaster tdt		
	WHERE tdt.DocumentTypeId = CASE WHEN @DocumentTypeId > 0 THEN @DocumentTypeId ELSE tdt.DocumentTypeId END
		AND (tdt.DocumentTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tdt.DocumentTypeName END + '%'
		OR tdt.Remarks LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tdt.Remarks END + '%')
		AND tdt.IsActive =  CASE WHEN @DocumentTypeId>0 THEN tdt.IsActive ELSE @FilterIsActive  END
		AND tdt.IsDeleted =  0
	ORDER BY tdt.DocumentTypeName
END
GO
IF OBJECT_ID('[sp_GetGender]', 'P') IS NOT NULL
DROP PROC [sp_GetGender]
GO
CREATE PROCEDURE [dbo].[sp_GetGender]
	@GenderTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tgt.GenderTypeId
		,tgt.GenderTypeName
		,tgt.IsActive		
	FROM tblGenderTypeMaster tgt		
	WHERE tgt.GenderTypeId = CASE WHEN @GenderTypeId > 0 THEN @GenderTypeId ELSE tgt.GenderTypeId END
		AND (tgt.GenderTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgt.GenderTypeName END + '%')
		AND tgt.IsActive =  CASE WHEN @GenderTypeId>0 THEN tgt.IsActive ELSE @FilterIsActive  END
		AND tgt.IsDeleted =  0
	ORDER BY tgt.GenderTypeName
END
GO
IF OBJECT_ID('[sp_GetGradeMaxSequenceNo]', 'P') IS NOT NULL
DROP PROC [sp_GetGradeMaxSequenceNo]
GO
CREATE PROCEDURE [dbo].[sp_GetGradeMaxSequenceNo]
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT ISNULL(MAX(SequenceNo),0) AS SequenceNo
	FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0
END
GO
IF OBJECT_ID('[sp_GetGrades]', 'P') IS NOT NULL
DROP PROC [sp_GetGrades]
GO
CREATE PROCEDURE [dbo].[sp_GetGrades]
	@GradeId int = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterCostCenterId int=0,
	@FilterGenderTypeId int=0,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tg.GradeId
		,tg.GradeName	
		,tg.SequenceNo	
		,tcc.CostCenterId
		,tcc.CostCenterName	
		,ISNULL(tgt.GenderTypeId,0) GenderTypeId
		,tgt.GenderTypeName
		,(SELECT MAX(SequenceNo)+1 FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0)  AS MaxSequenceNo 
		,tg.IsActive		
	FROM tblGradeMaster tg
	INNER JOIN tblCostCenterMaster tcc
		ON tcc.CostCenterId = tg.CostCenterId
	LEFT JOIN tblGenderTypeMaster tgt
		ON tgt.GenderTypeId = tg.GenderTypeId
	WHERE tg.GradeId = CASE WHEN @GradeId > 0 THEN @GradeId ELSE tg.GradeId END
		AND (tg.GradeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tg.GradeName END + '%'
		OR tcc.CostCenterName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.CostCenterName END + '%'
		OR tgt.GenderTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgt.GenderTypeName END + '%'
		)
		AND tg.CostCenterId = CASE WHEN @FilterCostCenterId > 0 THEN @FilterCostCenterId ELSE tg.CostCenterId END
		AND tg.GenderTypeId = CASE WHEN @FilterGenderTypeId > 0 THEN @FilterGenderTypeId ELSE tg.GenderTypeId END
		AND tg.IsActive =  CASE WHEN @GradeId > 0 THEN tg.IsActive ELSE @FilterIsActive  END
		AND tg.IsDeleted =0 AND tcc.IsDeleted = 0
	ORDER BY tg.SequenceNo

	
END
GO
IF OBJECT_ID([sp_GetGradeSections]'', 'P') IS NOT NULL
DROP PROC [sp_GetGradeSections]
GO
CREATE PROCEDURE [dbo].[sp_GetGradeSections]
	@GradeSectionId int = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterCostCenterId int=0,
	--@FilterGenderTypeId int=0,
	@FilterGradeId int=0,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tgs.GradeSectionId
		,tgs.SectionName	
		,tcc.CostCenterId
		,tcc.CostCenterName	
		--,tgt.GenderTypeId
		--,tgt.GenderTypeName
		,tg.GradeId
		,CONCAT_WS(' - ',tg.GradeName, tgt.GenderTypeName) AS GradeName
		,tgs.IsActive		
	FROM tblGradeSection tgs
	INNER JOIN tblCostCenterMaster tcc
		ON tcc.CostCenterId = tgs.CostCenterId
	INNER JOIN tblGradeMaster tg
		ON tgs.GradeId = tg.GradeId
	LEFT JOIN tblGenderTypeMaster tgt
		ON tgt.GenderTypeId = tg.GenderTypeId
	WHERE tgs.GradeSectionId = CASE WHEN @GradeSectionId > 0 THEN @GradeSectionId ELSE tgs.GradeSectionId END
		AND (tgs.SectionName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgs.SectionName END + '%'
			OR tcc.CostCenterName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.CostCenterName END + '%'
			--OR tgt.GenderTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgt.GenderTypeName END + '%'
			OR tg.GradeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tg.GradeName END + '%')
		AND tcc.CostCenterId = CASE WHEN @FilterCostCenterId > 0 THEN @FilterCostCenterId ELSE tcc.CostCenterId END
		--AND tgt.GenderTypeId = CASE WHEN @FilterGenderTypeId > 0 THEN @FilterGenderTypeId ELSE tgt.GenderTypeId END
		AND tg.GradeId = CASE WHEN @FilterGradeId > 0 THEN @FilterGradeId ELSE tg.GradeId END
		AND tgs.IsActive =  CASE WHEN  @GradeSectionId>0 THEN tgs.IsActive ELSE @FilterIsActive  END
		AND tgs.IsDeleted =0 AND tgs.IsDeleted = 0
	ORDER BY tg.SequenceNo
END
GO
IF OBJECT_ID('[sp_GetInvoiceType]', 'P') IS NOT NULL
DROP PROC [sp_GetInvoiceType]
GO
CREATE PROCEDURE [dbo].[sp_GetInvoiceType]
	@InvoiceTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tit.InvoiceTypeId
		,tit.InvoiceTypeName		
		,tit.IsActive		
	FROM tblInvoiceTypeMaster tit		
	WHERE tit.InvoiceTypeId = CASE WHEN @InvoiceTypeId > 0 THEN @InvoiceTypeId ELSE tit.InvoiceTypeId END
		AND (tit.InvoiceTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tit.InvoiceTypeName END + '%')
		AND tit.IsActive =  CASE WHEN  @InvoiceTypeId>0 THEN tit.IsActive ELSE @FilterIsActive  END
		AND tit.IsDeleted =  0
	ORDER BY tit.InvoiceTypeName
END
GO
IF OBJECT_ID('[sp_GetParent]', 'P') IS NOT NULL
DROP PROC [sp_GetParent]
GO
CREATE PROCEDURE [dbo].[sp_GetParent]
	@ParentId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1,
	@FilterNationalityId int= 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tp.ParentId
		,tp.ParentCode
		,tp.FatherName
		,tp.FatherArabicName
		,tp.FatherNationalityId
		,tp.FatherMobile
		,tp.FatherEmail
		,tp.IsFatherStaff	
		,tp.MotherName
		,tp.MotherArabicName
		,tp.MotherNationalityId
		,tp.MotherMobile
		,tp.MotherEmail
		,tp.IsMotherStaff
		,tp.IsActive
		,tp.IsDeleted
		,tp.UpdateDate
		,tp.UpdateBy		
	FROM tblParent tp	
	LEFT JOIN tblCountryMaster ftc
		ON ftc.CountryId = tp.FatherNationalityId
	LEFT JOIN tblCountryMaster mtc
		ON mtc.CountryId = tp.MotherNationalityId
	WHERE tp.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId END
		AND (tp.ParentCode LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.ParentCode END + '%'
			OR tp.FatherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherName END + '%'
			OR tp.FatherArabicName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherArabicName END + '%'
			OR ftc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ftc.CountryName END + '%'
			OR tp.FatherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherMobile END + '%'
			OR tp.FatherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherEmail END + '%'
			OR tp.MotherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherName END + '%'
			OR mtc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE mtc.CountryName END + '%'
			OR tp.MotherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherMobile END + '%'
			OR tp.MotherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherEmail END + '%'
		)
		AND tp.IsActive =  CASE WHEN  @ParentId > 0 THEN tp.IsActive ELSE @FilterIsActive  END
		AND (tp.FatherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.FatherNationalityId END
		OR tp.MotherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.MotherNationalityId END)
		AND tp.IsDeleted =  0
	ORDER BY tp.ParentCode
END
GO
IF OBJECT_ID('[sp_GetUsers]', 'P') IS NOT NULL
DROP PROC [sp_GetUsers]
GO
CREATE PROCEDURE [dbo].[sp_GetUsers]
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
IF OBJECT_ID('[sp_SaveCostCenter]', 'P') IS NOT NULL
DROP PROC [sp_SaveCostCenter]
GO
CREATE PROCEDURE [dbo].[sp_SaveCostCenter]
	@LoginUserId int
	,@CostCenterId bigint
	,@CostCenterName nvarchar(200)
	,@Remarks nvarchar(400)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblCostCenterMaster WHERE CostCenterName = @CostCenterName
			AND CostCenterId <> @CostCenterId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Costcenter already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@CostCenterId = 0)
			BEGIN
				INSERT INTO tblCostCenterMaster
					   (CostCenterName
					   ,Remarks							  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@CostCenterName
					   ,@Remarks								  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblCostCenterMaster
						SET CostCenterName = @CostCenterName
							,Remarks = @Remarks								
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE CostCenterId = @CostCenterId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveDocumentType]', 'P') IS NOT NULL
DROP PROC [sp_SaveDocumentType]
GO
CREATE PROCEDURE [dbo].[sp_SaveDocumentType]
	@LoginUserId int
	,@DocumentTypeId bigint
	,@DocumentTypeName nvarchar(200)
	,@Remarks nvarchar(400)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblDocumentTypeMaster WHERE DocumentTypeName = @DocumentTypeName
			AND DocumentTypeId <> @DocumentTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'DocumentType already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@DocumentTypeId = 0)
			BEGIN
				INSERT INTO tblDocumentTypeMaster
					   (DocumentTypeName
					   ,Remarks							  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@DocumentTypeName
					   ,@Remarks								  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblDocumentTypeMaster
						SET DocumentTypeName = @DocumentTypeName
							,Remarks = @Remarks								
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE DocumentTypeId = @DocumentTypeId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveGender]', 'P') IS NOT NULL
DROP PROC [sp_SaveGender]
GO
CREATE PROCEDURE [dbo].[sp_SaveGender]
	@LoginUserId int
	,@GenderTypeId bigint
	,@GenderTypeName nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblGenderTypeMaster WHERE GenderTypeName = @GenderTypeName
			AND GenderTypeId <> @GenderTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Gender already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@GenderTypeId = 0)
			BEGIN
				INSERT INTO tblGenderTypeMaster
					   (GenderTypeName				  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@GenderTypeName					  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblGenderTypeMaster
						SET GenderTypeName = @GenderTypeName			
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE GenderTypeId = @GenderTypeId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveGrade]', 'P') IS NOT NULL
DROP PROC [sp_SaveGrade]
GO
CREATE PROCEDURE [dbo].[sp_SaveGrade]
	@LoginUserId int
	,@GradeId int
	,@GradeName nvarchar(200)
	,@CostCenterId int
	,@GenderTypeId int=0
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblGradeMaster WHERE GradeName = @GradeName AND CostCenterId= @CostCenterId AND GenderTypeId = @GenderTypeId
			AND GradeId <> @GradeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Grade already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1	
		
			IF(@GradeId = 0)
			BEGIN
				INSERT INTO tblGradeMaster
					   (GradeName					 
					   ,CostCenterId					 
					   ,GenderTypeId					 
					   ,SequenceNo				  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@GradeName					 
					   ,@CostCenterId				 
					   ,@GenderTypeId				 
					   ,(SELECT ISNULL(MAX(SequenceNo),0)+1 FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0)			  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)

				SET @GradeId =SCOPE_IDENTITY()

			END
			ELSE
			BEGIN
				UPDATE tblGradeMaster
						SET GradeName = @GradeName						
							,CostCenterId = @CostCenterId					
							,GenderTypeId = @GenderTypeId			
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE GradeId = @GradeId				
			END
			COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveGradeSection]', 'P') IS NOT NULL
DROP PROC [sp_SaveGradeSection]
GO
CREATE PROCEDURE [dbo].[sp_SaveGradeSection]
	@LoginUserId int
	,@GradeSectionId int
	,@SectionName nvarchar(200)
	,@CostCenterId int = 0
	,@GradeId int
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	--IF EXISTS(SELECT 1 FROM tblGradeSection WHERE SectionName = @SectionName 
	--		AND GradeSectionId <> @GradeSectionId AND IsActive = 1)
	--BEGIN
	--	SELECT -2 AS Result, 'Grade Section already exists!' AS Response
	--	RETURN;
	--END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1		
			IF(@GradeSectionId = 0)
			BEGIN
				INSERT INTO tblGradeSection
					   (SectionName					 
					   ,CostCenterId				 
					   ,GradeId					  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@SectionName					 
					   ,(SELECT TOP 1 CostCenterId FROM tblGradeMaster WHERE GradeId=@GradeId)	 
					   ,@GradeId				  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);				
			END
			ELSE
			BEGIN
				UPDATE tblGradeSection
						SET SectionName = @SectionName						
							,CostCenterId =(SELECT TOP 1 CostCenterId FROM tblGradeMaster WHERE GradeId=@GradeId)
							,GradeId = @GradeId			
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE GradeSectionId = @GradeSectionId				  
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveInvoiceType]', 'P') IS NOT NULL
DROP PROC [sp_SaveInvoiceType]
GO
CREATE PROCEDURE [dbo].[sp_SaveInvoiceType]
	@LoginUserId int
	,@InvoiceTypeId bigint
	,@InvoiceTypeName nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblInvoiceTypeMaster WHERE InvoiceTypeName = @InvoiceTypeName
			AND InvoiceTypeId <> @InvoiceTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Invoice Type already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@InvoiceTypeId = 0)
			BEGIN
				INSERT INTO tblInvoiceTypeMaster
					   (InvoiceTypeName						  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@InvoiceTypeName								  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblInvoiceTypeMaster
						SET InvoiceTypeName = @InvoiceTypeName							
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE InvoiceTypeId = @InvoiceTypeId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveParent]', 'P') IS NOT NULL
DROP PROC [sp_SaveParent]
GO
CREATE PROCEDURE [dbo].[sp_SaveParent]
	@LoginUserId int
	,@ParentId bigint
	,@ParentPrefix nvarchar(50)
	,@FatherName nvarchar(200)
	,@FatherArabicName nvarchar(200) = NULL
	,@FatherIqamaNo nvarchar(50)
	,@FatherIqamaDocPath nvarchar(400) = NULL
	,@FatherNationalityId int
	,@FatherMobile nvarchar(20)
	,@FatherEmail nvarchar(200)
	,@IsFatherStaff	bit
	,@MotherName nvarchar(200)
	,@MotherArabicName nvarchar(200) = NULL
	,@MotherIqamaNo nvarchar(50)
	,@MotherIqamaDocPath nvarchar(400) = NULL
	,@MotherNationalityId int
	,@MotherMobile nvarchar(20) = NULL
	,@MotherEmail nvarchar(200) = NULL
	,@IsMotherStaff bit
	,@FPassword nvarchar(500) = NULL
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblParent WHERE FatherName = @FatherName 
			AND ParentId <> @ParentId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Parent already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@ParentId = 0)
			BEGIN
			    
				INSERT INTO tblParent
					   (ParentCode
						,FatherName
						,FatherArabicName
						,FatherIqamaNo
						,FatherIqamaDocPath
						,FatherNationalityId
						,FatherMobile
						,FatherEmail
						,IsFatherStaff
						,MotherName
						,MotherArabicName
						,MotherIqamaNo
						,MotherIqamaDocPath
						,MotherNationalityId
						,MotherMobile
						,MotherEmail
						,IsMotherStaff
						,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@ParentPrefix
						,@FatherName
						,@FatherArabicName
						,@FatherIqamaNo
						,@FatherIqamaDocPath
						,@FatherNationalityId
						,@FatherMobile
						,@FatherEmail
						,@IsFatherStaff
						,@MotherName
						,@MotherArabicName
						,@MotherIqamaNo
						,@MotherIqamaDocPath
						,@MotherNationalityId
						,@MotherMobile
						,@MotherEmail
						,@IsMotherStaff
						,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);

				SET @ParentId=SCOPE_IDENTITY();

				DECLARE @ParentCode VARCHAR(50) =  (SELECT CONCAT(@ParentPrefix, (right('000000'+convert(nvarchar(10),@ParentId),6))));

				UPDATE tblParent SET ParentCode = @ParentCode WHERE ParentId= @ParentId

				EXEC sp_SaveUser @LoginUserId=@LoginUserId,@UserId=0,@UserName=@FatherName,@UserArabicName=@FatherArabicName,@UserEmail=@FatherEmail
				,@UserPhone=@FatherMobile,@UserPass=@FPassword,@RoleId=3,@IsActive=1

			END
			ELSE
			BEGIN
				UPDATE tblParent
						SET FatherName = @FatherName
						,FatherArabicName= @FatherArabicName
						,FatherIqamaNo= @FatherIqamaNo
						,FatherIqamaDocPath= @FatherIqamaDocPath
						,FatherNationalityId= @FatherNationalityId
						,FatherMobile= @FatherMobile
						,FatherEmail= @FatherEmail
						,IsFatherStaff= @IsFatherStaff
						,MotherName= @MotherName
						,MotherArabicName= @MotherArabicName
						,MotherIqamaNo= @MotherIqamaNo
						,MotherIqamaDocPath= @MotherIqamaDocPath
						,MotherNationalityId= @MotherNationalityId
						,MotherMobile= @MotherMobile
						,MotherEmail= @MotherEmail
						,IsMotherStaff= @IsMotherStaff
						,IsActive = @IsActive				
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE ParentId = @ParentId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveUser]', 'P') IS NOT NULL
DROP PROC [sp_SaveUser]
GO
CREATE PROCEDURE [dbo].[sp_SaveUser]
	@LoginUserId int
	,@UserId int
	,@UserName nvarchar(200)
	,@UserArabicName nvarchar(500)
	,@UserEmail nvarchar(200)
	,@UserPhone nvarchar(20) = NULL
	,@UserPass nvarchar(500) = NULL
	,@RoleId int
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblUser WHERE UserEmail = @UserEmail 
			AND UserId <> @UserId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'User already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@UserId = 0)
			BEGIN
				INSERT INTO tblUser
					   (UserName
					   ,UserArabicName
					   ,UserEmail
					   ,UserPhone
					   ,UserPass
					   ,RoleId					  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@UserName
					   ,@UserArabicName
					   ,@UserEmail
					   ,@UserPhone		  
					   ,@UserPass
					   ,@RoleId					  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblUser
						SET UserName = @UserName
							,UserArabicName = @UserArabicName
							,UserEmail = @UserEmail
							,UserPhone = @UserPhone
							,UserPass = @UserPass
							,RoleId = @RoleId						
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE UserId = @UserId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
IF OBJECT_ID('[sp_SaveUserImage]', 'P') IS NOT NULL
DROP PROC [sp_SaveUserImage]
GO
CREATE PROCEDURE [dbo].[sp_SaveUserImage] 
	@LoginUserId int
	,@UserId int
	,@ImgPath nvarchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblUser
			SET ProfileImg = @ImgPath
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE UserId = @UserId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO


IF OBJECT_ID('[sp_GetStudentStatus]', 'P') IS NOT NULL
DROP PROC [sp_GetStudentStatus]
GO
CREATE PROCEDURE [dbo].[sp_GetStudentStatus]
	@StudentStatusId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterStatusId int=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tss.StudentStatusId
		,tss.StatusName		
		,tss.IsActive		
	FROM tblStudentStatus tss		
	WHERE tss.StudentStatusId = CASE WHEN @StudentStatusId > 0 THEN @StudentStatusId ELSE tss.StudentStatusId END
		AND (tss.StatusName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tss.StatusName END + '%')
		AND tss.IsActive =  CASE WHEN @FilterStatusId=-1 OR @StudentStatusId>0 THEN tss.IsActive ELSE @FilterStatusId  END
		AND tss.IsDeleted =  0
	ORDER BY tss.StatusName
END
GO


IF OBJECT_ID('[sp_SaveStudentStatus]', 'P') IS NOT NULL
DROP PROC [sp_SaveStudentStatus]
GO
CREATE PROCEDURE [dbo].[sp_SaveStudentStatus]
	@LoginUserId int
	,@StudentStatusId bigint
	,@StatusName nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblStudentStatus WHERE StatusName = @StatusName
			AND StudentStatusId <> @StudentStatusId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Student Status already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@StudentStatusId = 0)
			BEGIN
				INSERT INTO tblStudentStatus
					   (StatusName						  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@StatusName							  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblStudentStatus
						SET StatusName = @StatusName
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE StudentStatusId = @StudentStatusId
			END				
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO


IF OBJECT_ID('[sp_DeleteStudentStatus]', 'P') IS NOT NULL
DROP PROC [sp_DeleteStudentStatus]
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudentStatus] 
	@LoginUserId int
	,@StudentStatusId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentStatus
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE @StudentStatusId = @StudentStatusId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO