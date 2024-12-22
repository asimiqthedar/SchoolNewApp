  
CREATE PROCEDURE INT_CreateSalesInvoiceInGP @CallFrom INT = 0, @SourceDB CHAR(30) = '', @DestDB CHAR(30) = '',  
                                            @FromDate Datetime = '01/01/1900', @ToDate Datetime = '01/01/1900'   
AS  
BEGIN  
  
DECLARE @ID varchar(50) SET @ID = NEWID() print @ID  
IF OBJECT_ID('tempdb..##INT_SalesInvoiceSourceTable_Temp','U') IS NULL  
    create table ##INT_SalesInvoiceSourceTable_Temp  
    (  
 [ID] [varchar](50) NOT NULL,   
 [SeqNum] [int] NOT NULL,  
 [SOPNumber] [char](21) NOT NULL,  
 [SOPType] [smallint] NOT NULL,  
 [DocID] [char](15) NULL,  
 [DocDate] [datetime] NULL,  
 [CustomerNumber] [char](15) NULL,  
 [ItemNumber] [char](30) NULL,  
 [Quantity] [numeric](19, 5) NULL,  
 [UnitPrice] [numeric](19, 5) NULL,  
 [IntegrationStatus] [smallint] NOT NULL,  
 [Error] [varchar](max) NULL  
 )  
IF OBJECT_ID('tempdb..##INT_SalesPaymentSourceTable_Temp', 'U') IS NULL  
    create table ##INT_SalesPaymentSourceTable_Temp  
    (  
 [ID] [varchar](50) NOT NULL,   
 [SeqNum] [int] NOT NULL,  
 [SOPNumber] [char](21) NOT NULL,  
 [SOPType] [smallint] NOT NULL,  
 [PaymentType] [int] NULL,  
 [PaymentAmount] [numeric](19, 5) NULL,  
 [CheckbookID] [char](15) NULL,  
 [CardName] [char](15) NULL,  
 [CheckNumber] [char](20) NULL,  
 [CreditCardNumber] [char](20) NULL,  
 [AuthorizationCode] [char](15) NULL,  
 [ExpirationDate] [datetime] NULL,  
 [IntegrationStatus] [smallint] NOT NULL,  
 [Error] [varchar](max) NULL  
 )  
IF OBJECT_ID('tempdb..##INT_SalesDistributionSourceTable_Temp', 'U') IS NULL  
    create table ##INT_SalesDistributionSourceTable_Temp  
    (  
 [ID] [varchar](50) NOT NULL,  
 [SeqNum] [int] NOT NULL,  
 [SOPNumber] [char](21) NOT NULL,  
 [SOPType] [smallint] NOT NULL,  
 [DistType] [smallint] NOT NULL,  
 [AccountNumber] [char](75) NOT NULL,  
 [DebitAmount] [numeric](19, 5) NOT NULL,  
 [CreditAmount] [numeric](19, 5) NOT NULL,  
 [DistributionRef] [char](30) NULL,  
 [IntegrationStatus] [smallint] NOT NULL,  
 [Error] [varchar](max) NULL  
 )  
  
DECLARE @QueryString VARCHAR(MAX) = ''  
IF(@CallFrom = 0)/******** Call from SQL Job ********/  
BEGIN  
SET @QueryString =   
'INSERT INTO ##INT_SalesInvoiceSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)   
   SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error   
      FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK) WHERE IntegrationStatus = 0  
  
INSERT INTO ##INT_SalesPaymentSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,  
  AuthorizationCode,ExpirationDate,IntegrationStatus,Error)   
  SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,  
  AuthorizationCode,ExpirationDate,IntegrationStatus,Error FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesPaymentSourceTable(NOLOCK)   
      WHERE IntegrationStatus = 0 AND SOPNumber+CONVERT(CHAR(1),SOPType) IN   
      (SELECT DISTINCT SOPNumber+CONVERT(CHAR(1),SOPType) FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK)   
           WHERE IntegrationStatus = 0)  
  
