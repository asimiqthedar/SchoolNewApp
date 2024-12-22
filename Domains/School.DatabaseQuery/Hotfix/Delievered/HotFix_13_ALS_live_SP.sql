
alter PROCEDURE [dbo].[sp_GetInvoiceNo]  
as  
begin  
   
 update [dbo].[Transactions]  
 set TransactionNo=TransactionNo+1  
 where TransactionID=1  
  
 select TransactionNo as Result   
 from [dbo].[Transactions]  
 where TransactionID=1  

end  
GO