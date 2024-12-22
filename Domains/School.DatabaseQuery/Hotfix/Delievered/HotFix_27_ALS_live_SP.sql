CREATE PROCEDURE [dbo].[SP_GetStudentParentWise]  
 @ParentId bigint=0  
 ,@ParentName NVarChar(500)=null  
 ,@FatherIqama NVarChar(100)=null  
 ,@FatherMobile NVarChar(20)=null  
AS  
BEGIN  
 SELECT ts.StudentId  
  ,ts.StudentCode  
  ,ts.StudentName  
  ,tp.ParentId  
  ,tp.FatherName  
  ,tp.FatherIqamaNo  
  ,tp.FatherMobile  
 FROM tblStudent ts  
 INNER JOIN tblParent tp  
  ON ts.ParentId=tp.ParentId  
 WHERE tp.ParentId = CASE WHEN @ParentId>0 THEN @ParentId ELSE tp.ParentId END  
 AND tp.FatherName = CASE WHEN LEN(@ParentName)>0 THEN @ParentName ELSE tp.FatherName END  
 AND tp.FatherIqamaNo = CASE WHEN LEN(@FatherIqama)>0 THEN @FatherIqama ELSE tp.FatherIqamaNo END  
 AND tp.FatherMobile = CASE WHEN LEN(@FatherMobile)>0 THEN @FatherMobile ELSE tp.FatherMobile END  
END  
GO