INSERT INTO ##INT_SalesDistributionSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,  
     IntegrationStatus,Error)   
  SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,  
  IntegrationStatus,Error FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesDistributionSourceTable(NOLOCK)   
      WHERE IntegrationStatus = 0 AND SOPNumber+CONVERT(CHAR(1),SOPType) IN   
      (SELECT DISTINCT SOPNumber+CONVERT(CHAR(1),SOPType) FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK)   
           WHERE IntegrationStatus = 0)'  
END  
ELSE/****** Call from UI ********/  
BEGIN  
SET @QueryString =   
'INSERT INTO ##INT_SalesInvoiceSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)   
   SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error   
      FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK)   
   WHERE IntegrationStatus IN (0,2) AND DocDate BETWEEN '''+CONVERT(VARCHAR,@FromDate)+''' AND '''+CONVERT(VARCHAR,@ToDate)+'''    
  
INSERT INTO ##INT_SalesPaymentSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,  
  AuthorizationCode,ExpirationDate,IntegrationStatus,Error)   
  SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,  
  AuthorizationCode,ExpirationDate,IntegrationStatus,Error FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesPaymentSourceTable(NOLOCK)   
      WHERE IntegrationStatus IN (0,2) AND SOPNumber+CONVERT(CHAR(1),SOPType) IN   
      (SELECT DISTINCT SOPNumber+CONVERT(CHAR(1),SOPType) FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK)   
           WHERE IntegrationStatus IN (0,2) AND DocDate BETWEEN '''+CONVERT(VARCHAR,@FromDate)+''' AND '''+CONVERT(VARCHAR,@ToDate)+''')  
       
INSERT INTO ##INT_SalesDistributionSourceTable_Temp (ID,SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,  
     IntegrationStatus,Error)   
  SELECT '''+CONVERT(VARCHAR(MAX),@ID)+''',SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,  
  IntegrationStatus,Error FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesDistributionSourceTable(NOLOCK)   
      WHERE IntegrationStatus IN (0,2) AND SOPNumber+CONVERT(CHAR(1),SOPType) IN   
      (SELECT DISTINCT SOPNumber+CONVERT(CHAR(1),SOPType) FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable(NOLOCK)   
           WHERE IntegrationStatus IN (0,2) AND DocDate BETWEEN '''+CONVERT(VARCHAR,@FromDate)+''' AND '''+CONVERT(VARCHAR,@ToDate)+''')'  
END  
PRINT @QueryString  
EXECUTE (@QueryString)  
  
DECLARE @RT INT = 0,   
        @I_vBACHNUMB CHAR(15) = '',   
  @I_vSERIES INT = 3,   
  @I_vBCHSOURC CHAR(15) = 'Sales Entry',  
        @I_vDOCAMT NUMERIC(19,5) = 0,   
  @I_vORIGIN INT = 1,   
  @I_vNUMOFTRX INT = 0,   
  @I_vTRXSOURC CHAR(25) = '',  
  @I_vSOPTYPE SMALLINT = 3,   
  @I_vDOCID CHAR(15) = '',   
  @I_vSOPNUMBE CHAR(21) = '',  
        @I_vDOCDATE DATE = '01/01/1900',   
  @I_vCUSTNMBR CHAR(15)= '',   
  @I_vITEMNMBR CHAR(30) = '',   
  @I_vQUANTITY NUMERIC(19,5) = 0,   
  @I_vUNITPRCE NUMERIC(19,5) = 0,   
  @I_vXTNDPRCE NUMERIC(19,5) = 0,   
  @I_vUpdateIfExists SMALLINT = 1,  
  @I_vCREATETAXES SMALLINT = 1,   
  @I_vCREATEDIST SMALLINT = 0,  
  @I_vUpdateExisting SMALLINT = 1,  
  @I_vDOCAMNT NUMERIC(19,5) = 0,   
  @I_vCHEKBKID CHAR(15) = '',  
  @I_vCARDNAME CHAR(15) = '',   
  @I_vCHEKNMBR CHAR(20) = '',   
  @I_vRCTNCCRD CHAR(20) = '',  
        @I_vAUTHCODE CHAR(15) = '',   
  @I_vEXPNDATE DATE = '01/01/1900',  
  @I_vPYMTTYPE INT = 4,   
  @I_vAction SMALLINT = 1,  
  @SeqNum INT = 0,  
  @I_vQTYONHND NUMERIC(19,5) = 0,  
  @I_vQTYRTRND NUMERIC(19,5) = 0,  
  @I_vQTYINUSE NUMERIC(19,5) = 0,  
  @I_vQTYINSVC NUMERIC(19,5) = 0,  
  @I_vQTYDMGED NUMERIC(19,5) = 0,  
  @I_vDISTTYPE SMALLINT = 0,   
  @I_vACTNUMST VARCHAR(75) = '',   
  @I_vDEBITAMT NUMERIC(19,5) = 0.00,   
  @I_vCRDTAMNT NUMERIC(19,5) = 0,  
  @I_vDistRef CHAR(30) = '',   
  @O_iErrorState INT = 0,   
  @oErrString varchar(255) = '',  
  @Error VARCHAR(MAX) = ''  
  
SET @I_vBACHNUMB = 'INT_'+FORMAT(GETDATE(),'yyyyMMdd')   
PRINT 'Batch Number: '+@I_vBACHNUMB  
  
IF (@CallFrom = 0)/******** Call from SQL Job ********/  
BEGIN  
   DECLARE CUR1 CURSOR FOR SELECT DISTINCT SOPNumber,SOPType FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 0  
        AND ID = @ID  
   OPEN CUR1 FETCH NEXT FROM CUR1 INTO @I_vSOPNUMBE, @I_vSOPTYPE  
   WHILE @@FETCH_STATUS = 0  
   BEGIN  
   IF NOT EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'Sales Entry')  
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
         
    SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
       BEGIN print 'Batch Creation Error'   
          UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = @Error WHERE SOPNumber = @I_vSOPNUMBE  
                                                                 AND SOPType = @I_vSOPTYPE AND ID = @ID  
       END  
    END  
  
 SELECT TOP 1 @I_vDOCID = DocID, @I_vDOCDATE = DocDate, @I_vCUSTNMBR = CustomerNumber    
      FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND IntegrationStatus = 0  
      AND ID = @ID  
  
    EXECUTE @RT = [dbo].[taSopHdrIvcInsert]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vDOCID = @I_vDOCID,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vDOCDATE = @I_vDOCDATE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vBACHNUMB = @I_vBACHNUMB,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
     SET @Error = ''  
  SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
  IF (@Error <> '')  
     BEGIN print 'Create Header Error'  
          UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error)) WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                 AND SOPType = @I_vSOPTYPE AND ID = @ID  
     END  
  
     DECLARE CUR2 CURSOR FOR SELECT SeqNum, ItemNumber, ISNULL(Quantity,0), ISNULL(UnitPrice,0.00)   
                                FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                              AND ID = @ID  
     OPEN CUR2 FETCH NEXT FROM CUR2 INTO @SeqNum, @I_vITEMNMBR, @I_vQUANTITY, @I_vUNITPRCE  
     WHILE @@FETCH_STATUS = 0  
     BEGIN  
       SET @I_vXTNDPRCE = @I_vQUANTITY * @I_vUNITPRCE  
    IF (@I_vSOPTYPE = 4)  
        SET @I_vQTYRTRND = @I_vQUANTITY  
          ELSE  
        SET @I_vQTYRTRND = 0  
       EXECUTE @RT = [dbo].[taSopLineIvcInsert]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vDOCDATE = @I_vDOCDATE,  
      @I_vITEMNMBR = @I_vITEMNMBR,   
      @I_vQUANTITY = @I_vQUANTITY,  
      @I_vUNITPRCE = @I_vUNITPRCE,  
      @I_vXTNDPRCE = @I_vXTNDPRCE,  
      @I_vQTYONHND = @I_vQTYONHND,  
      @I_vQTYRTRND = @I_vQTYRTRND,  
      @I_vQTYINUSE = @I_vQTYINUSE,  
      @I_vQTYINSVC = @I_vQTYINSVC,  
      @I_vQTYDMGED = @I_vQTYDMGED,   
      @I_vUpdateIfExists = @I_vUpdateIfExists,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
       SET @Error = ''   
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
       IF (@Error <> '')  
          BEGIN print 'Create Invoice Line Error'  
              UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))   
                                                    WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                      AND ID = @ID  
          END  
  
    FETCH NEXT FROM CUR2 INTO @SeqNum, @I_vITEMNMBR, @I_vQUANTITY, @I_vUNITPRCE  
     END  
     CLOSE CUR2  
     DEALLOCATE CUR2  
  
  DECLARE CUR3 CURSOR FOR SELECT SeqNum, PaymentType, ISNULL(PaymentAmount,0), ISNULL(CheckbookID,''), ISNULL(CardName,''),ISNULL(CheckNumber,''),  
                           ISNULL(CreditCardNumber,''), ISNULL(AuthorizationCode,''), ISNULL(ExpirationDate,'01/01/1900')   
                            FROM ##INT_SalesPaymentSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                             AND ID = @ID  
     OPEN CUR3 FETCH NEXT FROM CUR3 INTO @SeqNum, @I_vPYMTTYPE, @I_vDOCAMNT, @I_vCHEKBKID, @I_vCARDNAME, @I_vCHEKNMBR, @I_vRCTNCCRD, @I_vAUTHCODE, @I_vEXPNDATE  
     WHILE @@FETCH_STATUS = 0  
     BEGIN   
      EXECUTE @RT = [dbo].[taCreateSopPaymentInsertRecord]  
          @I_vSOPTYPE = @I_vSOPTYPE,  
     @I_vSOPNUMBE = @I_vSOPNUMBE,  
     @I_vCUSTNMBR = @I_vCUSTNMBR,  
     @I_vDOCDATE = @I_vDOCDATE,  
     @I_vDOCAMNT = @I_vDOCAMNT,  
     @I_vCHEKBKID = @I_vCHEKBKID,  
     @I_vCARDNAME = @I_vCARDNAME,  
     @I_vCHEKNMBR = @I_vCHEKNMBR,  
     @I_vRCTNCCRD = @I_vRCTNCCRD,  
     @I_vAUTHCODE = @I_vAUTHCODE,  
     @I_vEXPNDATE = @I_vEXPNDATE,  
     @I_vPYMTTYPE = @I_vPYMTTYPE,  
     @I_vAction = @I_vAction,  
     @O_iErrorState = @O_iErrorState OUTPUT,  
     @oErrString = @oErrString OUTPUT   
          SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
          BEGIN print 'payment line error'  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
         FETCH NEXT FROM CUR3 INTO @SeqNum, @I_vPYMTTYPE, @I_vDOCAMNT, @I_vCHEKBKID, @I_vCARDNAME, @I_vCHEKNMBR, @I_vRCTNCCRD, @I_vAUTHCODE, @I_vEXPNDATE  
  END  
  CLOSE CUR3  
     DEALLOCATE CUR3  
  
  DELETE FROM SOP10102 WHERE SOPNUMBE = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE  
  
  DECLARE CUR4 CURSOR FOR SELECT SeqNum, DistType, ltrim(rtrim(AccountNumber)), ISNULL(DebitAmount,0.00), ISNULL(CreditAmount,0.00),  
                          ISNULL(DistributionRef,'')   
                             FROM ##INT_SalesDistributionSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                             AND ID = @ID  
     OPEN CUR4 FETCH NEXT FROM CUR4 INTO @SeqNum, @I_vDISTTYPE, @I_vACTNUMST, @I_vDEBITAMT, @I_vCRDTAMNT, @I_vDistRef  
     WHILE @@FETCH_STATUS = 0  
     BEGIN   
          EXECUTE @RT = [dbo].[taSopDistribution]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vDISTTYPE = @I_vDISTTYPE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vACTNUMST = @I_vACTNUMST,  
      @I_vDEBITAMT = @I_vDEBITAMT,  
      @I_vCRDTAMNT = @I_vCRDTAMNT,  
      @I_vDistRef = @I_vDistRef,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
  
          SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
          BEGIN   
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
         FETCH NEXT FROM CUR4 INTO @SeqNum, @I_vDISTTYPE, @I_vACTNUMST, @I_vDEBITAMT, @I_vCRDTAMNT, @I_vDistRef  
  END  
  CLOSE CUR4  
     DEALLOCATE CUR4  
  
 --EXECUTE @RT = [dbo].[taSopHdrIvcInsert]  
 --     @I_vSOPTYPE = @I_vSOPTYPE,  
 --     @I_vDOCID = @I_vDOCID,  
 --     @I_vSOPNUMBE = @I_vSOPNUMBE,  
 --     @I_vDOCDATE = @I_vDOCDATE,  
 --     @I_vCUSTNMBR = @I_vCUSTNMBR,  
 --     @I_vBACHNUMB = @I_vBACHNUMB,  
 --     @I_vCREATETAXES = @I_vCREATETAXES,  
 --     @I_vUpdateExisting = @I_vUpdateExisting,  
 --     @O_iErrorState = @O_iErrorState OUTPUT,  
 --     @oErrString = @oErrString OUTPUT  
 --   SET @Error = ''  
 --SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
 --IF (@Error <> '')  
 --   BEGIN print 'Header Tax Error'   
 --         UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))  
 --                                                WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID  
 --   END  
  
 IF (EXISTS(SELECT 1 FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID)  
 OR EXISTS(SELECT 1 FROM ##INT_SalesPaymentSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID)  
 OR EXISTS(SELECT 1 FROM ##INT_SalesDistributionSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID))  
 BEGIN print 'delete' print @I_vSOPNUMBE  
      EXECUTE @RT = [dbo].[taSopDeleteDocument]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
   
         UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
 END  
 ELSE  
 BEGIN print 'final update no error' print @I_vSOPNUMBE  
      UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
 END  
 FETCH NEXT FROM CUR1 INTO @I_vSOPNUMBE, @I_vSOPTYPE  
    END  
    CLOSE CUR1  
    DEALLOCATE CUR1  
END  
ELSE/****** Call from UI ********/  
BEGIN  
   DECLARE CUR1_1 CURSOR FOR SELECT DISTINCT SOPNumber,SOPType FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK)   
                                   WHERE IntegrationStatus IN (0,2) AND DocDate BETWEEN @FromDate AND @ToDate AND ID = @ID  
   OPEN CUR1_1 FETCH NEXT FROM CUR1_1 INTO @I_vSOPNUMBE, @I_vSOPTYPE  
   WHILE @@FETCH_STATUS = 0  
   BEGIN  
   IF NOT EXISTS(SELECT 1 FROM SY00500(NOLOCK) WHERE BACHNUMB = @I_vBACHNUMB AND BCHSOURC = 'Sales Entry')  
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
         
    SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
       BEGIN print 'Batch Creation Error'   
          UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = @Error WHERE SOPNumber = @I_vSOPNUMBE  
                                                                 AND SOPType = @I_vSOPTYPE AND ID = @ID  
       END  
    END  
  
 SELECT TOP 1 @I_vDOCID = DocID, @I_vDOCDATE = DocDate, @I_vCUSTNMBR = CustomerNumber    
      FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                         AND ID = @ID  
  
    EXECUTE @RT = [dbo].[taSopHdrIvcInsert]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vDOCID = @I_vDOCID,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vDOCDATE = @I_vDOCDATE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vBACHNUMB = @I_vBACHNUMB,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
     SET @Error = ''  
  SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
  IF (@Error <> '')  
     BEGIN print 'Create Header Error'  
          UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))   
                                                 WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID  
     END  
  
     DECLARE CUR2_1 CURSOR FOR SELECT SeqNum, ItemNumber, ISNULL(Quantity,0), ISNULL(UnitPrice,0.00)   
                                FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                              AND ID = @ID  
     OPEN CUR2_1 FETCH NEXT FROM CUR2_1 INTO @SeqNum, @I_vITEMNMBR, @I_vQUANTITY, @I_vUNITPRCE  
     WHILE @@FETCH_STATUS = 0  
     BEGIN  
       SET @I_vXTNDPRCE = @I_vQUANTITY * @I_vUNITPRCE  
    IF (@I_vSOPTYPE = 4)  
        SET @I_vQTYRTRND = @I_vQUANTITY  
          ELSE  
        SET @I_vQTYRTRND = 0  
       EXECUTE @RT = [dbo].[taSopLineIvcInsert]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vDOCDATE = @I_vDOCDATE,  
      @I_vITEMNMBR = @I_vITEMNMBR,   
      @I_vQUANTITY = @I_vQUANTITY,  
      @I_vUNITPRCE = @I_vUNITPRCE,  
      @I_vXTNDPRCE = @I_vXTNDPRCE,  
      @I_vQTYONHND = @I_vQTYONHND,  
      @I_vQTYRTRND = @I_vQTYRTRND,  
      @I_vQTYINUSE = @I_vQTYINUSE,  
      @I_vQTYINSVC = @I_vQTYINSVC,  
      @I_vQTYDMGED = @I_vQTYDMGED,   
      @I_vUpdateIfExists = @I_vUpdateIfExists,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
       SET @Error = ''   
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
       IF (@Error <> '')  
          BEGIN print 'Create Invoice Line Error'  
              UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))   
                                                    WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                      AND ID = @ID  
          END  
    ELSE  
    BEGIN   
              UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 0, Error = ''   
                                                    WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                      AND ID = @ID  
          END  
  
    FETCH NEXT FROM CUR2_1 INTO @SeqNum, @I_vITEMNMBR, @I_vQUANTITY, @I_vUNITPRCE  
     END  
     CLOSE CUR2_1  
     DEALLOCATE CUR2_1  
  
  DECLARE CUR3_1 CURSOR FOR SELECT SeqNum, PaymentType, ISNULL(PaymentAmount,0), ISNULL(CheckbookID,''), ISNULL(CardName,''),ISNULL(CheckNumber,''),  
                           ISNULL(CreditCardNumber,''), ISNULL(AuthorizationCode,''), ISNULL(ExpirationDate,'01/01/1900')   
                      FROM ##INT_SalesPaymentSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                             AND ID = @ID  
     OPEN CUR3_1 FETCH NEXT FROM CUR3_1 INTO @SeqNum, @I_vPYMTTYPE, @I_vDOCAMNT, @I_vCHEKBKID, @I_vCARDNAME, @I_vCHEKNMBR, @I_vRCTNCCRD, @I_vAUTHCODE, @I_vEXPNDATE  
     WHILE @@FETCH_STATUS = 0  
     BEGIN   
      EXECUTE @RT = [dbo].[taCreateSopPaymentInsertRecord]  
          @I_vSOPTYPE = @I_vSOPTYPE,  
     @I_vSOPNUMBE = @I_vSOPNUMBE,  
     @I_vCUSTNMBR = @I_vCUSTNMBR,  
     @I_vDOCDATE = @I_vDOCDATE,  
     @I_vDOCAMNT = @I_vDOCAMNT,  
     @I_vCHEKBKID = @I_vCHEKBKID,  
     @I_vCARDNAME = @I_vCARDNAME,  
     @I_vCHEKNMBR = @I_vCHEKNMBR,  
     @I_vRCTNCCRD = @I_vRCTNCCRD,  
     @I_vAUTHCODE = @I_vAUTHCODE,  
     @I_vEXPNDATE = @I_vEXPNDATE,  
     @I_vPYMTTYPE = @I_vPYMTTYPE,  
     @I_vAction = @I_vAction,  
     @O_iErrorState = @O_iErrorState OUTPUT,  
     @oErrString = @oErrString OUTPUT   
          SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
          BEGIN print 'payment line error'  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
    ELSE  
    BEGIN   
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 0, Error = ''  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
         FETCH NEXT FROM CUR3_1 INTO @SeqNum, @I_vPYMTTYPE, @I_vDOCAMNT, @I_vCHEKBKID, @I_vCARDNAME, @I_vCHEKNMBR, @I_vRCTNCCRD, @I_vAUTHCODE, @I_vEXPNDATE  
  END  
  CLOSE CUR3_1  
     DEALLOCATE CUR3_1  
  
  DELETE FROM SOP10102 WHERE SOPNUMBE = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE  
  
  DECLARE CUR4_1 CURSOR FOR SELECT SeqNum, DistType, ltrim(rtrim(AccountNumber)), ISNULL(DebitAmount,0.00), ISNULL(CreditAmount,0.00),  
                          ISNULL(DistributionRef,'')   
                             FROM ##INT_SalesDistributionSourceTable_Temp(NOLOCK) WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE   
                                                             AND ID = @ID  
     OPEN CUR4_1 FETCH NEXT FROM CUR4_1 INTO @SeqNum, @I_vDISTTYPE, @I_vACTNUMST, @I_vDEBITAMT, @I_vCRDTAMNT, @I_vDistRef  
     WHILE @@FETCH_STATUS = 0  
     BEGIN   
          EXECUTE @RT = [dbo].[taSopDistribution]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @I_vDISTTYPE = @I_vDISTTYPE,  
      @I_vCUSTNMBR = @I_vCUSTNMBR,  
      @I_vACTNUMST = @I_vACTNUMST,  
      @I_vDEBITAMT = @I_vDEBITAMT,  
      @I_vCRDTAMNT = @I_vCRDTAMNT,  
      @I_vDistRef = @I_vDistRef,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
  
          SET @Error = ''  
    SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
    IF (@Error <> '')  
          BEGIN print 'distribution line error'  
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(isnull(Error,''))) + ltrim(rtrim(@Error))  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
    ELSE  
    BEGIN   
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 0, Error = ''  
                                           WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND SeqNum = @SeqNum  
                   AND ID = @ID  
          END  
         FETCH NEXT FROM CUR4_1 INTO @SeqNum, @I_vDISTTYPE, @I_vACTNUMST, @I_vDEBITAMT, @I_vCRDTAMNT, @I_vDistRef  
  END  
  CLOSE CUR4_1  
     DEALLOCATE CUR4_1  
      
 --EXECUTE @RT = [dbo].[taSopHdrIvcInsert]  
 --     @I_vSOPTYPE = @I_vSOPTYPE,  
 --     @I_vDOCID = @I_vDOCID,  
 --     @I_vSOPNUMBE = @I_vSOPNUMBE,  
 --     @I_vDOCDATE = @I_vDOCDATE,  
 --     @I_vCUSTNMBR = @I_vCUSTNMBR,  
 --     @I_vBACHNUMB = @I_vBACHNUMB,  
 --     @I_vCREATETAXES = @I_vCREATETAXES,  
 --     @I_vUpdateExisting = @I_vUpdateExisting,  
 --     @O_iErrorState = @O_iErrorState OUTPUT,  
 --     @oErrString = @oErrString OUTPUT  
 --   SET @Error = ''  
 --SELECT @Error = ErrorDesc FROM DYNAMICS..taErrorCode(NOLOCK) WHERE ErrorCode = @O_iErrorState  
 --IF (@Error <> '')  
 --   BEGIN print 'Header Tax Error'   
 --         UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))  
 --                                                WHERE SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID  
 --   END  
  
 IF (EXISTS(SELECT 1 FROM ##INT_SalesInvoiceSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID)  
 OR EXISTS(SELECT 1 FROM ##INT_SalesPaymentSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID)  
 OR EXISTS(SELECT 1 FROM ##INT_SalesDistributionSourceTable_Temp(NOLOCK) WHERE IntegrationStatus = 2 AND SOPNumber = @I_vSOPNUMBE AND SOPType = @I_vSOPTYPE AND ID = @ID))  
 BEGIN print 'delete' print @I_vSOPNUMBE  
      EXECUTE @RT = [dbo].[taSopDeleteDocument]  
      @I_vSOPTYPE = @I_vSOPTYPE,  
      @I_vSOPNUMBE = @I_vSOPNUMBE,  
      @O_iErrorState = @O_iErrorState OUTPUT,  
      @oErrString = @oErrString OUTPUT  
   
         UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 2 WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
 END  
 ELSE  
 BEGIN print 'final update no error' print @I_vSOPNUMBE  
      UPDATE ##INT_SalesInvoiceSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesPaymentSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
         UPDATE ##INT_SalesDistributionSourceTable_Temp SET IntegrationStatus = 1, Error = '' WHERE SOPNumber = @I_vSOPNUMBE  
                                                                                    AND SOPType = @I_vSOPTYPE AND ID = @ID  
 END  
 FETCH NEXT FROM CUR1_1 INTO @I_vSOPNUMBE, @I_vSOPTYPE  
    END  
    CLOSE CUR1_1  
    DEALLOCATE CUR1_1  
END  
SET @QueryString =   
'UPDATE A SET A.IntegrationStatus = B.IntegrationStatus, A.Error = B.Error   
    FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesInvoiceSourceTable A INNER JOIN ##INT_SalesInvoiceSourceTable_Temp B   
          ON A.SeqNum = B.SeqNum AND A.SOPNumber  collate SQL_Latin1_General_CP1256_CI_AS= B.SOPNumber AND A.SOPType = B.SOPType AND B.ID = '''+CONVERT(VARCHAR(MAX),@ID)+'''   
  
UPDATE A SET A.IntegrationStatus = B.IntegrationStatus, A.Error = B.Error   
    FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesPaymentSourceTable A INNER JOIN ##INT_SalesPaymentSourceTable_Temp B   
          ON A.SeqNum = B.SeqNum AND A.SOPNumber  collate SQL_Latin1_General_CP1256_CI_AS= B.SOPNumber AND A.SOPType = B.SOPType AND B.ID = '''+CONVERT(VARCHAR(MAX),@ID)+'''  
      
UPDATE A SET A.IntegrationStatus = B.IntegrationStatus, A.Error = B.Error   
    FROM '+LTRIM(RTRIM(@SourceDB))+'.dbo.INT_SalesDistributionSourceTable A INNER JOIN ##INT_SalesDistributionSourceTable_Temp B   
          ON A.SeqNum = B.SeqNum AND A.SOPNumber collate SQL_Latin1_General_CP1256_CI_AS= B.SOPNumber AND A.SOPType = B.SOPType AND B.ID = '''+CONVERT(VARCHAR(MAX),@ID)+''''  
print @QueryString  
EXECUTE (@QueryString)  
  
delete from ##INT_SalesInvoiceSourceTable_Temp where ID = @ID  
delete from ##INT_SalesPaymentSourceTable_Temp where ID = @ID  
delete from ##INT_SalesDistributionSourceTable_Temp where ID = @ID  
END  
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
  @I_vJRNENTRY INT = 0, @I_vREFRENCE CHAR(30) = 0, @I_vTRXDATE DATETIME = '01/01/1900',   
        @I_vRVRSNGDT DATETIME = '01/01/1900', @I_vTRXTYPE SMALLINT = 0, -- 0 for Standard and 1 for Reversing  
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
     UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))   
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
     UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))   
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
     UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))+@I_vACTNUMST  
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
       UPDATE ##INT_GLSourceTable_Temp SET IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))   
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
          UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))   
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
          UPDATE ##INT_GLSourceTable_Temp SET JournalNumber = @I_vJRNENTRY, IntegrationStatus = 2, Error = ltrim(rtrim(Error)) + ltrim(rtrim(@Error))+@I_vACTNUMST   
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
DELETE FROM ##INT_GLSourceTable_Temp where ID = @ID  
END   
Go

