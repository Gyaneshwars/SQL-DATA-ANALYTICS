
--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE

USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2023-01-01 00:00:00.000'
SET @todate='2024-06-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#CITIDocs') IS NOT NULL DROP TABLE #CITIDocs 
SELECT DISTINCT CT.*,CONVERT(VARCHAR(10),insertedDate,101) Date2,cp.collectionProcessName,ED.effectiveDate,--vf.Description,v.formatID,
css.collectionStageStatusName,RD.researchcontributorid,
RD.contributorShortName INTO #CITIDocs
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
INNER JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ED.versionId = CT.collectionEntityId
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl RD (NOLOCK) ON RD.researchcontributorid = ED.researchcontributorid

--LEFT JOIN   DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId = CT.collectionEntityId
--INNER JOIN  DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID =v.formatID

INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId

WHERE       CT.collectionStageId IN (2)  AND CT.collectionProcessId IN (64,1062) AND CT.collectionEntityTypeId IN (9) AND CT.collectionstageStatusId IN (4,5)
AND         ((CT.insertedDate > = @frDate  AND CT.insertedDate <= @toDate) OR (ED.effectiveDate >= @frDate AND ED.effectiveDate <= @toDate))
AND         RD.researchcontributorid IN (3)
AND			CT.startDate IS NOT NULL
AND			CT.endDate IS NOT NULL
AND			RD.contributorShortName IS NOT NULL



--SELECT DISTINCT * FROM #CITIDocs

---Skipped
SELECT DISTINCT researchcontributorid,contributorShortName,collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,effectiveDate AS FilingDate,startDate,endDate,
DATEDIFF(MINUTE,startDate,endDate) AS Duration_Min,collectionStageStatusName FROM #CITIDocs 
WHERE collectionstageStatusId IN (5)
ORDER BY effectiveDate

---Processed
SELECT DISTINCT researchcontributorid,contributorShortName,collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,effectiveDate AS FilingDate,startDate,endDate,
DATEDIFF(MINUTE,startDate,endDate) AS Duration_Min,collectionStageStatusName FROM #CITIDocs 
WHERE collectionstageStatusId IN (4)
ORDER BY effectiveDate



