--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
Use Estimates


DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate='2000-01-01 00:00:00.000'
SET @toDate='2024-07-30 23:59:59.999'


IF OBJECT_ID('TEMPDB..#BlankRating') IS NOT NULL DROP TABLE #BlankRating 
SELECT DISTINCT ED.versionId,ED.feedFileId,CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId,ED.effectiveDate AS FilingDate,EDND.dataItemId,EDND.dataItemValue
INTO #BlankRating
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
LEFT JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ISNULL(ED.feedFileId,ED.versionId) = CT.collectionEntityId ---AND CT.relatedCompanyId = ED.companyId
INNER JOIN  Estimates.[dbo].[EstFull_vw] EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl rd (NOLOCK) ON rd.researchcontributorid = ED.researchcontributorid
INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId
WHERE       CT.collectionEntityTypeId IN (9,51)
AND         CT.collectionstageStatusId IN (4)
--AND			CT.startDate IS NOT NULL
--AND			CT.endDate IS NOT NULL
--AND			rd.contributorShortName IS NOT NULL
AND         ED.effectiveDate >@frDate AND ED.effectiveDate < @toDate
AND         ED.researchcontributorid IN (356,409)
AND         EDND.dataItemId NOT IN (21625)

IF OBJECT_ID('TEMPDB..#Rating') IS NOT NULL DROP TABLE #Rating 
SELECT DISTINCT ED.versionId,ED.feedFileId,CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId,ED.effectiveDate AS FilingDate,EDND.dataItemId,EDND.dataItemValue
INTO #Rating
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
LEFT JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ISNULL(ED.feedFileId,ED.versionId) = CT.collectionEntityId ---AND CT.relatedCompanyId = ED.companyId
INNER JOIN  Estimates.[dbo].[EstFull_vw] EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl rd (NOLOCK) ON rd.researchcontributorid = ED.researchcontributorid
INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId
WHERE       CT.collectionEntityTypeId IN (9,51)
AND         CT.collectionstageStatusId IN (4)
--AND			CT.startDate IS NOT NULL
--AND			CT.endDate IS NOT NULL
--AND			rd.contributorShortName IS NOT NULL
AND         ED.effectiveDate >@frDate AND ED.effectiveDate < @toDate
AND         ED.researchcontributorid IN (356,409)
AND         EDND.dataItemId IN (21625)




SELECT DISTINCT versionId,feedFileId,researchcontributorid,contributorShortName,relatedCompanyId,FilingDate FROM #BlankRating
EXCEPT
SELECT DISTINCT versionId,feedFileId,researchcontributorid,contributorShortName,relatedCompanyId,FilingDate FROM #Rating ORDER BY FilingDate