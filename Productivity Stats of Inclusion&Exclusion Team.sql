----PYTHON & SQL ETL DEVELOPER - GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-07-20 00:00:00.000' 
SET @toDate = '2023-12-31 23:59:59.999' 

IF OBJECT_ID('tempdb..#Inclxclsn') IS NOT NULL DROP TABLE #Inclxclsn
SELECT DISTINCT CT.collectionEntityId AS versionId,cet.collectionEntityTypeName,CT.relatedCompanyId AS companyId,CT.collectionstageStatusId,CSST.collectionStageStatusName,cpt.collectionProcessName,CT.collectionProcessId,
CT.collectionstageId,cstt.collectionStageName,CT.endDate AS DoneDate,CONVERT(VARCHAR,CT.endDate,23) AS ProcessedDate
INTO #Inclxclsn FROM WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK)
INNER JOIN workflow_estimates.[dbo].[CollectionStage_tbl] cstt (NOLOCK) ON cstt.collectionstageId=CT.collectionstageId
INNER JOIN workflow_estimates.[dbo].[CollectionStageStatus_tbl] csst (NOLOCK) ON csst.collectionStageStatusId=CT.collectionstageStatusId
INNER JOIN workflow_estimates.[dbo].[CollectionProcess_tbl] cpt (NOLOCK) ON cpt.collectionProcessId=CT.collectionProcessId
INNER JOIN Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=CT.collectionEntityTypeId
WHERE CT.endDate>=@frDate AND CT.endDate<=@toDate
AND CT.collectionEntityId IS NOT NULL 
AND CT.collectionstageStatusId IN (4,5)
AND CT.collectionstageId IN (49)
AND CT.collectionProcessId IN (64)

---SELECT * FROM #Inclxclsn

IF OBJECT_ID('tempdb..#Final') IS NOT NULL DROP TABLE #Final
SELECT ProcessedDate,CollectionProcessName,CollectionStageName,CASE WHEN collectionstageStatusId=4 THEN COUNT(collectionstageStatusId) ELSE 0 END AS Processedd, 
CASE WHEN collectionstageStatusId=5 THEN COUNT(collectionstageStatusId) ELSE 0 END AS Skippedd,CASE WHEN collectionstageStatusId IN (4,5) THEN COUNT(collectionstageStatusId) ELSE 0 END AS Totall
INTO #Final FROM #Inclxclsn
GROUP BY ProcessedDate,collectionProcessName,collectionStageName,collectionstageStatusId

SELECT ProcessedDate,CollectionProcessName,CollectionStageName,SUM(Totall) AS Total,SUM(Processedd) AS Processed,SUM(Skippedd) AS Skipped FROM #Final
GROUP BY ProcessedDate,collectionProcessName,collectionStageName
ORDER BY ProcessedDate

