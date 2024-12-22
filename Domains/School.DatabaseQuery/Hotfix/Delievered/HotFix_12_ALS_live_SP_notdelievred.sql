--exec [SP_ItemCodeRecords]     'two'
ALTER PROCEDURE [dbo].[SP_ItemCodeRecords]     
 @UniformDB nvarchar(100)  
as      
begin      
  
 DECLARE @Query nvarchar(max)  
 --DECLARE @ParmDefinition NVARCHAR(500);  
  
 --/* Build the SQL string once */  
 --SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,    
 -- isnull(nullif(ltrim(rtrim(LOCNCODE)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription    
 -- from '+@UniformDB+'.[dbo].IV00102 where LOCNCODE=''''' ;  
 ----SET @ParmDefinition = N'@UniformDBinput nvarchar(500)';  
 --/* Execute the string with the first parameter value. */  

   --Production 
   SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,    
  isnull(nullif(ltrim(rtrim(ITEMDESC)),''''),ltrim(rtrim(ITEMNMBR))) +'' - ''+ ltrim(rtrim(ITEMNMBR)) as ItemCodeDescription    
  from '+@UniformDB+'.[dbo].IV00101 where LOCNCODE=''''' ;  
                                                                                       
  --select * from two.dbo.IV00101
 EXECUTE sp_executesql @Query; 
  
end 
go
