--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
USE Workflow_Estimates  

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-01-01 06:00:00.000'
SET @toDate = '2023-03-31 05:59:59.999'

IF OBJECT_ID('TEMPDB..#LinkedCompanies') IS NOT NULL DROP TABLE #LinkedCompanies
SELECT DISTINCT CT.collectionEntityId AS VersionID,CT.relatedCompanyId AS LinkedcompanyId
INTO #LinkedCompanies FROM WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK)
INNER JOIN Workflow_Estimates.[dbo].[CollectionStage_tbl] cst (NOLOCK) ON cst.collectionstageid = CT.collectionstageId
INNER JOIN Workflow_Estimates.[dbo].CollectionStageStatus_tbl csts (NOLOCK) ON csts.collectionStageStatusId=CT.collectionstageStatusId
WHERE
CT.collectionstageid IN (2)
AND CT.collectionstageStatusId IN (4)
AND CT.collectionEntityId IS NOT NULL AND CT.relatedCompanyId IS NOT NULL
AND CT.endDate >= @frDate AND CT.endDate <= @toDate


---SELECT * FROM #LinkedCompanies


IF OBJECT_ID('TEMPDB..#Companiescount') IS NOT NULL DROP TABLE #Companiescount
SELECT DISTINCT VersionID,COUNT(LinkedcompanyId) AS companycount INTO #Companiescount FROM #LinkedCompanies
GROUP BY VersionID
HAVING COUNT(LinkedcompanyId)>1
ORDER BY VersionID


SELECT DISTINCT VersionID FROM #Companiescount
