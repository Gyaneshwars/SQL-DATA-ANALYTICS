--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME

SET @frDate = '2024-03-01 06:00:00.000' ----FROM DATE
SET @toDate = '2024-03-31 05:59:59.999' ----TO DATE

IF OBJECT_ID('TEMPDB..#ExclsnInclsn') IS NOT NULL DROP TABLE #ExclsnInclsn
SELECT DISTINCT ED.researchContributorId,Contributor=dbo.researchcontributorname_fn(ED.researchContributorId),ED.companyId,CIM.CompanyName,
DataitemName=dbo.dataitemname_fn(EF.dataitemid),ED.versionId,ED.feedFileId,FORMAT(CAST(EE.lastmodifiedutcdatetime AS DATE),'yyyy-MM-dd') AS DoneDate,
EE.fromdate,CASE WHEN ISNULL(sect.COMMENT,'')='' THEN EE.REASON ELSE SECT.COMMENT END [exclusioncomment],
UT.EmployeeNumber AS EmpID,UT.firstName + ' '+ UT.lastName AS EmpName INTO #ExclsnInclsn FROM EstimateDetail_tbl ED
INNER JOIN  EstFull_vw EF (NOLOCK) ON EF.estimateDetailId = ED.estimateDetailId
INNER JOIN  EstimatePeriod_tbl EP (NOLOCK) ON EP.estimatePeriodId =ED.estimatePeriodId
INNER JOIN  CompanyMaster.dbo.CompanyInfoMaster CIM (NOLOCK) ON CIM.CIQCompanyId = ED.companyid
LEFT JOIN   EstimateExclusion_tbl EE (NOLOCK) ON EE.estimateDetailId=EF.estimateDetailId and EE.dataItemId=EF.dataItemId
LEFT JOIN   Estimates.dbo.EstimateExclusionStandardizedComment_tbl EESCT (NOLOCK) ON EE.estimateExclusionId = EESCT.estimateExclusionId
LEFT JOIN   Estimates.dbo.StandardizedExclusionComment_tbl SECT (NOLOCK) ON  EESCT.standardizedExclusionCommentId = SECT.standardizedExclusionCommentId
INNER JOIN  CTAdminRepTables.[dbo].[user_tbl] UT (NOLOCK) ON ee.UserID=UT.UserID
WHERE       UT.EmployeeNumber IN ('000832','000907','C06016','107043','406033','907004','B06045')
AND         EE.lastmodifiedutcdatetime>=@frDate AND EE.lastmodifiedutcdatetime<=@toDate

IF OBJECT_ID('TEMPDB..#e') IS NOT NULL DROP TABLE #e  
SELECT DISTINCT companyid,CompanyName,DataitemName,COUNT(DISTINCT Contributor) CountOfContributor,EmpID,EmpName,
CASE WHEN EmpID IN ('B06045','406033','907004') THEN 'Closed Events' ELSE 'Announced Events' END Process INTO #e FROM #ExclsnInclsn
WHERE EmpID IN ('000832','000907','C06016','107043','406033','907004','B06045')
--empname IN ('Mallesh Narra','Chennakeshava Prasad Malasani','Santhosh Kumar Methuku','Veena Laljani','Jhanvi Ruparel') 
GROUP BY companyid,CompanyName,DataitemName,EmpID,EmpName


SELECT Process,EmpID,EmpName,SUM(CountOfContributor) AS Total_Count FROM #e GROUP BY Process,EmpID,EmpName