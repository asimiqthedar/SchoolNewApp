ALTER PROCEDURE [dbo].[sp_GetInvoice]                  
  @InvoiceId bigint = 0,        
  @Status nvarchar(50) = NULL,        
  @InvoiceDateStart date = NULL,        
  @InvoiceDateEnd date = NULL,        
  @InvoiceType nvarchar(50) = NULL,        
  @InvoiceNo nvarchar(50) = NULL,        
  @ParentCode nvarchar(50) = NUll,        
  @ParentName nvarchar(400) = NULL         
AS                  
BEGIN                  
 SET NOCOUNT ON;                   
        
 SELECT         
tis.InvoiceId        
,tis.InvoiceNo        
,tis.InvoiceDate        
,tis.Status        
,tis.PublishedBy        
,tis.CreditNo        
,tis.CreditReason        
,tis.CustomerName        
,tis.ParentId        
,tis.IqamaNumber        
,tis.TaxableAmount        
,tis.TaxAmount        
,tis.ItemSubtotal        
,tis.IsDeleted        
,tis.UpdateDate        
,tis.UpdateBy       
,InvoiceType=isnull(tis.InvoiceType,'Invoice')  
    
,tis.InvoiceRefNo  
,InvoiceTypeValue=  (select REPLACE(STUFF(CAST((
                    SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))
                    FROM ( 
	 SELECT scm.InvoiceType    
		 FROM INV_InvoiceDetail AS scm      
		 WHERE scm.InvoiceNo = tis.InvoiceNo      
	  ) c
    FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')) 


 FROM INV_InvoiceSummary tis               
 LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId           
 WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END        
  AND (@Status IS NULL OR tis.[Status] = @Status)        
  AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))        
  AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))        
  AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)        
  AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)        
  AND (@ParentCode IS NULL OR tp.ParentCode = @ParentCode)        
  AND (@ParentName IS NULL OR tp.FatherName like '%'+@ParentName+'%')        
  AND tis.IsDeleted = 0                  
 ORDER BY tis.InvoiceNo DESC                  
END 
GO

