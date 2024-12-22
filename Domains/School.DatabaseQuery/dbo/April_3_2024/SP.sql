IF EXISTS ( SELECT * FROM   sysobjects WHERE  id = object_id(N'[dbo].[sp_DeleteSection]') and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[sp_DeleteSection]
END
GO

CREATE PROCEDURE [dbo].[sp_DeleteSection] 
	@LoginUserId int
	,@SectionId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM tblStudent WHERE SectionId=@SectionId AND IsDeleted = 0 AND IsActive=1)
		BEGIN
			SELECT -2 AS Result, 'Students are associated with this Section' AS Response
			RETURN
		END
		ELSE
		BEGIN
		BEGIN TRANSACTION TRANS1
		UPDATE tblSection
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE SectionId= @SectionId
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO