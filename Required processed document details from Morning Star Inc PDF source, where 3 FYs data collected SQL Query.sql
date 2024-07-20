
--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE

USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2024-06-01 00:00:00.000'
SET @todate='2024-06-30 23:59:59.999'

IF OBJECT_ID('TEMPDB..#PDFDocs') IS NOT NULL DROP TABLE #PDFDocs 
SELECT DISTINCT CT.*,CONVERT(VARCHAR(10),insertedDate,101)Date2,cp.collectionProcessName,vf.Description,v.formatID,ED.effectiveDate,PEO=dbo.formatperiodid_fn(ED.estimateperiodid),
CASE WHEN v.formatID IN (7,63,64,83,157,177,176) THEN 'EXCEL' ELSE 'PDF' END AS DocFormat,css.collectionStageStatusName,rd.researchcontributorid,
rd.contributorShortName INTO #PDFDocs
FROM WorkflowArchive_Estimates.[dbo].CommonTracker_vw CT
LEFT JOIN   workflow_Estimates.[dbo].CollectionEntityToProcessToDataPoint_tbl cdp (NOLOCK) ON cdp.collectionEntityToProcessId = CT.collectionEntityToProcessId AND cdp.datapointid  = 1887
LEFT JOIN   Estimates.[dbo].Estimates_IndustrySubTypeToCollectionProcess_tbl  est (NOLOCK) ON est.industrysubtypeid = cdp.value 
LEFT JOIN   workflow_Estimates.[dbo].collectionprocess_tbl cp (NOLOCK) ON cp.collectionProcessId = ISNULL(est.collectionProcessId,CT.collectionProcessId) 
INNER JOIN  Estimates.[dbo].EstimateDetail_tbl ED (NOLOCK) ON ISNULL(ED.versionId,ED.feedFileId) = CT.collectionEntityId
--INNER JOIN  Estimates.[dbo].EstimatePeriod_tbl EP (NOLOCK) ON ED.estimateperiodid = EP.estimateperiodid
LEFT JOIN   ComparisonData.[dbo].ResearchContributor_tbl rd (NOLOCK) ON rd.researchcontributorid = ED.researchcontributorid
LEFT JOIN   DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId = CT.collectionEntityId
INNER JOIN  DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID =v.formatID
INNER JOIN  Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId = CT.collectionstageStatusId
WHERE       CT.collectionStageId IN (2)  AND CT.collectionProcessId IN (64,1062) AND CT.collectionEntityTypeId IN (9)
AND         CT.insertedDate > = @frDate  AND CT.insertedDate <= @toDate
AND         vf.formatID IN (4,12,16,32,52,94,140,145,149,155,192,195,200,201,205,208,209,210,213,214,215,218,221)
AND         rd.researchcontributorid IN (2494)
AND			CT.startDate IS NOT NULL
AND			CT.endDate IS NOT NULL
AND			rd.contributorShortName IS NOT NULL
AND         CT.relatedCompanyId IS NOT NULL




--SELECT DISTINCT * FROM #PDFDocs

-- Included Indices Versions

IF OBJECT_ID('TEMPDB..#Periodic') IS NOT NULL DROP TABLE #Periodic 
SELECT DISTINCT researchcontributorid,contributorShortName,collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,effectiveDate AS FilingDate,startDate,endDate,
DATEDIFF(MINUTE,startDate,endDate) AS Duration_Min,DocFormat,PEO INTO #Periodic FROM #PDFDocs
ORDER BY effectiveDate

---SELECT DISTINCT * FROM #Periodic

IF OBJECT_ID('TEMPDB..#NonPeriodic') IS NOT NULL DROP TABLE #NonPeriodic 
SELECT DISTINCT researchcontributorid,contributorShortName,collectionEntityId AS VersionId,relatedCompanyId AS CompanyId,effectiveDate AS FilingDate,startDate,endDate,
DATEDIFF(MINUTE,startDate,endDate) AS Duration_Min,DocFormat,PEO INTO #NonPeriodic FROM #PDFDocs
WHERE peo = 'NA'
ORDER BY effectiveDate

---SELECT DISTINCT * FROM #NonPeriodic

IF OBJECT_ID('TEMPDB..#Sfinal') IS NOT NULL DROP TABLE #Sfinal 
SELECT DISTINCT * INTO #Sfinal FROM #Periodic
EXCEPT
SELECT DISTINCT * FROM #NonPeriodic

---SELECT DISTINCT * FROM #Sfinal

SELECT DISTINCT researchcontributorid,contributorShortName,VersionId,CompanyId,FilingDate,
DocFormat,COUNT(DISTINCT(PEO)) AS FYs_Count FROM #Sfinal
WHERE PEO IS NOT NULL
GROUP BY researchcontributorid,contributorShortName,VersionId,CompanyId,FilingDate,DocFormat
HAVING COUNT(DISTINCT(PEO))>2
ORDER BY FilingDate,VersionId,CompanyId