ALTER proc [dbo].[Sp_GetItemCodeRecord]    
@ItemCode nvarchar(200)    
,@nationalId int
, @UniformDB nvarchar(100)  
as    
begin
	declare @VatPercent decimal(18,2)=0;  
	declare @VatID int=0;  
	declare @ExcludedCountryCount int=0;  

	select top 1 
		@VatPercent=ISNULL(VatTaxPercent,0),
		@VatID =fd.VatId
	from [dbo].[tblFeeTypeMaster] fm  
	inner join [dbo].[tblVatMaster] fd on fm.FeeTypeId=fd.FeeTypeId  
	where fm.FeeTypeId=1 OR fm.FeeTypeName like '%uniform%'  
	and fm.IsActive=1 and fm.IsDeleted=0  
	and fd.IsActive=1 and fd.IsDeleted=0    

	--select @VatPercent,@VatID


  
   if(@VatID>0)  
   begin  
	select @ExcludedCountryCount=count(CountryId) from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0  
   end

   --select * from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0 and CountryId=@nationalId

   ----check if country excempted from tax
   if exists(select 1 from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0 and CountryId=@nationalId)
   begin
	set @VatPercent=0
   end

	DECLARE @Query nvarchar(max) 
	declare @VatPercent2 nvarchar(500)  
	declare @ExcludedCountryCount2 nvarchar(500)  
	DECLARE @VatID2 nvarchar(500)  
  
	SELECT @VatPercent2=cast( @VatPercent as nvarchar(50))  
  
	SELECT @ExcludedCountryCount2=cast( @ExcludedCountryCount as nvarchar(50))  
	SELECT @VatID2=cast( @VatID as nvarchar(50))  
  
	 /* Build the SQL string once */  
	 SET @Query = N'SELECT top 1     
	 A.CURRCOST AS CurrentPrice,    
	 A.ITEMNMBR as ItemCode,    
	 A.ITEMDESC as ItemDescription,    
	 B.QTYONHND as QuantityOnHand,    
	 B.ATYALLOC as QuantityAllocated,    
	 AvailableQuantity= B.QTYONHND-B.ATYALLOC  
  
	 ,VatPercent = '+@VatPercent2+'  
	 ,ExcludedCountryCount='+@ExcludedCountryCount2+'  
	 ,VatID='+@VatID2+'  
  
	 FROM '+@UniformDB+'.[dbo].IV00101 A    
	 join '+@UniformDB+'.[dbo].IV00102 B     
	 on A.ITEMNMBR=b.ITEMNMBR    
	 where A.ITEMNMBR like ''%'+@ItemCode+'%''  
	 and B.LOCNCODE=''''' ;  
	 print @query  
	 
	 EXECUTE sp_executesql @Query;  

end 
GO

ALTER PROCEDURE [dbo].[sp_SaveStudent]  
 @LoginUserId int  
 ,@StudentId bigint  
 ,@ParentId int  
 ,@StudentCode nvarchar(50)  
 ,@StudentName nvarchar(200)  
 ,@StudentImage nvarchar(500)=NULL  
 ,@StudentEmail nvarchar(200)=NULL  
 ,@StudentArabicName nvarchar(200) =NULL  
 ,@DOB datetime  
 ,@IqamaNo nvarchar(100)  
 ,@NationalityId int  
 ,@GenderId int  
 ,@AdmissionDate datetime = NULL  
 ,@GradeId int  
 ,@CostCenterId int  
 ,@SectionId int  
 ,@PassportNo nvarchar(50)=NULL  
 ,@PassportExpiry datetime=NULL  
 ,@Mobile nvarchar(20)=NULL  
 ,@StudentAddress nvarchar(400)  
 ,@StudentStatusId int  
 ,@WithdrawDate datetime =NULL  
 ,@WithdrawAt int=null  
 ,@WithdrawYear nvarchar(20)=NULL  
 ,@Fees decimal(12,2)=NULL  
 ,@IsGPIntegration bit  
 ,@TermId int  
 ,@AdmissionYear nvarchar(20) = NULL  
 ,@PrinceAccount bit  
 ,@UserPass nvarchar(500)= NULL  
 ,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblStudent WHERE StudentCode = @StudentCode  
   AND StudentId <> @StudentId AND IsActive = 1)  
 BEGIN  
  SELECT -2 AS Result, 'Student already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@StudentId = 0)  
   BEGIN  
         
    INSERT INTO tblStudent  
                  ([StudentCode]  
           ,[StudentImage]  
           ,[ParentId]  
           ,[StudentName]  
           ,[StudentArabicName]  
           ,[StudentEmail]  
           ,[DOB]  
           ,[IqamaNo]  
           ,[NationalityId]  
           ,[GenderId]  
           ,[AdmissionDate]  
           ,[GradeId]  
           ,[CostCenterId]  
           ,[SectionId]  
           ,[PassportNo]  
           ,[PassportExpiry]  
           ,[Mobile]  
           ,[StudentAddress]  
           ,[StudentStatusId]  
           ,[WithdrawDate]  
           ,[WithdrawAt]  
           ,[WithdrawYear]  
           ,[Fees]  
           ,[IsGPIntegration]  
           ,[TermId]  
           ,[AdmissionYear]  
           ,[PrinceAccount]  
           ,[IsActive]  
           ,[IsDeleted]  
           ,[UpdateDate]  
           ,[UpdateBy])  
    VALUES      
        (@StudentCode        
      ,CASE WHEN LEN(ISNULL(@StudentImage,0))>0 THEN @StudentImage ELSE '' END  
      ,@ParentId  
      ,@StudentName  
      ,@StudentArabicName  
      ,@StudentEmail  
      ,@DOB  
      ,@IqamaNo  
      ,@NationalityId  
      ,@GenderId  
      ,CASE WHEN @AdmissionDate IS NULL THEN NULL ELSE  @AdmissionDate END  
      ,@GradeId  
      ,@CostCenterId  
      ,@SectionId  
      ,@PassportNo  
      ,CASE WHEN @PassportExpiry IS NULL THEN NULL ELSE @PassportExpiry END  
      ,@Mobile  
      ,@StudentAddress  
      ,@StudentStatusId  
      ,CASE WHEN @WithdrawDate IS NULL THEN NULL ELSE @WithdrawDate END  
      ,@WithdrawAt  
      ,@WithdrawYear  
      ,@Fees  
      ,@IsGPIntegration  
      ,@TermId  
      ,@AdmissionYear  
      ,@PrinceAccount  
      ,@IsActive  
        ,0  
        ,GETDATE()  
        ,@LoginUserId);  
  
    SET @StudentId=SCOPE_IDENTITY();  
      
    EXEC sp_SaveUser @LoginUserId=@LoginUserId,@UserId=0,@UserName=@StudentName,@UserArabicName=@StudentArabicName,@UserEmail=@StudentEmail  
    ,@UserPhone=@Mobile,@UserPass=@UserPass,@RoleId=2,@IsActive=1 ,@IsApprover=0 
    SELECT @StudentId AS Result, 'Saved' AS Response  
   END  
   ELSE  
   BEGIN  
    UPDATE tblStudent  
      SET   
      ParentId=@ParentId  
      ,StudentCode = @StudentCode  
      ,StudentName=@StudentName  
      ,StudentArabicName=@StudentArabicName  
      ,StudentImage=CASE WHEN LEN(ISNULL(@StudentImage,0))>0 THEN StudentImage ELSE @StudentImage END       
      ,StudentEmail=@StudentEmail  
      ,DOB=@DOB  
      ,IqamaNo=@IqamaNo  
      ,NationalityId=@NationalityId  
      ,GenderId=@GenderId  
      ,AdmissionDate=CASE WHEN @AdmissionDate IS NULL THEN NULL ELSE @AdmissionDate END   
      ,GradeId=@GradeId  
      ,CostCenterId=@CostCenterId  
      ,SectionId=@SectionId  
      ,PassportNo=@PassportNo  
      ,PassportExpiry=CASE WHEN @PassportExpiry IS NULL THEN NULL ELSE @PassportExpiry END  
      ,Mobile=@Mobile  
      ,StudentAddress=@StudentAddress  
      ,StudentStatusId=@StudentStatusId  
      ,WithdrawDate=CASE WHEN @WithdrawDate IS NULL THEN NULL ELSE @WithdrawDate END  
      ,WithdrawAt=@WithdrawAt  
      ,WithdrawYear=@WithdrawYear  
      ,Fees=@Fees  
      ,IsGPIntegration=@IsGPIntegration  
      ,TermId=@TermId  
      ,AdmissionYear=@AdmissionYear  
      ,PrinceAccount=@PrinceAccount  
      ,IsActive=@IsActive     
      ,UpdateDate = GETDATE()  
      ,UpdateBy = @LoginUserId  
    WHERE StudentId = @StudentId  
    SELECT @StudentId AS Result, 'Saved' AS Response  
   END      
  COMMIT TRAN TRANS1  
    
 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1     
   SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END 
GO

ALTER PROCEDURE [dbo].[sp_SaveParent]
	@LoginUserId int
	,@ParentId bigint
	,@ParentCode nvarchar(50)
	,@ParentImage nvarchar(500)=NULL
	,@FatherName nvarchar(200)
	,@FatherArabicName nvarchar(200) = NULL
	,@FatherNationalityId int
	,@FatherMobile nvarchar(20)
	,@FatherEmail nvarchar(200)
	,@FatherIqamaNo nvarchar(50)
	,@IsFatherStaff	bit
	,@MotherName nvarchar(200)
	,@MotherArabicName nvarchar(200) = NULL
	,@MotherNationalityId int
	,@MotherMobile nvarchar(20) = NULL
	,@MotherEmail nvarchar(200) = NULL
	,@MotherIqamaNo nvarchar(50) = NULL
	,@IsMotherStaff bit
	,@FPassword nvarchar(500) = NULL
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblParent WHERE  ParentCode = @ParentCode
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
					    ,ParentImage
						,FatherName
						,FatherArabicName
						,FatherNationalityId
						,FatherMobile
						,FatherEmail
						,FatherIqamaNo
						,IsFatherStaff
						,MotherName
						,MotherArabicName
						,MotherNationalityId
						,MotherMobile
						,MotherEmail
						,MotherIqamaNo
						,IsMotherStaff
						,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@ParentCode
					   ,CASE WHEN LEN(ISNULL(@ParentImage,0))>0 THEN @ParentImage ELSE '' END
						,@FatherName
						,@FatherArabicName
						,@FatherNationalityId
						,@FatherMobile
						,@FatherEmail
						,@FatherIqamaNo
						,@IsFatherStaff
						,@MotherName
						,@MotherArabicName
						,@MotherNationalityId
						,@MotherMobile
						,@MotherEmail
						,@MotherIqamaNo
						,@IsMotherStaff
						,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);

				SET @ParentId=SCOPE_IDENTITY();
				--DECLARE @ParentCode VARCHAR(50) =  (SELECT CONCAT(@ParentPrefix, (right('000000'+convert(nvarchar(10),@ParentId),6))));

				--UPDATE tblParent SET ParentCode = @ParentCode WHERE ParentId= @ParentId

				EXEC sp_SaveUser @LoginUserId=@LoginUserId,@UserId=0,@UserName=@FatherName,@UserArabicName=@FatherArabicName,@UserEmail=@FatherEmail
				,@UserPhone=@FatherMobile,@UserPass=@FPassword,@RoleId=3,@IsActive=1,@IsApprover=0 
				SELECT @ParentId AS Result, 'Saved' AS Response
			END
			ELSE
			BEGIN
				UPDATE tblParent
						SET FatherName = @FatherName
						,ParentCode = @ParentCode
						,ParentImage=CASE WHEN LEN(ISNULL(@ParentImage,0))>0 THEN ParentImage ELSE @ParentImage END
						,FatherArabicName= @FatherArabicName
						,FatherNationalityId= @FatherNationalityId
						,FatherMobile= @FatherMobile
						,FatherEmail= @FatherEmail
						,FatherIqamaNo=@FatherIqamaNo
						,IsFatherStaff= @IsFatherStaff
						,MotherName= @MotherName
						,MotherArabicName= @MotherArabicName
						,MotherNationalityId= @MotherNationalityId
						,MotherMobile= @MotherMobile
						,MotherEmail= @MotherEmail
						,MotherIqamaNo=@MotherIqamaNo
						,IsMotherStaff= @IsMotherStaff
						,IsActive = @IsActive				
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE ParentId = @ParentId
				SELECT @ParentId AS Result, 'Saved' AS Response
			END				
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO