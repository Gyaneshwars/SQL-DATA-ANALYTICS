
--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE

USE Estimates

---Please enter Min CompanyId,Max CompanyId & @researchcontributorid details below
DECLARE @minEffectiveDateCompanyId AS BIGINT,@maxEffectiveDateCompanyId AS BIGINT,@researchcontributorid AS BIGINT
SET @researchcontributorid = 2953

SET @minEffectiveDateCompanyId = 42083601
SET @maxEffectiveDateCompanyId = 42083601

---Please enter minEffectiveDateCompanyId details(I.E. FilingDate Range)
DECLARE @minEffectiveDatefrDate AS DATETIME, @minEffectiveDatetoDate AS DATETIME
SET @minEffectiveDatefrDate='2023-09-15 00:00:00.000'
SET @minEffectiveDatetoDate='2023-10-30 23:59:59.999'

---Please enter maxEffectiveDateCompanyId details(I.E. FilingDate Range)
DECLARE @maxEffectiveDatefrDate AS DATETIME, @maxEffectiveDatetoDate AS DATETIME
SET @maxEffectiveDatefrDate='2024-04-01 00:00:00.000'
SET @maxEffectiveDatetoDate='2024-04-25 23:59:59.999'

---Please enter minEffectiveDateCompanyId details(I.E. companyId,researchcontributorid)
IF OBJECT_ID('TEMPDB..#minEffectiveDateCompanyIdCiqCoverage') IS NOT NULL DROP TABLE #minEffectiveDateCompanyIdCiqCoverage 
SELECT DISTINCT CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId,MAX(ED.effectiveDate) AS MinFilingDate
INTO #minEffectiveDateCompanyIdCiqCoverage
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
INNER JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ISNULL(ED.feedFileId,ED.versionId) = CT.collectionEntityId AND CT.relatedCompanyId = ED.companyId
INNER JOIN  Estimates.[dbo].[EstFull_vw] EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl rd (NOLOCK) ON rd.researchcontributorid = ED.researchcontributorid
INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId
WHERE       CT.collectionEntityTypeId IN (9,51)
AND         CT.collectionstageStatusId IN (4)
AND			CT.startDate IS NOT NULL
AND			CT.endDate IS NOT NULL
AND			rd.contributorShortName IS NOT NULL
AND         ED.effectiveDate >@minEffectiveDatefrDate AND ED.effectiveDate < @minEffectiveDatetoDate
AND         EDND.dataItemId IN (21625,21626,21634,21635,21638,21642,21649,21650,21661,114208)
AND         CT.relatedcompanyid IN (@minEffectiveDateCompanyId)
AND         ED.researchcontributorid IN (@researchcontributorid)
GROUP BY    CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId

---SELECT * FROM #minEffectiveDateCompanyIdCiqCoverage

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

---Please enter maxEffectiveDateCompanyId details(I.E. companyId,researchcontributorid)

IF OBJECT_ID('TEMPDB..#maxEffectiveDateCompanyIdCiqCoverage') IS NOT NULL DROP TABLE #maxEffectiveDateCompanyIdCiqCoverage 
SELECT DISTINCT CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId,MAX(ED.effectiveDate) AS MaxFilingDate
INTO #maxEffectiveDateCompanyIdCiqCoverage
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
INNER JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ISNULL(ED.feedFileId,ED.versionId) = CT.collectionEntityId AND CT.relatedCompanyId = ED.companyId
INNER JOIN  Estimates.[dbo].[EstFull_vw] EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl rd (NOLOCK) ON rd.researchcontributorid = ED.researchcontributorid
INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId
WHERE       CT.collectionEntityTypeId IN (9,51)
AND         CT.collectionstageStatusId IN (4)
AND			CT.startDate IS NOT NULL
AND			CT.endDate IS NOT NULL
AND			rd.contributorShortName IS NOT NULL
AND         ED.effectiveDate > @maxEffectiveDatefrDate AND ED.effectiveDate < @maxEffectiveDatetoDate
AND         EDND.dataItemId IN (21625,21626,21634,21635,21638,21642,21649,21650,21661,114208)
AND         CT.relatedcompanyid IN (@maxEffectiveDateCompanyId)
AND         ED.researchcontributorid IN (@researchcontributorid)
GROUP BY    CT.collectionEntityId,rd.researchcontributorid,rd.contributorShortName,CT.relatedCompanyId

---SELECT * FROM #maxEffectiveDateCompanyIdCiqCoverage


SELECT DISTINCT collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,MinFilingDate,contributorShortName 
FROM #minEffectiveDateCompanyIdCiqCoverage
ORDER BY MinFilingDate



SELECT DISTINCT collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,MaxFilingDate,contributorShortName 
FROM #maxEffectiveDateCompanyIdCiqCoverage
ORDER BY MaxFilingDate














