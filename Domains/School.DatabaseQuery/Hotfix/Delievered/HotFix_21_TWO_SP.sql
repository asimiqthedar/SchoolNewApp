/*
Note:
1) @CallFrom = 0 for Call from SQL Job, and 1 for Call from UI.
2) @FromDate and @ToDate are passed from UI only.
3) @I_vTRXTYPE = 0 for Standard and 1 for Reversing.
4) IntegrationStatus = 0 for New, 1 for Successfully Integrated to GP, 2 for Error.
*/
IF OBJECT_ID('INT_CreateGLInGP', 'P') IS NOT NULL
   DROP PROC INT_CreateGLInGP
GO
CREATE PROCEDURE INT_CreateGLInGP @CallFrom INT = 0, @SourceDB CHAR(30) = '', @DestDB CHAR(30) = '', 
                                  @FromDate Datetime = '01/01/1900', @ToDate Datetime = '01/01/1900' 
AS
BEGIN

DECLARE @ID varchar(50) SET @ID = NEWID() print @ID
IF OBJECT_ID('tempdb..##INT_GLSourceTable_Temp','U') IS NULL
    create table ##INT_GLSourceTable_Temp
    (
	[ID] [varchar](50) NOT NULL,	
	[SeqNum] [int] NOT NULL,
	[Reference] [char](30) NOT NULL,
	[JournalNumber] [int] NULL,
	[TransactionType] [smallint] NULL,
	[TransactionDate] [datetime] NULL,
	[ReversingDate] [datetime] NULL,
	[AccountNumber] [char](75) NULL,
	[DistributionRef] [char](30) NULL,
	[CreditAmount] [numeric](19, 5) NULL,
	[DebitAmount] [numeric](19, 5) NULL,
	[IntegrationStatus] [smallint] NOT NULL,
	[Error] [varchar](max) NULL
	)
DECLARE @QueryString VARCHAR(MAX) = ''
IF(@CallFrom = 0)/******** Call from SQL Job ********/
BEGIN
SET @QueryString = 
'INSERT INTO ##INT_GLSourceTable_Temp (ID,SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber,
	   DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error) 
   SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber,
	   DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_GLSourceTable(NOLOCK) 
	       WHERE IntegrationStatus = 0'
END
ELSE/****** Call from UI ********/
BEGIN
SET @QueryString = 
'INSERT INTO ##INT_GLSourceTable_Temp (ID,SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber,
	   DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error) 
   SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber,
	   DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error  
      FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_GLSourceTable(NOLOCK) 
	  WHERE IntegrationStatus IN (0,2) AND TransactionDate BETWEEN '''+CONVERT(VARCHAR,@FromDate)+''' AND '''+CONVERT(VARCHAR,@ToDate)+''''  
END
PRINT @QueryString
EXECUTE (@QueryString)

DECLARE @RT INT = 0, @I_vBACHNUMB CHAR(15) = '', @I_vSERIES INT = 2,
        @I_vBCHSOURC CHAR(15) = 'GL_Normal', @I_vDOCAMT NUMERIC(19,5) = 0, @I_vORIGIN INT = 1,
		@I_vNUMOFTRX INT = 0, @I_vTRXSOURC CHAR(25) = '', 
		@I_vJRNENTRY INT = 0, @I_vREFRENCE CHAR(30) = 0, @I_vTRXDATE DATE = '01/01/1900', 
        @I_vRVRSNGDT DATE = '01/01/1900', @I_vTRXTYPE SMALLINT = 0, -- 0 for Standard and 1 for Reversing
		@I_vInc_Dec TINYINT = 1,-- 0 to decrement 1 to increment
		@O_vJournalEntryNumber CHAR(13) = '', @I_vACTINDX INT = 0,
		@I_vCRDTAMNT NUMERIC(19,5) = 0.00, @I_vDEBITAMT NUMERIC(19,5) = 0.00,
		@I_vACTNUMST CHAR(75) = '',@I_vDSCRIPTN CHAR(30) = '',@SeqNum INT = 0,
		@O_iErrorState INT = 0, @oErrString varchar(255) = '',
		@Error VARCHAR(MAX) = ''

SET @I_vBACHNUMB = 'INT_'+FORMAT(GETDATE(),'yyyyMMdd') 
PRINT 'Batch Number: '+@I_vBACHNUMB

IF (@CallFrom = 0)/******** Call from SQL Job ********/
BEGIN
   DECLARE CUR1 CURSOR FOR SELECT DISTINCT Reference FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 0 AND ID = @ID
   OPEN CUR1 FETCH NEXT FROM CUR1 INTO @I_vREFRENCE
   WHILE @@FETCH_STATUS = 0
   BEGIN
   IF EXISTS(select 1 from ##INT_GLSourceTable_Temp WHERE Reference = @I_vREFRENCE AND ID = @ID AND 
                AccountNumber NOT IN (select ACTNUMST from GL00105(NOLOCK)))
   BEGIN
          PRINT 'Account Number does not exists'
          UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = 'One of the Distribution Account Number does not exits in GP' 
		                            WHERE Reference = @I_vREFRENCE AND ID = @ID
   END
   ELSE
   BEGIN
	   IF NOT EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal')
	   BEGIN
		   EXECUTE @RT = [dbo].[taCreateUpdateBatchHeaderRcd]
						 @I_vBACHNUMB = @I_vBACHNUMB,
						 @I_vSERIES = @I_vSERIES,
						 @I_vBCHSOURC = @I_vBCHSOURC,
						 @I_vDOCAMT = @I_vDOCAMT,
						 @I_vORIGIN = @I_vORIGIN,
						 @I_vNUMOFTRX = @I_vNUMOFTRX,
						 @I_vTRXSOURC = @I_vTRXSOURC,
						 @O_iErrorState = @O_iErrorState OUTPUT,
						 @oErrString = @oErrString OUTPUT

		   PRINT 'Batch Creation Error: '+CONVERT(VARCHAR(255),@O_iErrorState) + @oErrString
		   SET @Error = ''
		   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
		   IF (@Error <> '')
		   BEGIN
			  UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = @Error WHERE Reference = @I_vREFRENCE AND ID = @ID
		   END 
	   END

	   EXECUTE @RT = [dbo].[taGetNextJournalEntry]
						@I_vInc_Dec = @I_vInc_Dec,
						@O_vJournalEntryNumber = @O_vJournalEntryNumber OUTPUT,
						@O_iErrorState = @O_iErrorState OUTPUT
   
	   SET @Error = ''
	   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
	   IF (@Error <> '')
	   BEGIN PRINT 'JE Number Creation Error'
		   UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error)) 
									 WHERE Reference = @I_vREFRENCE AND ID = @ID
	   END
	   SET @I_vJRNENTRY = @O_vJournalEntryNumber

	   SELECT TOP 1 @I_vTRXTYPE = TransactionType, @I_vTRXDATE = TransactionDate, @I_vRVRSNGDT = ISNULL(ReversingDate,'01/01/1900') 
		   FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE Reference = @I_vREFRENCE AND ID = @ID
   
	   IF (@I_vTRXTYPE = 1 AND @I_vRVRSNGDT = '01/01/1900')
	   BEGIN
		   SET @I_vRVRSNGDT = @I_vTRXDATE
	   END

	   EXECUTE @RT = [dbo].[taGLTransactionHeaderInsert]  
						@I_vBACHNUMB = @I_vBACHNUMB,
						@I_vJRNENTRY = @I_vJRNENTRY,
						@I_vREFRENCE = @I_vREFRENCE,
						@I_vTRXDATE = @I_vTRXDATE,
						@I_vRVRSNGDT = @I_vRVRSNGDT,
						@I_vTRXTYPE = @I_vTRXTYPE,
						@O_iErrorState = @O_iErrorState OUTPUT,
						@oErrString = @oErrString OUTPUT
   
	   SET @Error = ''
	   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
	   IF (@Error <> '')
	   BEGIN PRINT 'GL Header Error'
			  UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error)) 
										WHERE Reference = @I_vREFRENCE AND ID = @ID
	   END

	   DECLARE CUR2 CURSOR FOR SELECT SeqNum,AccountNumber, ISNULL(DistributionRef,''), ISNULL(CreditAmount,0.00), ISNULL(DebitAmount,0.00) 
									FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE Reference = @I_vREFRENCE AND ID = @ID
	   OPEN CUR2 FETCH NEXT FROM CUR2 INTO @SeqNum, @I_vACTNUMST, @I_vDSCRIPTN, @I_vCRDTAMNT, @I_vDEBITAMT
	   WHILE @@FETCH_STATUS = 0
	   BEGIN
			EXECUTE @RT = [dbo].[taGLTransactionLineInsert] 
					   @I_vBACHNUMB = @I_vBACHNUMB,
					   @I_vJRNENTRY = @I_vJRNENTRY,
					   @I_vCRDTAMNT = @I_vCRDTAMNT,
					   @I_vDEBITAMT = @I_vDEBITAMT,
					   @I_vACTNUMST = @I_vACTNUMST,
					   @I_vDSCRIPTN = @I_vDSCRIPTN,
					   @O_iErrorState = @O_iErrorState OUTPUT,
					   @oErrString = @oErrString OUTPUT
       
		   SET @Error = ''
		   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode WHERE ErrorCode = @O_iErrorState
		   IF (@Error <> '')
		   BEGIN PRINT 'GL Line Error'
			  UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))+@I_vACTNUMST
										WHERE Reference = @I_vREFRENCE AND SeqNum = @SeqNum AND ID = @ID
		   END

		   FETCH NEXT FROM CUR2 INTO @SeqNum, @I_vACTNUMST, @I_vDSCRIPTN, @I_vCRDTAMNT, @I_vDEBITAMT
       END
       CLOSE CUR2
       DEALLOCATE CUR2
	   IF NOT EXISTS (SELECT 1 FROM ##INT_GLSourceTable_Temp WHERE Reference = @I_vREFRENCE AND IntegrationStatus = 2 AND ID = @ID)
	   BEGIN print 'final succcess update'
		   UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY,IntegrationStatus = 1, Error = '' WHERE Reference = @I_vREFRENCE
																													AND ID = @ID
	   END  
   END   
	   FETCH NEXT FROM CUR1 INTO @I_vREFRENCE
   END
   CLOSE CUR1
   DEALLOCATE CUR1

   IF EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal')
   BEGIN
       SELECT @I_vDOCAMT = SUM(DEBITAMT)+SUM(CRDTAMNT) FROM GL10001 WHERE BACHNUMB = @I_vBACHNUMB
       IF (@I_vDOCAMT <> 0)
	        UPDATE SY00500 SET BCHTOTAL = @I_vDOCAMT WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal'
   END

END
ELSE /********** Call from UI *********/
BEGIN
   DECLARE CUR1_1 CURSOR FOR SELECT DISTINCT Reference FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE IntegrationStatus IN (0,2) AND 
							                                       TransactionDate BETWEEN @FromDate AND @ToDate AND ID = @ID
   OPEN CUR1_1 FETCH NEXT FROM CUR1_1 INTO @I_vREFRENCE
   WHILE @@FETCH_STATUS = 0
   BEGIN
   IF EXISTS(select 1 from ##INT_GLSourceTable_Temp WHERE Reference = @I_vREFRENCE AND ID = @ID AND 
                AccountNumber NOT IN (select ACTNUMST from GL00105(NOLOCK)))
   BEGIN
          PRINT 'Account Number does not exists'
          UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = 'One of the Distribution Account Number does not exits in GP' 
		                            WHERE Reference = @I_vREFRENCE AND ID = @ID
   END
   ELSE
   BEGIN
   IF NOT EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal')
   BEGIN
       EXECUTE @RT = [dbo].[taCreateUpdateBatchHeaderRcd]
					 @I_vBACHNUMB = @I_vBACHNUMB,
					 @I_vSERIES = @I_vSERIES,
					 @I_vBCHSOURC = @I_vBCHSOURC,
					 @I_vDOCAMT = @I_vDOCAMT,
					 @I_vORIGIN = @I_vORIGIN,
					 @I_vNUMOFTRX = @I_vNUMOFTRX,
					 @I_vTRXSOURC = @I_vTRXSOURC,
					 @O_iErrorState = @O_iErrorState OUTPUT,
					 @oErrString = @oErrString OUTPUT

       PRINT 'Batch Creation Error: '+CONVERT(VARCHAR(255),@O_iErrorState) + @oErrString
	   SET @Error = ''
	   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
	   IF (@Error <> '')
       BEGIN
          UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = @Error WHERE Reference = @I_vREFRENCE AND ID = @ID
       END 
   END

   EXECUTE @RT = [dbo].[taGetNextJournalEntry]
                    @I_vInc_Dec = @I_vInc_Dec,
					@O_vJournalEntryNumber = @O_vJournalEntryNumber OUTPUT,
					@O_iErrorState = @O_iErrorState OUTPUT
   
   SET @Error = ''
   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
   IF (@Error <> '')
   BEGIN print 'JE Number Creation Error'
       UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error)) 
	                             WHERE Reference = @I_vREFRENCE AND ID = @ID
   END
   SET @I_vJRNENTRY = @O_vJournalEntryNumber

   SELECT TOP 1 @I_vTRXTYPE = TransactionType, @I_vTRXDATE = TransactionDate, @I_vRVRSNGDT = ISNULL(ReversingDate,'01/01/1900') 
       FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE Reference = @I_vREFRENCE AND ID = @ID
   
   IF (@I_vTRXTYPE = 1 AND @I_vRVRSNGDT = '01/01/1900')
   BEGIN
       SET @I_vRVRSNGDT = @I_vTRXDATE
   END

   EXECUTE @RT = [dbo].[taGLTransactionHeaderInsert]  
                    @I_vBACHNUMB = @I_vBACHNUMB,
					@I_vJRNENTRY = @I_vJRNENTRY,
					@I_vREFRENCE = @I_vREFRENCE,
					@I_vTRXDATE = @I_vTRXDATE,
					@I_vRVRSNGDT = @I_vRVRSNGDT,
					@I_vTRXTYPE = @I_vTRXTYPE,
					@O_iErrorState = @O_iErrorState OUTPUT,
					@oErrString = @oErrString OUTPUT
   
   SET @Error = ''
   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState
   IF (@Error <> '')
   BEGIN print 'GL Header Error'
          UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error)) 
		                            WHERE Reference = @I_vREFRENCE AND ID = @ID
   END

   DECLARE CUR2_1 CURSOR FOR SELECT SeqNum, AccountNumber, ISNULL(DistributionRef,''), ISNULL(CreditAmount,0.00), ISNULL(DebitAmount,0.00) 
                                FROM ##INT_GLSourceTable_Temp(NOLOCK) WHERE Reference = @I_vREFRENCE AND ID = @ID
   OPEN CUR2_1 FETCH NEXT FROM CUR2_1 INTO @SeqNum, @I_vACTNUMST, @I_vDSCRIPTN, @I_vCRDTAMNT, @I_vDEBITAMT
   WHILE @@FETCH_STATUS = 0
   BEGIN
        EXECUTE @RT = [dbo].[taGLTransactionLineInsert] 
                   @I_vBACHNUMB = @I_vBACHNUMB,
                   @I_vJRNENTRY = @I_vJRNENTRY,
			       @I_vCRDTAMNT = @I_vCRDTAMNT,
                   @I_vDEBITAMT = @I_vDEBITAMT,
                   @I_vACTNUMST = @I_vACTNUMST,
				   @I_vDSCRIPTN = @I_vDSCRIPTN,
                   @O_iErrorState = @O_iErrorState OUTPUT,
                   @oErrString = @oErrString OUTPUT
       
	   SET @Error = ''
	   SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode WHERE ErrorCode = @O_iErrorState
	   IF (@Error <> '')
       BEGIN print 'GL Line Error'
          UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))+@I_vACTNUMST 
		                            WHERE Reference = @I_vREFRENCE AND SeqNum = @SeqNum AND ID = @ID
       END
	   ELSE
	   BEGIN
	      UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 0, Error = '' 
		                            WHERE Reference = @I_vREFRENCE AND SeqNum = @SeqNum AND ID = @ID
	   END

	   FETCH NEXT FROM CUR2_1 INTO @SeqNum, @I_vACTNUMST, @I_vDSCRIPTN, @I_vCRDTAMNT, @I_vDEBITAMT
   END
   CLOSE CUR2_1
   DEALLOCATE CUR2_1
   IF NOT EXISTS (SELECT 1 FROM ##INT_GLSourceTable_Temp WHERE Reference = @I_vREFRENCE AND IntegrationStatus = 2 AND ID = @ID)
   BEGIN print 'final success updation'
       UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY,IntegrationStatus = 1, Error = '' WHERE Reference = @I_vREFRENCE
	                                                                                                            AND ID = @ID
   END     
   FETCH NEXT FROM CUR1_1 INTO @I_vREFRENCE
   END
   END
   CLOSE CUR1_1
   DEALLOCATE CUR1_1

   IF EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal')
   BEGIN
       SELECT @I_vDOCAMT = SUM(DEBITAMT)+SUM(CRDTAMNT) FROM GL10001 WHERE BACHNUMB = @I_vBACHNUMB
       IF (@I_vDOCAMT <> 0)
	        UPDATE SY00500 SET BCHTOTAL = @I_vDOCAMT WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'GL_Normal'
   END	
END
SET @QueryString = 
'UPDATE A SET A.JournalNumber = B.JournalNumber, A.IntegrationStatus = B.IntegrationStatus, A.Error = B.Error 
    FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_GLSourceTable A INNER JOIN ##INT_GLSourceTable_Temp B 
          ON A.SeqNum = B.SeqNum AND A.Reference = B.Reference AND B.ID = '''+CONVERT(VARCHAR(MAX),@ID)+''''

print @QueryString
EXECUTE (@QueryString)
--SELECT * FROM ##INT_GLSourceTable_Temp where ID = @ID
DELETE FROM ##INT_GLSourceTable_Temp where ID = @ID
END	

GO
